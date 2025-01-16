[🏠 Home](https://github.com/ubi-coro/openeb)

---

# Compiling on MacOS

## Retrieving OpenEB source code

Clone the [GitHub repository](https://github.com/prophesee-ai/openeb) in a path that doesn't contain any spaces:

> [!NOTE]
>
> If you clone into a path that contains spaces, you will get an error when sourcing. This is because the environment variables cannot be set.
>
>  Go into `path/to/openeb/build/utils/scripts/setup_env.sh`.
>
> Either change all ` ` to `\ `:
>
> ```bash
> export PATH=/Users/jozseflurvig/GitHub\ Projects/openeb/build/bin:$PATH
> export MV_HAL_PLUGIN_PATH=/Users/jozseflurvig/GitHub\ Projects/openeb/build/lib/metavision/hal/plugins
> export PYTHONPATH=/Users/jozseflurvig/GitHub\ Projects/openeb/build/py3:/Users/jozseflurvig/GitHub\ Projects/openeb/sdk/modules/core_ml/python/pypkg:/Users/jozseflurvig/GitHub\ Projects/openeb/sdk/modules/core/python/pypkg::/Users/jozseflurvig/GitHub\ Projects/openeb/utils/python:/Users/jozseflurvig/GitHub\ Projects/openeb/utils/ci:$PYTHONPATH
> export HDF5_PLUGIN_PATH=/Users/jozseflurvig/GitHub\ Projects/openeb/build/lib/hdf5/plugin
> exec "$@"
> ```
>
> or put the whole path in quotation marks:
>
> ```bash
> export PATH="/Users/jozseflurvig/GitHub Projects/openeb/build/bin":$PATH
> export MV_HAL_PLUGIN_PATH="/Users/jozseflurvig/GitHub Projects/openeb/build/lib/metavision/hal/plugins"
> export PYTHONPATH="/Users/jozseflurvig/GitHub Projects/openeb/build/py3":"/Users/jozseflurvig/GitHub Projects/openeb/sdk/modules/core_ml/python/pypkg":"/Users/jozseflurvig/GitHub Projects/openeb/sdk/modules/core/python/pypkg"::"/Users/jozseflurvig/GitHub Projects/openeb/utils/python":"/Users/jozseflurvig/GitHub Projects/openeb/utils/ci":$PYTHONPATH
> export HDF5_PLUGIN_PATH="/Users/jozseflurvig/GitHub Projects/openeb/build/lib/hdf5/plugin"
> exec "$@"
> ```

```bash
git clone git@github.com:prophesee-ai/openeb.git
```

## Prerequisites

Install the following dependencies:

```bash
brew update
brew install cmake libusb boost pybind11 opencv glfw
```

## Compilation

Create and open the build directory in `OPENEB_SRC_DIR`

```bash
mkdir build && cd build
```

Generate the makefiles using CMake

```bash
cmake .. -DBUILD_TESTING=OFF
```

Compile

```bash
cmake --build . --config Release -- -j 4
```
  
To use OpenEB directly from the `build` folder, you need to update some environment variables using this script (which you may add to your `~/.bashrc` to make it permanent):

```bash
source utils/scripts/setup_env.sh
```

## Necessary changes to the code

In `sdk/modules/ui/cpp/src/base_window.cpp` in the `LoadShaders()` function, change `version 310 es` to `version 330` (there are two occurencies in the file).

In `CMakeLists.txt` file (in root folder) add:

```txt
if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    include_directories(/usr/local/include)
    link_directories(/usr/local/lib)
    
    include_directories(/opt/homebrew/include)
    link_directories(/opt/homebrew/lib)
endif()
```

and comment this line:

```txt
link_libraries(stdc++fs)
```