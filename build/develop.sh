#!/bin/bash

cp VERSION VERSION.bak
echo "edge" > VERSION

_VERSION="$(echo -n $(cat VERSION))"
make clean
make dist
make clean

git commit -a -m "Building release ${_VERSION}"
git tag -a "v${_VERSION}" -m "version ${_VERSION}"
git push origin "v${_VERSION}"
git push origin master

make docker
make docker-release

mv VERSION.bak VERSION
