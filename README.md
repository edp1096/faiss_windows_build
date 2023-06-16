faiss build for my windows machine.

Not much tested.

## Environment on my machine
* Visual Studio 2022 community
* CMake 3.25.0, 3.26.3
* Python 3.7.3, 3.10.7
* CUDA 12.1


## Build

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

* `OpenBLAS` and `SWIG` will be downloaded and be used during compilation
```powershell
./build.ps1

cd faiss/build/faiss/python
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
* Delete `site-packages/faiss-1.7.4-py3.xx.egg` folder
