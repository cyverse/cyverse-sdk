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


## Using this image

The CLI is a set of interactive scripts. You can run them individually by running a separate container each time, or via an interactive terminal session.

```
$ docker run -it --rm agaveapi/agave-cli
```  
  
You need to initialize your environment prior to using the CLI. This will create a cache file holding your session authentication info, api keys, and API endpoints. Rather than repeat this every time you run the container, we recommend creating a local directory to hold the cache info and attaching it as a volume.

```
$ docker run -it --rm -v `$HOME`/.agave:/agave agaveapi/agave-cli  
```    
  
## Getting started

From here on, we assume you are running an interactive container with the following command. All future commands are given inside the container's interactive shell. We will start the container with a local cache directory attached as a volume.

```
docker run -it --rm -v `$HOME`/.agave:/agave agaveapi/agave-cli  
```  
  
We assume you either set or will replace the following environment variables:  

* `AGAVE_USERNAME`: The username you use to login to Agave for your organization.  
* `AGAVE_PASSWORD`: The password you use to login to Agave for your organization.  


### Configuring your enviornment

Prior to using the CLI, you will need to initialize your environment using the `tenants-init` command and selecting your organization from the list. This is a one-time process that sets the proper URL base path for your tenant and stores it in a cache file on your system. You can configure the location of the authentication cache by setting the `AGAVE_CACHE_DIR` environment variable. The default location is `/agave`.  
  
```
$ tenants-init --tenant agave.prod  
```  
  
### Getting your API keys

In order to communicate with Agave, you will need a set of API keys. You can use the `clients-create` command to create a set.  

```
client-create -N cli_client -D "Just a test api client" -u "$AGAVE_USERNAME" -p "$AGAVE_PASSWORD" -S  
```  
  
The `-S` option will save your api keys in your session cache directory, `AGAVE_CACHE_DIR`.  


### Authentication

Authentication with the API is done via OAuth2. The CLI will handle the authentication flow for you. Simply run the `auth-tokens-create` command and supply your client key, secret, and username & password and a bearer token will be retrieved from the auth service. Alternatively, you can specify a bearer token at the command line by providing the `-z` or `--access_token` option. If you would like to store a token for repeated use so you don't have to keep reauthenticating with every call, run the `auth-tokens-create` script with the `-S` option to store the token locally for future use.  

```
$ auth-tokens-create -u "$AGAVE_USERNAME" -p "$AGAVE_PASSWORD"  
```  
  
Accept the default values, which will hold the API keys you created in the last step. Once this returns, you will be authenticated and ready to use the Agave CLI.

If your auth token expires, you can refresh it rather than pulling a new one.  

```
$ auth-tokens-refresh  
```  
  
Again, accept the default values, which will hold the API keys you created in the last section and the refresh token you received when you first authenticated.

### Using the CLI

The Agave CLI is broken down into the following groups of scripts

  - apps*           query and register applications
  - auth*           authenticate
  - clients*        create and manage your API keys
  - events*         search default events, create and manage your own
  - files*          manage remote files and folders, upload data
  - jobs*           submit and manage jobs
  - metadata*		create and manage metadata
  - monitors*		create and manage system monitors
  - notifications*  create and manage notifications
  - requestbin*     create requestbins for use as webhook targets
  - postits*        create preauthenticated, disposable urls
  - profiles*       query and register users
  - realtime*       subscribe to websocket and streaming http event feeds
  - systems*        query, monitor, and manage systems
  - tags*           create and manage tags
  - tenants*        query and initialize the CLI for your tenant
  - transforms*     move data from one location to another

All commands follow a common syntax and share many of the same flags `-h` for help, `-d` for debug mode, `-v` for verbose output, `-V` for very verbose (prints curl command and full service response), and `-i` for interactive mode. Additionaly, individual commands will have their own options specific to their functionality. The general syntax all commands follow is:  

```
<command> [-hdv]  
<command> [-hdv] [target]  
<command> [-hdv] [options] [target]  
```  
  
Each command has built in help documentation that will be displayed when the `-h` flag is specified. The help documentation will list the actions, options, and targets available for that command.  

### Testing webhooks

The Agave CLI image comes bundled with a simple web server written in GoLang that logs all requests it receives. This is useful for testing webhook responses from Agave. To work around issues associated with firewalls, dynamic ips, and NATs, a free [ngrok](https://ngrok.com/) client is also configured in the container. Theses two components are sufficient to allow you to receive webhooks from Agave on your local machine, or where ever the Agave CLI container is running. 

To start the tunnel, call the `tunnelup.sh` command.  

```
$ tunnelup.sh
Starting an Agave HttpMirror server...done
Starting a ngrok client.............done
#############################################################
# A http mirror server has been started and published at: 
#
#   http://ca50321d.ngrok.io 
#
# All webhooks sent to that url will be logged at: 
#
#   /usr/local/agave-cli/http/log/httpmirror.log 
#
# Run these commands to configure your environment: 
#
#   export WEBHOOK_LOG=/usr/local/agave-cli/http/log/httpmirror.log 
#   export WEBHOOK_URL=http://ca50321d.ngrok.io 
#############################################################
```  
  
To stop the tunnel, call the `tunneldown.sh` command.  

```
$ tunneldown.sh  
Stopping HttpMirror server 20...  
Stopping ngrok client 21...  
```  
  
If you forget your container's published ngrok url, you can retrieve it via the `ngrok_url` alias.  

```
$ ngrok_url  
http://ca50321d.ngrok.io    
```  
  