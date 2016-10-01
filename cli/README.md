## What is the Agave Platform?

The Agave Platform ([http://agaveapi.co](http://agaveapi.co)) is an open source, science-as-a-service API platform for powering your digital lab. Agave allows you to bring together your public, private, and shared high performance computing (HPC), high throughput computing (HTC), Cloud, and Big Data resources under a single, web-friendly REST API.

* Run scientific codes

	*your own or community provided codes*

* ...on HPC, HTC, or cloud resources

	*your own, shared, or commercial systems*

* ...and manage your data

	*reliable, multi-protocol, async data movement*

* ...from the web

	*webhooks, rest, json, cors, OAuth2*

* ...and remember how you did it

	*deep provenance, history, and reproducibility built in*

For more information, visit the [Agave Developer’s Portal](http://agaveapi.co) at [http://agaveapi.co](http://agaveapi.co).


## What is the Agave CLI

The Agave CLI is a collection of Bash shell scripts allowing you to interact with the Agave Platform. The CLI allows you to streamline common interactions with the API and automating repetative and/or background tasks.


## Installation from source

The following dependencies are required to use the Agave API cli tools.

	* bash 4.2.50+
	* curl 7.19.7+
	* python 2.7.9+

Optional dependencies

	* jq 1.4+ (for faster JSON parsing)

Clone the repository from Bitbucket and add the bin directory to your PATH and you're ready to go.

	git clone https://bitbucket.org/taccaci/foundation-cli.git agave-cli
	export PATH=$PATH:`pwd`/agave-cli/bin

## Getting started

From here on, we assume you have the CLI installed and your environment confired properly. We also assume you either set or will replace the following environment variables:

* `AGAVE_USERNAME`: The username you use to login to Agave for your organization.
* `AGAVE_PASSWORD`: The password you use to login to Agave for your organization.


### Configuring your enviornment

Prior to using the CLI, you will need to initialize your environment using the `tenants-init` command and selecting your organization from the list. This is a one-time process that sets the proper URL base path for your tenant and stores it in a cache file on your system. You can configure the location of the authentication cache by setting the `AGAVE_CACHE_DIR` environment variable. The default location is `/root/.agave`.

	bash-4.1# tenants-init --tenant 1


### Getting your API keys

In order to communicate with Agave, you will need a set of API keys. You can use the `clients-create` command to create a set.

	bash-4.1# clients-create -N cli_client -D "Just a test api client" -u "$AGAVE_USERNAME" -p "$AGAVE_PASSWORD" -S

The `-S` option will save your api keys in your session cache directory, `AGAVE_CACHE_DIR`.


### Authentication

Authentication with the API is done via OAuth2. The CLI will handle the authentication flow for you. Simply run the `auth-tokens-create` command and supply your client key, secret, and username & password and a bearer token will be retrieved from the auth service. Alternatively, you can specify a bearer token at the command line by providing the `-z` or `--access_token` option. If you would like to store a token for repeated use so you don't have to keep reauthenticating with every call, run the `auth-tokens-create` script with the `-S` option to store the token locally for future use.

	bash-4.1# auth-tokens-create -S -u "$AGAVE_USERNAME" -p "$AGAVE_PASSWORD"

Accept the default values, which will hold the API keys you created in the last step. Once this returns, you will be authenticated and ready to use the Agave CLI.

If your auth token expires, you can refresh it rather than pulling a new one.

	bash-4.1# auth-tokens-refresh -S

Again, accept the default values, which will hold the API keys you created in the last section and the refresh token you received when you first authenticated.


### Using the CLI

The Agave CLI is broken down into the following groups of scripts

	- apps*           query and register applications
	- auth*           authenticate
	- clients*        create and manage your API keys
	- files*          manage remote files and folders, upload data
	- jobs*           submit and manage jobs
	- metadata*			  create and manage metadata
	- monitors*			  create and manage system monitors
	- notifications*  create and manage notifications
	- postits*        create preauthenticated, disposable urls
	- profiles*       query and register users
	- systems*        query, monitor, and manage systems
	- tenants*        query and initialize the CLI for your tenant
	- transforms*     move data from one location to another

All commands follow a common syntax and share many of the same flags `-h` for help, `-d` for debug mode, `-v` for verbose output, `-V` for very verbose (prints curl command and full service response), and `-i` for interactive mode. Additionaly, individual commands will have their own options specific to their functionality. The general syntax all commands follow is:

	<command> [-hdv]
	<command> [-hdv] [target]
	<command> [-hdv] [options] [target]

Each command has built in help documentation that will be displayed when the `-h` flag is specified. The help documentation will list the actions, options, and targets available for that command.

### Configuring custom JSON parsers

The CLI comes bundled with two different JSON parsers. Additionally, tthree other parsers are supported. To specify your preferred parser, set the `AGAVE_JSON_PARSER` environment variable to one of values in the following list. If no value is selected, the python parser will be used if python is available, otherwise the json-mirror API will be used.

* `python`: The Python parser is a lightweight script written for Python 2.6+. It requires the `json` module be installed (which should come standard in 2.7+). Nothing needs to be done to use this module, but you do need to have Python installed. Window users may want to consider using the `json-mirror` option instead.
* `jq`: [jq](https://stedolan.github.io/jq/) is a command line utility written in C. It is fast, powerful, and has an extremely small memory footprint. jq has binary installers for every majory platform as well as mostly portable build. It must be installed separately.
* `json`: The [JSON Tool](http://trentm.com/json/) is a command line utility written in NodeJS. It is fast, friendly, and works out of the box. It must be installed separately and requires a Node runtime be present on the system.
* `native`: This is the native Bash implementation from the [json.sh](https://github.com/dominictarr/JSON.sh) project. It is quite a bit slower than the Python implementation and does have trouble with newline characters from time to time. That being said, it's pretty awesome for a pure Bash JSON parser.
* `json-mirror`: The [Agave JSON Mirror API](https://bitbucket.org/taccaci/agave-json-mirror) is a publicly available, free API which provides JSON pretty printing and JavaScript style dot notation querying of. It is a suitable replacement for basic java manipulation and formatting.

>  For a 100% bash CLI with no dependencies, use the `json-mirror` parser. That will force the CLI to call out to the [Agave JSON Mirror API](https://bitbucket.org/taccaci/agave-json-mirror) at http://agaveapi.co/json-mirror and avoid any python dependencies.