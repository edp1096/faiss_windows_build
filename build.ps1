$enablePython = "ON" # This will build the python module or c-api
$useGPU = "ON"
$createDLL = "OFF"


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

cmake -B build . -DCMAKE_CXX_FLAGS="-i$pythonDIR/include" -DCMAKE_CXX_FLAGS="/EHsc /openmp" -DLAPACK_LIBRARIES="$openblasLIB" -DBLAS_LIBRARIES="$openblasLIB" -DBLA_VENDOR=OpenBLAS -DFAISS_ENABLE_GPU="$useGPU" -DFAISS_ENABLE_PYTHON="$enablePython" -DBUILD_SHARED_LIBS="$createDLL" -DFAISS_ENABLE_C_API="ON" -DBUILD_TESTING=OFF

cd build

cp -f $openblasROOT/lib/libopenblas.lib faiss/
cp -f $openblasROOT/lib/libopenblas.lib faiss/python/
cp -f $pythonDIR/libs/python*.lib faiss/python/

if ($enablePython -eq "ON") {
    cmake --build . --config Release --target swigfaiss
    cp -f $openblasROOT/bin/libopenblas.dll faiss/python/libopenblas.exp.dll
} else {
    cmake --build . --config Release --target faiss_c
}


cd ../..
