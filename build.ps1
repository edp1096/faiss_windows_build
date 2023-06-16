$useGPU = "OFF"
$enablePython = "ON"
$createDLL = "ON"


echo "Prepare vendors..."
cd vendors

echo "Downloading OpenBLAS..."
curl --progress-bar -Lo openblas.zip https://github.com/xianyi/OpenBLAS/releases/download/v0.3.23/OpenBLAS-0.3.23-x64.zip

mkdir -f openblas >$null
rm -rf openblas/*
tar -xf openblas.zip -C openblas

echo "Downloading SWIG..."
curl --progress-bar -Lo swig.zip https://udomain.dl.sourceforge.net/project/swig/swigwin/swigwin-4.1.1/swigwin-4.1.1.zip

mkdir -f swig >$null
rm -rf swig/*
tar -xf swig.zip -C swig
mv swig/swigwin-4.1.1/* swig
rm -rf swig/swigwin-4.1.1
$env:PATH += ";$pwd/swig"

cd ..

# $pythonIncludeDIR = $(python -c "import sysconfig; print(sysconfig.get_path('include'))")
# $pythonLibDIR = $(python -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))")
# echo $pythonIncludeDIR
# echo $pythonLibDIR

# $openblasRoot = "$pwd/vendors/openblas"
$openblasRoot = "../vendors/openblas"

cd faiss

# cmake -B build . -G "MinGW Makefiles" -DCMAKE_CXX_FLAGS="-std=c++20 -fpermissive" -DLAPACK_LIBRARIES="openblas" -DBLAS_LIBRARIES="openblas" -DBLA_VENDOR=OpenBLAS -DFAISS_ENABLE_GPU=OFF -DFAISS_ENABLE_PYTHON=OFF -DBUILD_SHARED_LIBS=ON -DFAISS_ENABLE_C_API=ON -DBUILD_TESTING=OFF
# cmake -B build . -DCMAKE_CXX_FLAGS="/EHsc" -DLAPACK_LIBRARIES="openblas" -DBLAS_LIBRARIES="openblas" -DPython_EXECUTABLE="D:/dev/pcbangstudio/tools/langs/python3" -DBLA_VENDOR=OpenBLAS -DFAISS_ENABLE_GPU=ON -DFAISS_ENABLE_PYTHON=ON -DBUILD_SHARED_LIBS=ON -DFAISS_ENABLE_C_API=ON -DBUILD_TESTING=OFF
# cmake -B build . -DCMAKE_CXX_FLAGS="/EHsc" -DLAPACK_LIBRARIES="openblas" -DBLAS_LIBRARIES="openblas" -DBLA_VENDOR=OpenBLAS -DFAISS_ENABLE_GPU=ON -DFAISS_ENABLE_PYTHON=ON -DBUILD_SHARED_LIBS=ON -DFAISS_ENABLE_C_API=ON -DBUILD_TESTING=OFF -DPYTHON_INCLUDE_DIR=$pythonIncludeDIR -DPYTHON_LIBRARY=$pythonLibDIR
cmake -B build . -DCMAKE_PREFIX_PATH="$openblasRoot/lib" -DCMAKE_CXX_FLAGS="/EHsc" -DLAPACK_LIBRARIES="$openblasRoot" -DBLAS_LIBRARIES="$openblasRoot" -DBLA_VENDOR=OpenBLAS -DFAISS_ENABLE_GPU="$useGPU" -DFAISS_ENABLE_PYTHON="$enablePython" -DBUILD_SHARED_LIBS="$createDLL" -DFAISS_ENABLE_C_API="ON" -DBUILD_TESTING=OFF
cd build

cp -f ../$openblasRoot/lib/libopenblas.lib faiss/openblas.lib

cmake --build . --config Release
cd ..
