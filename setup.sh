#!/usr/bin/env bash
set -euo pipefail

# --- Preconditions -----------------------------------------------------------
# Support either a venv (VIRTUAL_ENV) or a conda env (CONDA_PREFIX, non-base).
if [[ -n "${VIRTUAL_ENV:-}" ]]; then
    ENV_KIND="venv"
    ENV_PREFIX="$VIRTUAL_ENV"
elif [[ -n "${CONDA_PREFIX:-}" && "${CONDA_DEFAULT_ENV:-}" != "base" ]]; then
    ENV_KIND="conda"
    ENV_PREFIX="$CONDA_PREFIX"
else
    echo "❌ Please activate a Python environment first."
    echo "   venv:  source .venv/bin/activate"
    echo "   conda: conda activate <env-name>    (must not be 'base')"
    exit 1
fi

echo "✅ Using $ENV_KIND: $ENV_PREFIX"
PYTHON=$(command -v python)
ENV_PY_VER=$($PYTHON -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

# --- System Dependencies -----------------------------------------------------
echo "📦 Installing system dependencies (requires sudo) ..."
sudo apt update
sudo apt install -y apt-utils build-essential cmake software-properties-common wget unzip curl git
sudo apt install -y libopencv-dev libboost-all-dev libusb-1.0-0-dev libprotobuf-dev protobuf-compiler
sudo apt install -y libhdf5-dev hdf5-tools libglew-dev libglfw3-dev libcanberra-gtk-module ffmpeg mesa-utils libgl1-mesa-dev

# Dynamically install the exact Python dev headers for whatever version the env is using.
# Conda ships its own Python headers, so this is only needed for system-python venvs.
if [[ "$ENV_KIND" == "venv" ]]; then
    sudo apt install -y "python${ENV_PY_VER}-dev"
fi

# --- Python Dependencies -----------------------------------------------------
echo "🐍 Installing Python build dependencies ..."
pip install --upgrade pip
pip install pybind11

# Install OpenEB requirements
if [[ -f "utils/python/requirements_openeb.txt" ]]; then
    pip install -r utils/python/requirements_openeb.txt
else
    echo "⚠️ utils/python/requirements_openeb.txt not found! Make sure you are running this from the openeb root."
fi

# --- Build & Install ---------------------------------------------------------
echo "🔨 Configuring and building OpenEB ..."
mkdir -p build && cd build

# Nuke old cache to prevent CMake from holding onto ghost paths
rm -f CMakeCache.txt

# Explicitly lock CMake to the active env
cmake .. \
   -DCMAKE_INSTALL_RPATH="$ENV_PREFIX/lib" \
   -DCMAKE_BUILD_TYPE=Release \
   -DBUILD_PYTHON3_BINDINGS=ON \
   -DPython3_EXECUTABLE="$PYTHON" \
   -DPYTHON_EXECUTABLE="$PYTHON" \
   -DCMAKE_INSTALL_PREFIX="$ENV_PREFIX" \
   -Dpybind11_DIR="$($PYTHON -c "import pybind11; print(pybind11.get_cmake_dir())")"

cmake --build . --parallel $(nproc)

echo "🚀 Installing to $ENV_KIND (requires sudo for udev rules) ..."
# We use sudo to allow the udev rules to copy to /etc/udev/rules.d/
sudo cmake --install .

# Immediately reclaim ownership of the env so root doesn't lock us out
sudo chown -R $USER:$USER "$ENV_PREFIX"

# Reload the new udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger
echo "✅ udev rules installed and loaded. Replug the camera if it’s connected."

cd ..

# --- Debian/Ubuntu dist-packages fix ----------------------------------------
# CMake on Debian/Ubuntu may install Python extensions into 'dist-packages'
# rather than the env's native 'site-packages'.
export PYTHONPATH="$ENV_PREFIX/lib/python${ENV_PY_VER}/dist-packages:$ENV_PREFIX/local/lib/python${ENV_PY_VER}/dist-packages:${PYTHONPATH:-}"

# --- Compute Metavision paths ------------------------------------------------
echo "🔎 Detecting Metavision SDK locations ..."
MV_SDK_CORE_DIR="$($PYTHON - <<'PY'
import pathlib, sys
try:
    import metavision_sdk_core as m
    print(pathlib.Path(m.__file__).parent)
except Exception:
    print(""); sys.exit(0)
PY
)"

MV_HAL_DIR="$($PYTHON - <<'PY'
import pathlib, sys
try:
    import metavision_hal as m
    p = pathlib.Path(m.__file__).parent
    for d in (p/"plugins", p/"hal_plugins", p/"hal"/"plugins"):
        if d.exists():
            print(d); break
    else:
        print("")
except Exception:
    print("")
PY
)"

# --- Idempotently patch env activation --------------------------------------
MARK_START="# >>> METAVISION AUTO-CONFIG >>>"
MARK_END="# <<< METAVISION AUTO-CONFIG <<<"

# The exports we want applied on every activation. Uses $VIRTUAL_ENV for venv
# and $CONDA_PREFIX for conda — resolved at activation time, not now.
read -r -d '' AUTO_CONFIG_BODY <<'ACT' || true
# Metavision runtime: make env's native libs visible
if [ -n "${VIRTUAL_ENV:-}" ]; then
    _MV_PREFIX="$VIRTUAL_ENV"
elif [ -n "${CONDA_PREFIX:-}" ]; then
    _MV_PREFIX="$CONDA_PREFIX"
fi
export LD_LIBRARY_PATH="$_MV_PREFIX/lib:${LD_LIBRARY_PATH:-}"

# Debian/Ubuntu dist-packages
_MV_PY_VER=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
export PYTHONPATH="$_MV_PREFIX/lib/python${_MV_PY_VER}/dist-packages:$_MV_PREFIX/local/lib/python${_MV_PY_VER}/dist-packages:${PYTHONPATH:-}"
unset _MV_PREFIX _MV_PY_VER

# Metavision HAL plugin path (computed dynamically if module is present)
export MV_HAL_PLUGIN_PATH="$(
    python - <<'PY'
import pathlib, sys
try:
    import metavision_hal as m
    p = pathlib.Path(m.__file__).parent
    for d in (p/"plugins", p/"hal_plugins", p/"hal"/"plugins"):
        if d.exists():
            print(d); break
except Exception:
    pass
PY
)"

# Headless/SSH tip (uncomment if needed)
# export QT_QPA_PLATFORM=xcb
ACT

if [[ "$ENV_KIND" == "venv" ]]; then
    ACTIVATE="$ENV_PREFIX/bin/activate"
    if ! grep -q "$MARK_START" "$ACTIVATE"; then
        echo "🧩 Patching $ACTIVATE to export runtime paths ..."
        {
            echo ""
            echo "$MARK_START"
            echo "$AUTO_CONFIG_BODY"
            echo "$MARK_END"
        } >> "$ACTIVATE"
    else
        echo "ℹ️ $ACTIVATE already contains Metavision auto-config; leaving as-is."
    fi
    REACTIVATE_HINT="deactivate && source $ACTIVATE"
else
    # conda: drop a script into activate.d so it runs on every `conda activate`
    ACTIVATE_DIR="$ENV_PREFIX/etc/conda/activate.d"
    ACTIVATE="$ACTIVATE_DIR/metavision.sh"
    mkdir -p "$ACTIVATE_DIR"
    if [[ ! -f "$ACTIVATE" ]] || ! grep -q "$MARK_START" "$ACTIVATE"; then
        echo "🧩 Writing $ACTIVATE to export runtime paths ..."
        {
            echo "$MARK_START"
            echo "$AUTO_CONFIG_BODY"
            echo "$MARK_END"
        } > "$ACTIVATE"
    else
        echo "ℹ️ $ACTIVATE already contains Metavision auto-config; leaving as-is."
    fi
    REACTIVATE_HINT="conda deactivate && conda activate ${CONDA_DEFAULT_ENV:-<env>}"
fi

# --- Apply the exports for this shell now ------------------------------------
export LD_LIBRARY_PATH="$ENV_PREFIX/lib:${LD_LIBRARY_PATH:-}"
if [[ -n "$MV_HAL_DIR" ]]; then
    export MV_HAL_PLUGIN_PATH="$MV_HAL_DIR"
fi

# --- Health check ------------------------------------------------------------
echo "🧪 Import test ..."
$PYTHON - <<'PY'
import importlib
mods = ["metavision_core","metavision_hal","metavision_sdk_core","metavision_sdk_ui"]
for m in mods:
    try:
        importlib.import_module(m)
        print(f"✅ {m} import OK")
    except Exception as e:
        print(f"❌ {m} import FAILED: {e}")
PY

echo "🧪 Native deps (ldd) on HAL .so ..."
$PYTHON - <<'PY'
import pathlib, importlib
try:
    import metavision_hal as m
    p = pathlib.Path(m.__file__).parent
    so = next((x for x in p.glob("*.so")), None)
    print(f"HAL .so: {so}")
except Exception as e:
    print(f"Skip ldd: {e}")
PY
if command -v ldd >/dev/null 2>&1; then
    SO_PATH="$($PYTHON - <<'PY'
import pathlib, importlib, sys
try:
    import metavision_hal as m
    p = pathlib.Path(m.__file__).parent
    so = next((x for x in p.glob("*.so")), None)
    print(so or "")
except Exception:
    print("")
PY
)"
    if [[ -n "$SO_PATH" && -f "$SO_PATH" ]]; then
        MISSING="$(ldd "$SO_PATH" | awk '/not found/ {print}')"
        if [[ -n "$MISSING" ]]; then
            echo "❌ Missing native libs:"
            echo "$MISSING"
            exit 2
        else
            echo "✅ All native deps found."
        fi
    fi
fi

echo "🎉 Metavision environment ready. Reactivate to persist: '$REACTIVATE_HINT'"
