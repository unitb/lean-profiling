#!/bin/sh

REPO=https://github.com/unitb/temporal-logic
NEW_BRANCH=faster-intros
OLD_BRANCH=master
git clone $REPO old
git clone $REPO new

# Run benchmark on old
pushd old
git checkout $OLD_BRANCH
cp ../Makefile .
make clean
leanpkg configure
leanpkg test
# lean test/benchmark.lean --profile --test-suite
make profile
grep -R . -e "% *temporal\\." --include ".*\\.out" > report.txt
stack runghc src/collate.hs
popd

# Run benchmark on new
pushd new
git checkout $NEW_BRANCH
cp ../Makefile .
make clean
leanpkg configure
leanpkg test
# lean --make src --profile --test-suite
make profile
grep -R . -e "% *temporal\\." --include ".*\\.out" > report.txt
stack runghc src/collate.hs
popd
