# Agave CLI Bash Completion

This script provides completion of:
 - commands and their options
 - filepaths
 - search terms & operators

## Installation 

To enable the completions either:  

> place this file in `/etc/bash_completion.d`

or  

> copy this file to e.g. ~/.agave-completion.sh and add the line below to your .bashrc after bash completion features are loaded `. ~/.agave-completion.sh`  

## Configuration

For several commands, the amount of completions can be configured by setting environment variables. This is generally helpful when calls to fetch remote directory listings slow down the responsiveness of the CLI. 

```
AGAVE_CLI_COMPLETION_SHOW_FILE_PATHS
AGAVE_CLI_COMPLETION_SHOW_FILE_IMPORTS  
AGAVE_CLI_COMPLETION_SHOW_JOB_OUTPUTS_PATHS  
  "no"  - Disable autocomplete (default)
  "yes" - Autocomplete file and folder names
```

You can also enable completion caching to speed up frequent interactions with the CLI. Completion caching is controlled on a service-by service basis through environment variables. Completion caching does not reflect the request/response from the actual CLI calls. Each service's completion cache is stored separately from the cli response cache and managed independently.
  
```
AGAVE_CLI_COMPLETION_CACHE_APPS
AGAVE_CLI_COMPLETION_CACHE_CLIENTS
AGAVE_CLI_COMPLETION_CACHE_FILES
AGAVE_CLI_COMPLETION_CACHE_JOBS
AGAVE_CLI_COMPLETION_CACHE_METADATA
AGAVE_CLI_COMPLETION_CACHE_MONITORS
AGAVE_CLI_COMPLETION_CACHE_NOTIFICATIONS
AGAVE_CLI_COMPLETION_CACHE_POSTITS
AGAVE_CLI_COMPLETION_CACHE_PROFILES
AGAVE_CLI_COMPLETION_CACHE_SYSTEMS
AGAVE_CLI_COMPLETION_CACHE_TAGS
AGAVE_CLI_COMPLETION_CACHE_TENANTS
AGAVE_CLI_COMPLETION_CACHE_TRANSFERS
AGAVE_CLI_COMPLETION_CACHE_TRANFORMS
  "no"  - Disable autocomplete (default)
  "yes" - Autocomplete file and folder names
```

You can configure the lifetime (seconds) of all caches globally using environment variables.

```  
AGAVE_CLI_COMPLETION_CACHE_LIFETIME
    "" - No value, defaults to 60 (1 hour)
     0 - Disables cache (default)
   > 0 - Number of minutes before cache invalidates
```
