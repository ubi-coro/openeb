[🏠 Home](https://github.com/ubi-coro/openeb)

---

# Compiling on Windows

Currently, we support only Windows 10. 
Compilation on other versions of Windows was not tested.
For those platforms some adjustments to this guide or to the code itself may be required.

<details>
<summary><h2>Upgrading OpenEB</h2></summary>

Read carefully the [Release Notes](https://docs.prophesee.ai/stable/release_notes.html) as some changes may impact your usage of our SDK (e.g. [API](https://docs.prophesee.ai/stable/api.html) updates) and cameras (e.g. [firmware update](https://support.prophesee.ai/portal/en/kb/articles/evk-firmware-versions) might be necessary).

Uninstall the previously installed software.
Remove the folders where you installed Metavision artifacts (check both the `build` folder of the source code and `C:\Program Files\Prophesee` which is the default install path of the deployment step).
</details>

## Retrieving OpenEB source code

Clone the [GitHub repository](https://github.com/prophesee-ai/openeb):

```bash
git clone https://github.com/prophesee-ai/openeb.git --branch 5.0.0
```

In the following sections, absolute path to this directory is called `OPENEB_SRC_DIR`.

If you choose to download an archive of OpenEB from GitHub rather than cloning the repository, you need to ensure that you select a `Full.Source.Code.*` archive instead of using the automatically generated `Source.Code.*` archives. This is because the latter do not include a necessary submodule.

## Prerequisites

> [!WARNING]
> 
> Some steps of this procedure don't work on `FAT32` and `exFAT` file system.
Hence, make sure that you are using a `NTFS` file system before going further.

Enable the support for long paths:

 * Hit the Windows key, type `gpedit.msc` and press Enter
 * Navigate to **Local Computer Policy** > **Computer Configuration** > **Administrative Templates** > **System** > **Filesystem**
 * Double-click the `Enable Win32 long paths` option, select the `Enabled` option and click `OK`.

Install the following tools:

 * Install [git](https://git-scm.com/download/win).
 * Install [CMake 3.26](https://cmake.org/files/v3.26/cmake-3.26.6-windows-x86_64.msi).
 * Install Microsoft C++ compiler (64-bit). You can choose one of the following solutions:
    * For building only, you can install MS Build Tools (free, part of Windows 10 SDK package)
      * Download and run ["Build tools for Visual Studio 2022" installer](https://visualstudio.microsoft.com/visual-cpp-build-tools/)
      * Select "C++ build tools", make sure Windows 10 SDK is checked, and add English Language Pack
    * For development, you can also download and run [Visual Studio Installer](https://visualstudio.microsoft.com/downloads/)    
 * Install [vcpkg](https://github.com/microsoft/vcpkg) that will be used for installing dependencies:
    * download and extract [vcpkg version 2024.04.26](https://github.com/microsoft/vcpkg/archive/refs/tags/2024.04.26.zip) in a folder that we will refer as `VCPKG_SRC_DIR`
    * `cd <VCPKG_SRC_DIR>`
    * `bootstrap-vcpkg.bat`
    * `vcpkg update`
    * copy the ``vcpkg-openeb.json`` file located in the OpenEB source code at ``utils/windows``
      into `VCPKG_SRC_DIR` and rename it to ``vcpkg.json``
  * install the libraries by running:
    * `vcpkg install --triplet x64-windows --x-install-root installed`
  * Finally, download and install [ffmpeg](https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z) and add the `bin` directory to your PATH.

> [!NOTE]
>
> If you're using `vcpkg` across multiple projects or versions of OpenEB, it’s beneficial to streamline the number of `vcpkg` installations you manage. To achieve this, you'll need the specific versions of the libraries required. You can find these versions by cross-referencing our `vcpkg.json` file with the [official vcpkg repository](https://github.com/microsoft/vcpkg/tree/2024.04.26/versions), but for your convenience, we’ve listed them below:
>
>  * libusb: `1.0.27`
>  * boost: `1.78.0`
>  * opencv: `4.8.0`
>  * dirent: `1.24.0`
>  * gtest: `1.14.0`
>  * pybind11: `2.12.0`
>  * glew: `2.2.0`
>  * glfw3: `3.4.0`
>  * hdf5: `1.14.2`
>  * protobuf: `3.21.12`

### Installing Python and libraries

* Download "Windows x86-64 executable installer" for one of these Python versions:
  * [Python 3.9](https://www.python.org/downloads/release/python-3913/)
  * [Python 3.10](https://www.python.org/downloads/release/python-31011/)
  * [Python 3.11](https://www.python.org/downloads/release/python-3119/)
  * [Python 3.12](https://www.python.org/downloads/release/python-3125/)
* Add Python install and script directories in your `PATH` and make sure they are listed before
  the `WindowsApps` folder which contains a Python alias launching the Microsoft Store. So, if you installed
  Python 3.9 in the default path, your user `PATH` should contain those three lines in that order:
  
```bash
%USERPROFILE%\AppData\Local\Programs\Python\Python39
%USERPROFILE%\AppData\Local\Programs\Python\Python39\Scripts
%USERPROFILE%\AppData\Local\Microsoft\WindowsApps
````
We recommend using Python with [virtualenv](https://virtualenv.pypa.io/en/latest/) to avoid conflicts with other installed Python packages.

Create a virtual environment and install the necessary dependencies:

```bash
python -m venv C:\tmp\prophesee\py3venv --system-site-packages
C:\tmp\prophesee\py3venv\Scripts\python -m pip install pip --upgrade
C:\tmp\prophesee\py3venv\Scripts\python -m pip install -r OPENEB_SRC_DIR\utils\python\python_requirements\requirements_openeb.txt
```

When creating the virtual environment, it is necessary to use the `--system-site-packages` option to ensure that
the SDK packages installed in the system directories are accessible. However, this option also makes your local
user site-packages visible by default.
To prevent this and maintain a cleaner virtual environment, you can set the environment variable `PYTHONNOUSERSITE` to true.

Optionally, you can run the `activate` command (`C:\tmp\prophesee\py3venv\Scripts\activate`) to modify your shell's environment variables,
setting the virtual environment's Python interpreter and scripts as the default for your current session.
This allows you to use simple commands like `python` without needing to specify the full path each time.

### Prerequisites for the ML module

To use Machine Learning features, you need to install some additional dependencies.

First, if you have some Nvidia hardware with GPUs, you can optionally install [CUDA (11.6 or 11.7)](https://developer.nvidia.com/cuda-downloads)
and [cuDNN](https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html) to leverage them with pytorch and libtorch.

## Compilation

<details>
<summary><h3>Compilation using CMake</h3></summary>

Open a command prompt inside the `OPENEB_SRC_DIR` folder :

 1. Create and open the build directory, where temporary files will be created: `mkdir build && cd build`
 2. Generate the makefiles using CMake: `cmake .. -A x64 -DCMAKE_TOOLCHAIN_FILE=<OPENEB_SRC_DIR>\cmake\toolchains\vcpkg.cmake -DVCPKG_DIRECTORY=<VCPKG_SRC_DIR>`.
    Note that the value passed to the parameter `-DCMAKE_TOOLCHAIN_FILE` must be an absolute path, not a relative one. 
 3. Compile: `cmake --build . --config Release --parallel 4`
 
Once the compilation is done, you have two options: you can choose to work directly from the `build` folder
or you can deploy the OpenEB files (applications, samples, libraries etc.) in a directory of your choice.

<details>
<summary>Option 1 - working from <code>build</code> folder</summary>

To use OpenEB directly from the `build` folder, you need to update some environment variables using this script:

```bash
utils\scripts\setup_env.bat
```
</details>

<details>
<summary>Option 2 - deploying in a directory of your choice</summary>

To deploy OpenEB in the default folder (`C:\Program Files\Prophesee`), execute this command (your console should be launched as an administrator):

```bash 
cmake --build . --config Release --target install
```

To deploy OpenEB in another folder, you should generate the solution again (step 2 above) with the additional variable `CMAKE_INSTALL_PREFIX` having the value of your target folder (`OPENEB_INSTALL_DIR`).

Similarly, to specify where the Python packages will be deployed (``PYTHON3_PACKAGES_INSTALL_DIR``), you should use the `PYTHON3_SITE_PACKAGES` variable.

Here is an example of a command customizing those two folders:
    
```bash
cmake .. -A x64 -DCMAKE_TOOLCHAIN_FILE=<OPENEB_SRC_DIR>\cmake\toolchains\vcpkg.cmake -DVCPKG_DIRECTORY=<VCPKG_SRC_DIR> -DCMAKE_INSTALL_PREFIX=<OPENEB_INSTALL_DIR> -DPYTHON3_SITE_PACKAGES=<PYTHON3_PACKAGES_INSTALL_DIR> -DBUILD_TESTING=OFF
```
    
After this command, you should launch the actual compilation and installation of OpenEB (your console should be launched as an administrator):

```bash
cmake --build . --config Release --parallel 4
cmake --build . --config Release --target install
```

You also need to manually edit some environment variables:

* append `<OPENEB_INSTALL_DIR>\bin` to `PATH` (`C:\Program Files\Prophesee\bin` if you used default configuration)
* append `<OPENEB_INSTALL_DIR>\lib\metavision\hal\plugins` to `MV_HAL_PLUGIN_PATH` (`C:\Program Files\Prophesee\lib\metavision\hal\plugins` if you used default configuration)
* append `<OPENEB_INSTALL_DIR>\lib\hdf5\plugin` to `HDF5_PLUGIN_PATH` (`C:\Program Files\Prophesee\lib\hdf5\plugin` if you used default configuration)
* append `<PYTHON3_PACKAGES_INSTALL_DIR>` to `PYTHONPATH` (not needed if you used default configuration)
</details>

</details>

<details>
<summary><h3>Compilation using MS Visual Studio</h3></summary>

Open a command prompt inside the `OPENEB_SRC_DIR` folder:

 1. Create and open the build directory, where temporary files will be created: `mkdir build && cd build`
 2. Generate the Visual Studio files using CMake: `cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_TOOLCHAIN_FILE=<OPENEB_SRC_DIR>\cmake\toolchains\vcpkg.cmake -DVCPKG_DIRECTORY=<VCPKG_SRC_DIR>` (adapt to your Visual Studio version).
    Note that the value passed to the parameter `-DCMAKE_TOOLCHAIN_FILE` must be an absolute path, not a relative one.
 3. Open the solution file `metavision.sln`, select the `Release` configuration and build the `ALL_BUILD` project.

Once the compilation is done, you can choose to work directly from the `build` folder
or you can deploy the OpenEB files (applications, samples, libraries etc.) in a directory of your choice.

<details>
<summary>Option 1 - working from the <code>build</code> folder</summary>

To use OpenEB directly from the `build` folder, you need to update the environment variables as done in the script `utils\scripts\setup_env.bat`.
</details>

<details>
<summary>Option 2 - deploying OpenEB</summary>

To deploy OpenEB, you need to build the `INSTALL` project. By default, files will be deployed in `C:\Program Files\Prophesee`.
</details>
</details>

### Camera Plugins

Prophesee camera plugins are included in OpenEB, but you need to install the drivers
for the cameras to be available on Windows. To do so, follow this procedure:

1. Download [wdi-simple.exe from our file server](https://kdrive.infomaniak.com/app/share/975517/4f59e852-af5e-4e00-90fc-f213aad20edd).
2. Execute the following commands in a Command Prompt launched as an administrator:

```bash
wdi-simple.exe -n "EVK" -m "Prophesee" -v 0x04b4 -p 0x00f4
wdi-simple.exe -n "EVK" -m "Prophesee" -v 0x04b4 -p 0x00f5
wdi-simple.exe -n "EVK" -m "Prophesee" -v 0x04b4 -p 0x00f3
```
> [!NOTE]
>
> If you own an EVK2 or an RDK2, there are a few additional steps to complete that are detailed in our online documentation in the [Camera Plugin section of the OpenEB install guide](https://docs.prophesee.ai/stable/installation/windows_openeb.html#camera-plugins).

> [!NOTE]
>
> If you are using a third-party camera, you need to follow the instructions provided by the camera vendor to install the driver and the camera plugin. Make sure that you reference the location of the plugin in the `MV_HAL_PLUGIN_PATH` environment variable.

### Getting Started

To get started with OpenEB, you can download some [sample recordings](https://docs.prophesee.ai/stable/datasets.html) and visualize them with [metavision_viewer](https://docs.prophesee.ai/stable/samples/modules/stream/viewer.html) or you can stream data from your Prophesee-compatible event-based camera.

## Running the test suite (Optional)

Running the test suite is a sure-fire way to ensure you did everything well with your compilation and installation process.

1. Download [the files](https://kdrive.infomaniak.com/app/share/975517/2aa2545c-6b12-4478-992b-df2acfb81b38) necessary to run the tests. Click `Download` on the top right folder. Beware of the size of the obtained archive which weighs around 1.5 Gb.
   
2. Extract and put the content of this archive to `<OPENEB_SRC_DIR>/datasets`. For instance, the correct path of sequence `gen31_timer.raw` should be `<OPENEB_SRC_DIR>/datasets/openeb/gen31_timer.raw`.

3. To run the test suite you need to reconfigure your build environment using CMake and to recompile

    <details>
    <summary>Compilation using CMake</summary>

    Regenerate the build using CMake (note that `-DCMAKE_TOOLCHAIN_FILE` must be absolute path, not a relative one)::

      ```
      cd <OPENEB_SRC_DIR>/build
      cmake .. -A x64 -DCMAKE_TOOLCHAIN_FILE=<OPENEB_SRC_DIR>\cmake\toolchains\vcpkg.cmake -DVCPKG_DIRECTORY=<VCPKG_SRC_DIR> -DBUILD_TESTING=ON
      ```
    Compile: `cmake --build . --config Release --parallel 4`
    </details>

    <details>
    <summary>Compilation using MS Visual Studio</summary>

    Generate the Visual Studio files using CMake (adapt the command to your Visual Studio version and note that `-DCMAKE_TOOLCHAIN_FILE` must be absolute path, not a relative one):

      `cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_TOOLCHAIN_FILE=<OPENEB_SRC_DIR>\cmake\toolchains\vcpkg.cmake -DVCPKG_DIRECTORY=<VCPKG_SRC_DIR> -DBUILD_TESTING=ON`

    Open the solution file `metavision.sln`, select the `Release` configuration and build the `ALL_BUILD` project.

    Running the test suite is then simply `ctest -C Release`.
    </details>