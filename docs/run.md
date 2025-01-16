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

# Important commands

If you make any changes in the code, this is how you can build the project:

```bash
cmake .. -DBUILD_TESTING=OFF
cmake --build . --config Release -- -j 4
```

If you open a new terminal, you need to source `setup_env.sh`:

```bash
source <OPENEB_SRC_DIR>/build/utils/scripts/setup_env.sh
# for example
source ~/openeb/build/utils/scripts/setup_env.sh
```

> [!NOTE]
>
> You may add this to your `~/.bashrc` to make it permanent:
> ```bash
> nano ~/.bashrc
> # Add this line to the very end:
> source <OPENEB_SRC_DIR>/utils/scripts/setup_env.sh
> ```

This is how you run a python script:

```bash
~/openeb_venv/bin/python <name>.py
```

> You can find example scripts in the `samples` folder:
> 
> ```bash
> ~/openeb_venv/bin/python ~/openeb/sdk/modules/core/python/samples/<name>/<name>.py
> ```

This is how you run a C++ script:

```bash
build/bin/<name> [args]
```