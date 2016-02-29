# Change Log
All notable changes to this project will be documented in this file.

## Version 1.0.8 - 02/15/2016
### Added
* iplantc/cyverse-cli:1.0.8 released to Dockerhub

### Changed
* Substantial updates to docs reflecting state of Agave API at Cyverse
* Fixed Docker image cache directory amnesia
* Fixed broken cyverse-sdk-info

### Removed
* Nothing

## Version 1.0.7 - 02/15/2016
### Added
* Nothing

### Changed
* Fixed virtual rootDir for storage and compute systems at TACC
* Pinned executionSystem logins to specific login node on each system

### Removed
* Nothing

## Version 1.0.6 - 02/14/2016
### Added
* Nothing

### Changed
* Removed support for cyverse-sdk-info in Makefile

### Removed
* cyverse-sdk-info (for now)

## Version 1.0.5 - 02/13/2016
### Added
* Nothing

### Changed
* Added check for empty values in tacc-systems-create
* Added check for BSD vs Linux sed in Makefile
* Renamed cyverse-cli-info to cyverse-sdk-info
* Fixed an issue where TMPDIR was not defined in tacc-systems-create

### Removed
* Nothing

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
