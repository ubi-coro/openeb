# Overview

```bash
build
└───utils
    └───scripts
            📜 setup_env.sh
cmake
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
    │   └───python
    │       └───samples
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
~/openeb_venv/bin/python example.py
```

> You can find example scripts in the `sample` folder:
> 
> ```bash
> ~/openeb_venv/bin/python ~/openeb/sdk/modules/core/python/samples/metavision_sdk_get_started/metavision_sdk_get_started.py
> ```

Run a C++ script:

```bash
build/sdk/modules/stream/cpp/samples/...
```