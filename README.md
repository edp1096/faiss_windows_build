faiss build for my windows machine.

Not so much tested.

`build.ps1` runs only for RTX30 series so for others, edit value of `CMAKE_CUDA_ARCHITECTURES` in `build.ps1` then rebuild.


## Environment on my machine
* H/W: AMD Ryzen 3600, 32GB RAM, RTX 3060Ti
* Visual Studio 2022 community
* CMake 3.26.3
* Python 3.7.3, 3.10.11
* CUDA Toolkit 12.1
    * Environment variable `CUDA_PATH` must be set
* Git 2.40.1


## Build

First, clone or download this repository.

### Powershell scripts
* Before execute `ps1` script files, `ExecutionPolicy` should be set to `RemoteSigned` and unblock `ps1` files
```powershell
# Check
ExecutionPolicy
# Set as RemoteSigned
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

# Unblock ps1 files
Unblock-File *.ps1
```

### Submodule
* Run if faiss submodule is not cloned yet
```powershell
git submodule update --init --recursive
cd faiss
git checkout v1.7.4
cd ..
```

### Compile
* Not use MKL. Instead `OpenBLAS` and `SWIG` will be downloaded and be used during compilation
```powershell
./build.ps1
```

### Install
```powershell
cd dist
python setup.py install
```


## Run
```powershell
cd samples/hello_faiss
python main.py

cd samples/gpu
python main.py
```


## Clean build
```powershell
./clean.ps1
# or
./clean.ps1 all # Remove OpenBLAS and SWIG
```

## Uninstall
* Delete `%PYTHON_LIB_PATH%/site-packages/faiss-1.7.4-py3.xx.egg` folder
