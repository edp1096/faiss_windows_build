$enablePython = "ON" # This will build the python module or c-api
$useGPU = "ON"
$createDLL = "ON"

if ($enablePython -eq "ON") {
    # Flag "swigfaiss" not work with dll creation flag so, we need to build static library
    $createDLL = "OFF"
}


$pythonDIR = $(python -c "import sysconfig; print(sysconfig.get_path('data'))").Replace("\", "/")
$env:LD_LIBRARY_PATH += ";$pythonDIR/libs"


echo "Prepare vendors..."

cd vendors
import-module bitstransfer

if (-not (Test-Path -Path "openblas.zip")) {
    echo "Downloading OpenBLAS..."
    start-bitstransfer -destination openblas.zip -source https://github.com/xianyi/OpenBLAS/releases/download/v0.3.23/OpenBLAS-0.3.23-x64.zip

    mkdir -f openblas >$null
    remove-item -r -force -ea 0 openblas/*
    remove-item -force -ea 0 *.TMP
    tar -xf openblas.zip -C openblas
}

if (-not (Test-Path -Path "swig.zip")) {
    echo "Downloading SWIG..."
    start-bitstransfer -destination swig.zip -source https://udomain.dl.sourceforge.net/project/swig/swigwin/swigwin-4.1.1/swigwin-4.1.1.zip

    mkdir -f swig >$null
    remove-item -r -force -ea 0 swig/*
    remove-item -force -ea 0 *.TMP
    tar -xf swig.zip -C swig
    mv -ea 0 swig/swigwin-4.1.1/* swig
    remove-item -r -force -ea 0 swig/swigwin-4.1.1
}
$env:PATH += ";$pwd/swig"

cd ..


$openblasROOT = ("$pwd/vendors/openblas/").Replace("\", "/")
$openblasLIB = "libopenblas"

cp -r -force mods/faiss/* faiss/

cd faiss

cmake -B build . -DCMAKE_CXX_FLAGS="-i$pythonDIR/include" -DCMAKE_CXX_FLAGS="/EHsc" -DLAPACK_LIBRARIES="$openblasLIB" -DBLAS_LIBRARIES="$openblasLIB" -DBLA_VENDOR=OpenBLAS -DFAISS_ENABLE_GPU="$useGPU" -DFAISS_ENABLE_PYTHON="$enablePython" -DBUILD_SHARED_LIBS="$createDLL" -DFAISS_ENABLE_C_API="ON" -DBUILD_TESTING=OFF

cd build

cp -force $openblasROOT/lib/libopenblas.lib faiss/
cp -force $openblasROOT/lib/libopenblas.lib faiss/python/
cp -force $pythonDIR/libs/python*.lib faiss/python/

if ($enablePython -eq "ON") {
    cmake --build . --config Release --target swigfaiss
    cp -force $openblasROOT/bin/libopenblas.dll faiss/python/libopenblas.exp.dll
} else {
    cmake --build . --config Release --target faiss_c
}


cd ../..
