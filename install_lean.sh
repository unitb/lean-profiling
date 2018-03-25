#!/bin/sh

git clone https://github.com/leanprover/lean
cd lean
git fetch origin
git checkout $1
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_CXX_COMPILER=$CMAKE_CXX_COMPILER -DTCMALLOC=$TCMALLOC -DMULTI_THREAD=$MULTI_THREAD -DSTATIC=$STATIC -DLEAN_EXTRA_MAKE_OPTS=$LEAN_EXTRA_MAKE_OPTS ../src || exit
make -j2 || exit
export PATH=$HOME/lean/bin:$PATH
