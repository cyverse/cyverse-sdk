## Agave CLI Test Suite

This is the test suite for the Agave CLI. It is a work in progress. Please consider contributing tests to help expand coverage.

### Requirements

These test rely upon the [Bash Automated Testing System (Bats)](https://github.com/sstephenson/bats). Bats is a TAP-compliant testing framework for Bash. For more information on Bats, please see the project's [wiki page](https://github.com/sstephenson/bats/wiki).

You can install Bats using your favorite package manager. Instructions are provided on the [Bats installation](https://github.com/sstephenson/bats/wiki/Install-Bats-Using-a-Package) page. 

```
# Ubuntu/Debian
sudo apt-get install bats

# CentOS/RHEL
sudo yum install bats

# OSX
brew install bats
```  

### Running

To run the entire test suite, point Bats at the `test` folder. 

```
bats test/bin/*
``` 

To run tests for individual commands, run the `<command>.bat` file for the command you care about.
 
```
# run tests for just the tenants-list command
bats test/tenants-list.bat

# run tests for the apps-search and jobs-search commands
bats test/apps-search.bat test/jobs-search.bat

# run tests for all the jobs-* commands
bats test/jobs-*
```  

### Test data

Some tests require valid compute and data resources to properly run. In these situations, the CLI tests will attempt use your default compute and storage systems. If you do not have any default compute and storage systems defined, the tests will attempt to start up a docker container locally and use that as a sandbox system. You can override this behavior by defining your own system definitions in `test/data/storage.json` and  `test/data/compute.json`.
 
