#!/bin/sh

REPO=https://github.com/unitb/temporal-logic
OLD_BRANCH=master
BRANCHES="$OLD_BRANCH faster-intros still-faster-intros"
for br in $BRANCHES
do
    git clone $REPO "$br"
done
lean || ./install_lean.sh $(cat $OLD_BRANCH/lean_version)
for br in $BRANCHES
do
    pushd "$br"
    git fetch origin
    git checkout $br
    leanpkg configure
    leanpkg test &
    popd
done
wait

# Run benchmark on old
for br in $BRANCHES
do
    pushd "$br"
    cp ../Makefile .
    cp ../collate.hs .
    cp -f ../benchmark.lean test/
    make clean
    make profile -j4 -l 5
    # make test/benchmark.lean.test_suite.out
    popd
done
wait
for br in $BRANCHES
do
    pushd "$br"
    grep -R . -e "% *temporal\\." --include ".*\\.out" > report.txt &
    popd
done
wait
for br in $BRANCHES
do
    pushd "$br"
    stack runghc collate.hs
    popd
done

# mkdir "$NEW_BRANCH vs $OLD_BRANCH"
# mv "$OLD_BRANCH" "$NEW_BRANCH vs $OLD_BRANCH/$OLD_BRANCH"
# mv "$NEW_BRANCH" "$NEW_BRANCH vs $OLD_BRANCH/$NEW_BRANCH"
