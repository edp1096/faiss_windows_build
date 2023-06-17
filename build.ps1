$target = "python" # python, c_api

$enablePython = "OFF"
$enableC_API = "OFF"
$useGPU = "ON"
$createDLL = "ON"
$optLevel = "avx2" # generic, avx2


if ($target -eq "python") {
    if (get-command "python.exe" -ea 0) {
        $pythonDIR = (python -c "import sysconfig; print(sysconfig.get_path('data'))").Replace("\", "/")
        $env:LD_LIBRARY_PATH += ";$pythonDIR/libs"
    } else {
        echo "Python not found."
        exit
    }
}


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
    move-item -ea 0 swig/swigwin-4.1.1/* swig
    remove-item -r -force -ea 0 swig/swigwin-4.1.1
}
$env:PATH += ";$pwd/swig"

cd ..


$openblasROOT = ("$pwd/vendors/openblas/").Replace("\", "/")
$openblasLIB = "libopenblas"

copy-item -r -force mods/faiss/* faiss/


cd faiss

if ($target -eq "python") {
    $enablePython = "ON"
    $enableC_API = "OFF"
    $createDLL = "OFF"

    cmake -B ../build . `
    -DCMAKE_CXX_FLAGS="/std:c++20 /EHsc /wd4819" `
    -DBUILD_SHARED_LIBS="$createDLL" -DFAISS_ENABLE_PYTHON="$enablePython" -DFAISS_ENABLE_C_API="$enableC_API" `
    -DBLA_VENDOR=OpenBLAS            -DBLAS_LIBRARIES="$openblasLIB"       -DLAPACK_LIBRARIES="$openblasLIB" `
    -DFAISS_OPT_LEVEL="$optLevel"    -DFAISS_ENABLE_GPU="$useGPU" `
    -DCMAKE_BUILD_TYPE=Release       -DBUILD_TESTING=OFF

    cd ../build

    copy-item -force $openblasROOT/lib/libopenblas.lib faiss/python/
    copy-item -force $pythonDIR/libs/python*.lib faiss/python/

    cmake --build . --config Release --target swigfaiss
    copy-item -force $openblasROOT/bin/libopenblas.dll faiss/python/libopenblas.exp.dll
    remove-item -r -force -ea 0 dist
    mkdir -f ../dist >$null
    copy-item -r -force faiss/python/* ../dist/
} else {
    $enablePython = "OFF"
    $enableC_API = "ON"
    $createDLL = "ON"

    cmake -B ../build . `
    -DCMAKE_CXX_FLAGS="/std:c++20 /EHsc /wd4819" `
    -DBUILD_SHARED_LIBS="$createDLL" -DFAISS_ENABLE_PYTHON="$enablePython" -DFAISS_ENABLE_C_API="$enableC_API" `
    -DBLA_VENDOR=OpenBLAS            -DBLAS_LIBRARIES="$openblasLIB"       -DLAPACK_LIBRARIES="$openblasLIB" `
    -DFAISS_OPT_LEVEL="$optLevel"    -DFAISS_ENABLE_GPU="$useGPU" `
    -DCMAKE_BUILD_TYPE=Release       -DBUILD_TESTING=OFF

    cd ../build

    copy-item -force $openblasROOT/lib/libopenblas.lib faiss/

    cmake --build . --config Release --target faiss_c
}

cd ..

