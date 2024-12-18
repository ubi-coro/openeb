[🏠 Home](https://github.com/ubi-coro/openeb)

---

# Overview

```bash
build
├───bin
│   ├───metavision_viewer
│   └───...
└───utils
    └───scripts
            📜 setup_env.sh
cmake
docs
hal
hal_psee_plugins
licensing
sdk
├───cmake
└───modules
    ├───base
    ├───core
    ├───core_ml
    ├───stream
    │   ├───cpp
    │   │   └───samples
    │   │       └───...
    │   └───python
    │       └───samples
    │           └───...
    └───ui
    📜 CMakeLists.txt
standalone_samples
utils
📜 CMakeLists.txt
📜 conftest.py
📜 pytest.ini
📜 README.md
```

# Compilation

```bash
cmake .. -DBUILD_TESTING=OFF
cmake --build . --config Release -- -j 4
```

```bash
source ~/openeb/build/utils/scripts/setup_env.sh
```

Run a python script:

```bash
~/openeb_venv/bin/python <name>.py
```

> You can find example scripts in the `samples` folder:
> 
> ```bash
> ~/openeb_venv/bin/python ~/openeb/sdk/modules/core/python/samples/<name>/<name>.py
> ```

Run a C++ script:

```bash
build/bin/<name> [args]
```