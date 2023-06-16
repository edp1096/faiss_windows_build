rm -rf faiss/build
git restore faiss

if ($args[0] -eq "all") {
    rm -rf vendors/build
    rm -rf vendors/openblas
    rm -f vendors/openblas.zip
    rm -rf vendors/swig
    rm -f vendors/swig.zip
}
