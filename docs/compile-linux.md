[🏠 Home](https://github.com/ubi-coro/openeb)

---

# Compiling on Linux

Compilation and execution were tested on platforms that meet the following requirements:

| | |
-|-
OS | Ubuntu 22.04 or 24.04<br>64-bit
Architecture | amd64 (x64)
Graphics card | support of OpenGL 3.0 or higher

> [!WARNING]
>
> Compilation on other platforms (alternative Linux distributions, different versions of Ubuntu, ARM processor architecture etc.) was not tested. For those platforms some adjustments to this guide or to the code itself may be required.

<details>
<summary><h2>Upgrading OpenEB</h2></summary>

Read carefully the [Release Notes](https://docs.prophesee.ai/stable/release_notes.html) as some changes may impact your usage of our SDK (e.g. [API](https://docs.prophesee.ai/stable/api.html) updates) and cameras (e.g. [firmware update](https://support.prophesee.ai/portal/en/kb/articles/evk-firmware-versions) might be necessary).

Clean your system from previously installed Prophesee software.

> If after a previous compilation, you chose to deploy the Metavision files in your system path, then go to the `build` folder in the source code directory and launch the following command to remove those files:
>
> ```bash
> sudo make uninstall
> ```

Make a global check in your system paths (`/usr/lib`, `/usr/local/lib`, `/usr/include`, `/usr/local/include`) and in your environment variables (`PATH`, `PYTHONPATH` and `LD_LIBRARY_PATH`) to remove occurrences of Prophesee or Metavision files.
</details>

## Retrieving OpenEB source code

Clone the [GitHub repository](https://github.com/prophesee-ai/openeb):

```bash
git clone https://github.com/prophesee-ai/openeb.git --branch 5.1.1
```

In the following sections, absolute path to this directory is called `OPENEB_SRC_DIR`.

> [!CAUTION]
>
> If you choose to download an archive of OpenEB from GitHub rather than cloning the repository, you need to ensure that you select a `Full.Source.Code.*` archive instead of using the automatically generated `Source.Code.*` archives. This is because the latter does not include a necessary submodule.

## Prerequisites

Install the following dependencies:

```bash
sudo apt update
sudo apt -y install apt-utils build-essential software-properties-common wget unzip curl git cmake
sudo apt -y install libopencv-dev libboost-all-dev libusb-1.0-0-dev libprotobuf-dev protobuf-compiler
sudo apt -y install libhdf5-dev hdf5-tools libglew-dev libglfw3-dev libcanberra-gtk-module ffmpeg 
```

> [!NOTE]
>
> Optionally, if you want to run the tests, you need to install `Google Gtest` and `Gmock` packages.
> For more details, see [Google Test User Guide](https://google.github.io/googletest/):
>
> ```bash
> sudo apt -y install libgtest-dev libgmock-dev
> ```

### Python libraries

For the [Python API](https://docs.prophesee.ai/stable/api/python/index.html#chapter-api-python), you will need Python and some additional libraries.
We support Python 3.9 and 3.10 on Ubuntu 22.04 and Python 3.11 and 3.12 on Ubuntu 24.04.

We recommend using Python with [virtualenv](https://virtualenv.pypa.io/en/latest/) to avoid conflicts with other installed Python packages.
So, first install it along with some Python development tools:

```bash
sudo apt -y install python3.x-venv python3.x-dev
# where "x" is 9, 10, 11 or 12 depending on your Python version
```

Next, create a virtual environment and install the necessary dependencies:

```bash
python3 -m venv /tmp/prophesee/py3venv --system-site-packages
/tmp/prophesee/py3venv/bin/python -m pip install pip --upgrade
/tmp/prophesee/py3venv/bin/python -m pip install -r <OPENEB_SRC_DIR>/utils/python/requirements_openeb.txt
```

> [!NOTE]
>
> When creating the virtual environment, it is necessary to use the `--system-site-packages` option to ensure that the SDK packages installed in the system directories are accessible. However, this option also makes your local user site-packages (typically found in `~/.local/lib/pythonX.Y/site-packages`) visible by default.
> To prevent this and maintain a cleaner virtual environment, you can set the environment variable `PYTHONNOUSERSITE` to true.

Optionally, you can run the `activate` command (`source /tmp/prophesee/py3venv/bin/activate`) to modify your shell's environment variables, setting the virtual environment's Python interpreter and scripts as the default for your current session.
This allows you to use simple commands like `python` without needing to specify the full path each time.

The Python bindings of the C++ API rely on the [pybind11](https://github.com/pybind) library, specifically version 2.11.0.

> [!NOTE]
>
> `pybind11` is required only if you want to use the Python bindings of the C++ API. You can opt out of creating these bindings by passing the argument `-DCOMPILE_PYTHON3_BINDINGS=OFF` at step 3 during compilation (see below). In that case, you will not need to install pybind11, but you won't be able to use our Python interface to the C++ API.

Unfortunately, there is no pre-compiled version of `pybind11` available, so you need to install it manually:

```bash
wget https://github.com/pybind/pybind11/archive/v2.11.0.zip
unzip v2.11.0.zip
cd pybind11-2.11.0/
mkdir build && cd build
cmake .. -DPYBIND11_TEST=OFF
cmake --build .
sudo cmake --build . --target install
```

maybe also works:

```bash
pip install pybind11
brew install pybind11
```

### CUDA dependencies

To use Machine Learning features, you need to install some additional dependencies.

First, if you have some NVIDIA hardware with GPUs, you can optionally install [CUDA (11.6 or 11.7)](https://developer.nvidia.com/cuda-downloads) and [cuDNN](https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html) to leverage them with pytorch and libtorch.

Make sure that you install a version of CUDA that is compatible with your GPUs by checking [NVIDIA compatibility page](https://docs.nvidia.com/deeplearning/cudnn/support-matrix/index.html).

> [!NOTE]
>
> At the moment, we don't support [OpenCL](https://www.khronos.org/opencl/) and AMD GPUs.


## Compilation

1. Create and open the build directory in `OPENEB_SRC_DIR`
    ```bash
    mkdir build && cd build
    ```
2. Generate the makefiles using CMake
    ```bash
    cmake .. -DBUILD_TESTING=OFF
    ```

    > [!NOTE]
    >
    > If you want to specify to `cmake` which version of Python to consider, you should use the option
    >
    > ```bash
    > -DPython3_EXECUTABLE=<path_to_python_to_use>
    > ```
    >
    > This is useful, for example, when you have a more recent version of Python than the ones we support installed on your system.
    > In that case, `cmake` would select it and compilation might fail.

3. Compile
    ```bash
    cmake --build . --config Release -- -j 4
    ```

Once the compilation is finished, you have two options: you can choose to work directly from the `build` folder or you can deploy the OpenEB files in the system path (`/usr/local/lib`, `/usr/local/include`...).

* Option 1 - working from `build` folder

  * To use OpenEB directly from the `build` folder, you need to update some environment variables using this script (which you may add to your `~/.bashrc` to make it permanent):

    ```bash
    source utils/scripts/setup_env.sh
    ```

  * [Prophesee camera plugins](https://docs.prophesee.ai/stable/installation/camera_plugins.html) are included in OpenEB, but you still need to copy the udev rules files in the system path and reload them so that your camera is detected with this command:

    ```bash
    sudo cp <OPENEB_SRC_DIR>/hal_psee_plugins/resources/rules/*.rules /etc/udev/rules.d
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    ```

* Option 2 - deploying in the system path

  * To deploy OpenEB, launch the following command:

    ```bash
    sudo cmake --build . --target install
    ```

    > [!NOTE]
    >
    > You can also deploy the OpenEB files (applications, samples, libraries etc.) in a directory of your choice by using the `CMAKE_INSTALL_PREFIX` variable (`-DCMAKE_INSTALL_PREFIX=<OPENEB_INSTALL_DIR>`) when generating the makefiles in step 2. Similarly, you can configure the directory where the Python packages will be deployed using the `PYTHON3_SITE_PACKAGES` variable (`-DPYTHON3_SITE_PACKAGES=<PYTHON3_PACKAGES_INSTALL_DIR>`).

  * you also need to update `LD_LIBRARY_PATH` and `HDF5_PLUGIN_PATH` (which you may add to your `~/.bashrc` to make it permanent):

    ```bash
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
    export HDF5_PLUGIN_PATH=$HDF5_PLUGIN_PATH:/usr/local/hdf5/lib/plugin  # On Ubuntu 22.04
    export HDF5_PLUGIN_PATH=$HDF5_PLUGIN_PATH:/usr/local/lib/hdf5/plugin  # On Ubuntu 24.04
    ```

## Final thoughts

> [!NOTE]
>
> If you are using a third-party camera, you need to install the plugin provided by the camera vendor and specify the location of the plugin using the `MV_HAL_PLUGIN_PATH` environment variable.

To get started with OpenEB, you can download some [sample recordings](https://docs.prophesee.ai/stable/datasets.html) and visualize them with [metavision_viewer](https://docs.prophesee.ai/stable/samples/modules/stream/viewer.html) or you can stream data from your Prophesee-compatible event-based camera.

### Running the test suite (Optional)

Running the test suite is a sure-fire way to ensure you did everything well with your compilation and installation process.

 * Download [the files](https://kdrive.infomaniak.com/app/share/975517/2aa2545c-6b12-4478-992b-df2acfb81b38) necessary to run the tests.
   Click `Download` on the top right folder. Beware of the size of the obtained archive which weighs around 1.5 Gb.

 * Extract and put the content of this archive to `<OPENEB_SRC_DIR>/datasets`. 
   For instance, the correct path of sequence `gen31_timer.raw` should be `<OPENEB_SRC_DIR>/datasets/openeb/gen31_timer.raw`.

 * Regenerate the makefiles with the test options enabled:

  ```bash
  cd <OPENEB_SRC_DIR>/build
  cmake .. -DBUILD_TESTING=ON
  ```

 * Compile again.  `cmake --build . --config Release -- -j 4`

 * Finally, run the test suite:   `ctest --verbose`