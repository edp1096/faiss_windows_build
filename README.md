faiss build for my windows machine.

Not tested.

## Environment on my machine
* Visual Studio 2022 community
* CMake 3.26.3
* Python 3.7.3
* CUDA 12.1 and maybe CUDNN also


## Build
* OpenBLAS and SWIG will be downloaded and be used when compile
* Compilation with CUDA make take veeeeeeeeeeeeery long time
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


## Clean
```powershell
./clean.ps1
```
