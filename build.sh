#!/bin/bash

# Prequisites
# - Assumed on Ubuntu 22.04
# - Because of doxygen issue so, swig should >= 4.0.2
# - Run below commands before running this script
# sudo apt update
### apt-cache search openblas
### sudo apt install swig4.0 libblas-dev liblapack-dev
# sudo apt install swig4.0 libopenblas-dev
### Found BLAS: /usr/lib/x86_64-linux-gnu/libopenblas.so  
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu

# cp /usr/lib/x86_64-linux-gnu/libopenblas.so ./

# Uninstall
# Remove /home/username/.local/lib/python3.10/site-packages/faiss


mode="python" # python, c_api
if [ -n "$1" ]; then
    if [ "$1" = "python" ] || [ "$2" = "c_api" ]; then
        mode="$1"
    else
        echo "Invalid mode. Please use either python or c_api"
        echo "Usage: ./build.sh python"
        exit 1
    fi
fi

enablePython="OFF"
enableC_API="OFF"
useGPU="ON"
createSO="ON"
optLevel="avx2" # generic, avx2

threadCount=4

openblasLIB="libopenblas"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu


start_time=$(date +%s)


cd faiss

if [ "$mode" = "python" ]; then
    enablePython="ON"
    enableC_API="OFF"
    createSO="ON"

    cmake -B ../build_lin . \
        -DCMAKE_CXX_FLAGS="-std=c++17" \
        -DBUILD_SHARED_LIBS="$createSO" -DFAISS_ENABLE_PYTHON="$enablePython" -DFAISS_ENABLE_C_API="$enableC_API" \
        -DFAISS_OPT_LEVEL="$optLevel"   -DFAISS_ENABLE_GPU="$useGPU" \
        -DCMAKE_BUILD_TYPE=Release      -DBUILD_TESTING=OFF \
        -DCMAKE_CUDA_ARCHITECTURES="86-real"

    cd ../build_lin
    cmake --build . --config Release --target swigfaiss -j $threadCount

    cp -f /usr/lib/x86_64-linux-gnu/libopenblas.so ./faiss/python/

    mkdir -p ../dist_lin
    cp -rf faiss/python/* ../dist_lin/
else
    enablePython="OFF"
    enableC_API="ON"
    createSO="ON"

    cmake -B ../build_lin . \
        -DCMAKE_CXX_FLAGS="-std=c++17" \
        -DBUILD_SHARED_LIBS="$createSO" -DFAISS_ENABLE_PYTHON="$enablePython" -DFAISS_ENABLE_C_API="$enableC_API" \
        -DBLA_VENDOR=OpenBLAS           -DBLAS_LIBRARIES="$openblasLIB"       -DLAPACK_LIBRARIES="$openblasLIB" \
        -DFAISS_OPT_LEVEL="$optLevel"   -DFAISS_ENABLE_GPU="$useGPU" \
        -DCMAKE_BUILD_TYPE=Release      -DBUILD_TESTING=OFF \
        -DCMAKE_CUDA_ARCHITECTURES="86-real"

    cd ../build_lin
    cmake --build . --config Release --target faiss_c -j $threadCount

    cp -f /usr/lib/x86_64-linux-gnu/libopenblas.so ./faiss/python/

    mkdir -p ../dist_lin
    cp -rf faiss/python/* ../dist_lin/
fi

cd ..


end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
formatted_time=$(date -u -d @${elapsed_time} +"%T")
echo "Elapsed time: $formatted_time"
