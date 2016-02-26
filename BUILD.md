BUILD INSTRUCTIONS
==================

LOCAL INSTALLATION
------------------

By default, the CLI will be installed under ```$HOME```. To change this, edit ```PREFIX``` in Makefile.

Run the following command(s)

```module load git```

```make && make install```

Ensure that ```cyverse-cli/bin``` is in your PATH.  See [INSTALL INSTRUCTIONS](../INSTALL.md) for how to do this. 

BUILDING A RELEASE
------------------

1. Increment the version number in ```VERSION```
2. Edit ```CHANGELOG.md``` to reflect new version and date; added, updated, removed capabilities
3. Run the following commands

```
_VERSION=$(echo -n $(cat VERSION))
make clean
make dist
make clean
git commit -a -m "Building release ${_VERSION}"
git tag -a "v${_VERSION}" -m "version ${_VERSION}"
git push origin "v${_VERSION}"
git push origin master

# Docker
make docker
make docker-release
```
