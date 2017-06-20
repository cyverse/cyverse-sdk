# Change Log
All notable changes to this project will be documented in this file.

## 2.1.9.0 - 2016-10-14
### ADDED
- `uuid-lookup` script to resolve generic uuid and optionally return the full object representation. Relies on the beta `/uuids` API.

### FIXED
- Fixed parsing issue in `requestbin-create` and `systems-history` scripts
- Fixed `jobs-template` and added logic to make it more forgiving when a user profile does not resolve or an input has a null default value.

### REMOVED
- No changes.


## 2.1.8.1 - 2016-07-13
### ADDED
- `Dockerfile` to build a minimal image with embedded webhook server written in Golang and `ngrok.com` reverse tunnel for local webhook inspection behind a proxy. 

### FIXED
- Fixed a bug in `systems-roles-addupdate` where the curl statement was misprinting.

### REMOVED
- No changes.


## 2.1.8 - 2016-06-13
### ADDED
- `jobs-kick` command to roll a job back to its previous status and retry processing from there.
- Added search support to the `monitors-checks-list` command.
- Added support for specify custom notification delivery retry policy in the `notifications-addupdate` script.
- Adding support for strict validation of inputs and paramters in the `jobs-resubmit` script. You can now use the `-I` and `--strictinputs` to enforce strict reproducibility on the submissi    on syntax and `-P` and  `--strictparams` to enforce strict reproducibility on the input syntax. Thes allow you to shield yourself against changes to the app descriptions that would otherwise silently go through. 

### FIXED
- Fixed a bug in `monitors-addupdate` preventing json descriptions from being read from stdin.
- Fixed a bug where the veryverbose output of the `systems-list` script did not quote the url.

### REMOVED
- No changes.


## 2.1.5 - 2016-03-09
### ADDED
- No changes.

### FIXED
- Overhauled parameters and script docs for correctness and consistency.

### REMOVED
- No changes.

## 2.1.4 - 2015-09-14
### ADDED
- `*-search` Adding support for deep, sql style searching across first-class resources
- `files-output-list` and `jobs-list` now have -L option to print out file listing in unix-y format
- `systems-queues-*` commands for crud actions on system queues.

### FIXED
- Fixed random typos in error messages.
- All `*-search` commands now properly url-encoded serach terms.
- Exit code on errors is now returned as 1.
- Fixed parameter-based notifications creation.
- Fixing bug in auth-switch command preventing dev and primary url from being set properly.

### REMOVED
- No changes.

## 2.1.0 - 2015-02-23
### ADDED
- `*-addupdate` Adding support for reading from stdin to all the scripts that previously accepted only files by replacing the file name with `-`
- `jobs-template` adding webhook url with [Agave RequestBin](http://requestbin.agaveapi.co/) valid for 24 hours created on each request.
- `jobs-template` added support for parsing most enum values, properly creating arrays vs primary types based on min and max cardinality, and the ability to populate with random default values, including inputs

### FIXED
- Fixed existence check on all commands accepting files/folder inputs.

### REMOVED
- No changes.


## 2.1.0 - 2015-02-22
### ADDED
- `files-publish` script providing a single command to upload a file/folder and create a public PostIt URL that can be shared. All arguments of the `files-upload` and `postits-create` commands are supported.
- `jobs-output-list` script replaces the default directory listing behavior of the `jobs-output` command.
- `jobs-output-get` script replaces the download behavior of the `jobs-output` command. This script supercedes the previous command by adding recursive directory downloads, range query support, and optional printing to standard out.

### FIXED
- No changes.

### REMOVED
- `jobs-output` has been deprecated and now delegates all calls to the `jobs-output-list` and `jobs-output-get` commands.


## 2.0.0 - 2014-12-10
### ADDED
- `clients-create` Broke client JSON into individual command line arguments.
- `tenants-init` Added ability to specify tenant by id or name.

### FIXED
- `tenants-init` Fixed a bug where the tenant id given at the command line was not being recognized.

### REMOVED
- No changes.
