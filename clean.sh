cd faiss
git restore .
cd ..

if [ "$1" = "all" ]; then
    rm -rf ./build_lin
fi
