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

# generate-code - https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards
# Maxwell (CUDA >= 6 <= 11)
# 50 / Quadro 4000, Quadro 6000
# 52 / GTX970, GTX980, GTX Titan X
# 53 / Tegra X1, Jetson nano
# Pascal (CUDA >= 8)
# 60 / Quadro GP100, Tesla P100
# 61 / GTX1050, GTX1060, GTX1070, GTX1080, GTX1080Ti, Titan Xp, Tesla P4, Tesla P40
# 62 / Tegra X2
# Turing (CUDA >= 9)
# 75 / GTX1660, RTX2060, RTX2070, RTX2080, RTX2080Ti, Titan RTX
# Ampere (CUDA >= 11.1)
# 80 / A100
# 86 / RTX3050, RTX3060, RTX3060Ti, RTX3070, RTX3080, RTX3090, RTX A4000, RTX A6000, RTX A40, RTX A10
# 87 / Jetson AGX
if ($target -eq "python") {
    $enablePython = "ON"
    $enableC_API = "OFF"
    $createDLL = "OFF"

    cmake -B ../build . `
    -DCMAKE_CXX_FLAGS="/std:c++20 /EHsc /wd4819" `
    -DBUILD_SHARED_LIBS="$createDLL" -DFAISS_ENABLE_PYTHON="$enablePython" -DFAISS_ENABLE_C_API="$enableC_API" `
    -DBLA_VENDOR=OpenBLAS            -DBLAS_LIBRARIES="$openblasLIB"       -DLAPACK_LIBRARIES="$openblasLIB" `
    -DFAISS_OPT_LEVEL="$optLevel"    -DFAISS_ENABLE_GPU="$useGPU" `
    -DCMAKE_BUILD_TYPE=Release       -DBUILD_TESTING=OFF `
    -DCMAKE_CUDA_ARCHITECTURES="86"

    cd ../build

    copy-item -force $openblasROOT/lib/libopenblas.lib faiss/python/
    copy-item -force $pythonDIR/libs/python*.lib faiss/python/

    cmake --build . --config Release --target swigfaiss -j6
    copy-item -force $openblasROOT/bin/libopenblas.dll faiss/python/libopenblas.exp.dll
    remove-item -r -force -ea 0 ../dist
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
    -DCMAKE_BUILD_TYPE=Release       -DBUILD_TESTING=OFF `
    -DCMAKE_CUDA_ARCHITECTURES="86"

    cd ../build

    copy-item -force $openblasROOT/lib/libopenblas.lib faiss/

    cmake --build . --config Release --target faiss_c -j6
}

cd ..

