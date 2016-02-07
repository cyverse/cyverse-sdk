# Change Log
All notable changes to this project will be documented in this file.

## Version 1.0.4 - 02/07/2016
### Added
* docker-clean make target in Makefile

### Changed
* cyverse-cli image now contains python 2.7.11 (or higher) to support JSON parsing
* updated BUILD to reflect docker-specific make targets

### Removed
* Nothing

## Version 1.0.3 - 02/07/2016
### Added
* Completed Docker support with addition of docker and docker-release make targets
* jsonpki command for serializing private and public keys

### Changed
* Nothing

### Removed
* Nothing

## Version 1.0.2 - 02/05/2016
### Added
* cyverse-cli-info command to report API, tenant, etc
* Support for TACC global WORK storageSystem
* Support for Lonestar5 executionSystem


### Changed
* Fork of iplant-agave-sdk, placed under active version management
* Fixed installation instructions

### Removed
* Support for Lonestar4 executionSystem
* Support for Wrangler executionSystem (will return soon)
