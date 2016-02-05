BUILD INSTRUCTIONS
==================

LOCAL INSTALLATION
------------------

1. Run the following command(s)

By default, the CLI will be installed under ```$HOME```. To change this, edit ```PREFIX``` in Makefile.

```make && make install```

2. Ensure the ```cyverse-cli/bin``` are in your PATH

BUILDING A RELEASE
------------------

1. Increment the version number in ```VERSION```
2. Edit ```CHANGELOG.md``` to reflect new version and date; added, updated, removed capabilities
3. Run the following commands

```
_VERSION=$(echo -n $(cat VERSION))
make clean
make dist
git commit -a -m "Building release ${_VERSION}"
git tag -a "v${_VERSION}" -m "version ${_VERSION}"
git push origin "v${_VERSION}"

docker build -t iplantc/cyverse-cli .
docker tag iplantc/cyverse-cli iplantc/cyverse-cli:${_VERSION}
docker push iplantc/cyverse-cli:${_VERSION}
```
