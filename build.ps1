$useGPU = "OFF"
$enablePython = "ON"
$createDLL = "ON"


$pythonDIR = $(python -c "import sysconfig; print(sysconfig.get_path('data'))").Replace("\", "/")
$env:LD_LIBRARY_PATH += ";$pythonDIR/libs"

echo "Prepare vendors..."
cd vendors

if (-not (Test-Path -Path "openblas.zip")) {
    echo "Downloading OpenBLAS..."
    curl --progress-bar -Lo openblas.zip https://github.com/xianyi/OpenBLAS/releases/download/v0.3.23/OpenBLAS-0.3.23-x64.zip

    mkdir -f openblas >$null
    rm -rf openblas/*
    tar -xf openblas.zip -C openblas
}

if (-not (Test-Path -Path "swig.zip")) {
    echo "Downloading SWIG..."
    curl --progress-bar -Lo swig.zip https://udomain.dl.sourceforge.net/project/swig/swigwin/swigwin-4.1.1/swigwin-4.1.1.zip

    mkdir -f swig >$null
    rm -rf swig/*
    tar -xf swig.zip -C swig
    mv swig/swigwin-4.1.1/* swig
    rm -rf swig/swigwin-4.1.1
}
$env:PATH += ";$pwd/swig"

cd ..


$openblasROOT = ("$pwd/vendors/openblas/").Replace("\", "/")
$openblasLIB = "libopenblas"

cp -rf mods/faiss/* faiss/

cd faiss

# cmake -B build . -G "MinGW Makefiles" -DCMAKE_CXX_FLAGS="-std=c++20 -fpermissive" -DLAPACK_LIBRARIES="openblas" -DBLAS_LIBRARIES="openblas" -DBLA_VENDOR=OpenBLAS -DFAISS_ENABLE_GPU=OFF -DFAISS_ENABLE_PYTHON=OFF -DBUILD_SHARED_LIBS=ON -DFAISS_ENABLE_C_API=ON -DBUILD_TESTING=OFF
# cmake -B build . -DCMAKE_CXX_FLAGS="/EHsc" -DLAPACK_LIBRARIES="openblas" -DBLAS_LIBRARIES="openblas" -DPython_EXECUTABLE="D:/dev/pcbangstudio/tools/langs/python3" -DBLA_VENDOR=OpenBLAS -DFAISS_ENABLE_GPU=ON -DFAISS_ENABLE_PYTHON=ON -DBUILD_SHARED_LIBS=ON -DFAISS_ENABLE_C_API=ON -DBUILD_TESTING=OFF
# cmake -B build . -DCMAKE_CXX_FLAGS="/EHsc" -DLAPACK_LIBRARIES="openblas" -DBLAS_LIBRARIES="openblas" -DBLA_VENDOR=OpenBLAS -DFAISS_ENABLE_GPU=ON -DFAISS_ENABLE_PYTHON=ON -DBUILD_SHARED_LIBS=ON -DFAISS_ENABLE_C_API=ON -DBUILD_TESTING=OFF -DPYTHON_INCLUDE_DIR=$pythonIncludeDIR -DPYTHON_LIBRARY=$pythonLibDIR
# cmake -B build . -DCMAKE_PREFIX_PATH="$openblasROOT" -DCMAKE_CXX_FLAGS="/EHsc" -DLAPACK_LIBRARIES="$openblasLIB" -DBLAS_LIBRARIES="$openblasLIB" -DBLA_VENDOR=OpenBLAS -DFAISS_ENABLE_GPU="$useGPU" -DFAISS_ENABLE_PYTHON="$enablePython" -DPython_EXECUTABLE="$pythonDIR" -DPYTHON_INCLUDE_DIR="$pythonIncludeDIR" -DDPYTHON_LIBRARY="$pythonDIR/libs" -DBUILD_SHARED_LIBS="$createDLL" -DFAISS_ENABLE_C_API="ON" -DBUILD_TESTING=OFF
cmake -B build . -DCMAKE_PREFIX_PATH="$openblasROOT" -DCMAKE_CXX_FLAGS="/EHsc" -DLAPACK_LIBRARIES="$openblasLIB" -DBLAS_LIBRARIES="$openblasLIB" -DBLA_VENDOR=OpenBLAS -DFAISS_ENABLE_GPU="$useGPU" -DFAISS_ENABLE_PYTHON="$enablePython" -DBUILD_SHARED_LIBS="$createDLL" -DFAISS_ENABLE_C_API="ON" -DBUILD_TESTING=OFF

cd build

cp -f $openblasROOT/lib/libopenblas.lib faiss/
cp -f $pythonDIR/libs/python*.lib faiss/python/

cmake --build . --config Release


cd ../..
