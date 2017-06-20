#!/bin/bash
#
# common.sh
#
# author: dooley@tacc.utexas.edu
#
# Common helper functions and global variables for all cli scripts.
# A lot of this is based on options.bash by Daniel Mills.
# @see https://github.com/e36freak/tools/blob/master/options.bash

# init the parent directory variable if not already present
# this is needed when sourcing this script directly from
# outside the CLI scripts.
if [[ -z "$DIR" ]]; then
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

# add keyvalue support
source $DIR/kv-bash

# update the old cache to the new key-value format if present
if [ -f "$HOME/.agave" ]; then
  oldcache=$(cat $HOME/.agave)
  rm $HOME/.agave
  mkdir $HOME/.agave
  kvset current "$oldcache"
fi

# Preamble {{{

# Exit immediately on error
#set -e -x

# Detect whether output is piped or not.
[[ -t 1 ]] && piped=0 || piped=1

# versioning info
version="v2"
release="2.1.10"
revision=""
if [ -e "$DIR/../.git" ];
then
  revision=$(git --git-dir=$DIR/../.git rev-parse --short HEAD)
  if [[ -n "$revision" ]];
  then
    revision="${version}-r$revision"
  elif [ -e "$DIR/../.git/refs/heads/master" ];
  then
    revision="${version}-r$(git --git-dir=$DIR/../.git rev-parse --short HEAD)"
  else
    revision="${version}"
  fi
else
  revision="${version}"
fi

# Determine which flavor of awk is being used (e.g. GNU gawk or BSD nawk)
awk=$(awk -Wversion &>/dev/null && echo gawk || echo nawk)

os=`uname -s`;

# Defaults
force=0
quiet=0
verbose=0
veryverbose=0
interactive=0
rich=0
development=$( (("$AGAVE_DEVEL_MODE")) && echo "1" || echo "0" )

disable_cache=0 # set to 1 to prevent using auth cache.
args=()

# Configure which json parser to use
if [[ -z "$AGAVE_JSON_PARSER" ]]; then
	# If no parser is specified, look for python in the local path
	# and fall back on the native json.sh implementation.
#	if hash python 2>/dev/null; then
#		AGAVE_JSON_PARSER='python'
#	else
		AGAVE_JSON_PARSER='native'
#	fi
fi

# }}}
# Helpers {{{

function out() {
  ((quiet)) && return

  local message="$@"
  #if ((piped)); then
  #  message=$(echo $message | sed '
  #    s/\\[0-9]\{3\}\[[0-9]\(;[0-9]\{2\}\)\?m//g;
  #    #s/✖/Error:/g;
  #    #s/✔/Success:/g;
  #  ')
  #fie
  if (( pipe )); then
  	echo "$@"
  else
  	printf '%b\n' "$message";
  fi
}
function die() { out "$@"; exit 1; } >&2
function err() {
	if [[ -n $(ishtmlstring "$response") ]]; then
		response=$(get_html_message "$response")
		response=`json_prettyify $(to_json_error_message "$response")`
	elif [[ -n $(isxmlstring "$response") ]]; then
		response=$(get_xml_message "$1")
		response=`json_prettyify $(to_json_error_message "$response")`
	else
		response=$@
	fi

	if (($verbose)); then
		if ((piped)); then
		  	die "${response}"
		else
		  	die "\033[1;31m${response}\033[0m"
		fi
	else
		if ((piped)); then
			die "$@"
		else
			die "\033[1;31m${@}\033[0m"
		fi
	fi
} >&2

function success() {
  if ((piped)); then
    out "$@"
  else
	#message=$(echo "$@" | sed 's/\\[0-9]\{3\}\[[0-9]\(;[0-9]\{2\}\)\?m//g')
	out "\033[1;0m$@\033[0m";
  fi

}

function version() {
	out "iPlant Agave API ${release}
Agave CLI (revision ${revision})
"
}

function copyright() {
	out "Copyright (c) 2013, Texas Advanced Computing Center
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the University of Texas at Austin nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS AS IS
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"
}

function disclaimer() {
	out "Documentation on the Agave API, client libaries, and developer tools is
available online from the Agave Website, http://developer.agaveapi.co. For
localized help of the various CLI commands, run any command with the -h
or --help option.
"
}

# Verbose logging
function log() { (($verbose)) && out "$@"; }

# Notify on function success
function notify() { [[ $? == 0 ]] && success "$@" || err "$@"; }

# Escape a string
function escape() { echo $@ | sed 's/\//\\\//g'; }

# Unless force is used, confirm with user
function confirm() {
  (($force)) && return 1;

  read -p "$1 [Y/n] " -n 1;
  [[ $REPLY =~ ^[Yy]$ ]];
}

# Set a trap for cleaning up in case of errors or when script exits.
function rollback() {
	stty echo
	die
}

function getIpAddress() {
    curl http://myip.dnsomatic.com
}

function jsonval {
	local __resultvar=$1
	local __temp=`echo "$2" | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $3| cut -d":" -f2| sed -e 's/^ *//g' -e 's/ *$//g'`
	eval $__resultvar=`echo '${__temp##*|}'`
}

function ishtmlstring {
	if [[ -n "$1" ]]; then
		firstelement=${1:0:5}
		if [[ "$firstelement" = "<html" ]] || [[ "$firstelement" = "<!DOC" ]]; then
			echo 1
		fi
	fi
}

function isxmlstring {
	if [[ -n "$1" ]]; then
		if hash xmllint 2>/dev/null; then
			xmllint - >> /dev/null 2>&1 <<< "$1"
			[ $? -eq 0 ] && echo 1
		else
			firstcharacter=$(trim "$1")
			firstcharacter=${firstcharacter:0:1}
			[ "$firstcharacter" = '<' ] && echo 1
		fi
	fi
}

function get_html_message() {
  if [[ -n $(echo "$1" | grep "<title") ]]; then
    echo "$1" | grep -om1 "<title>[^<]*" | sed -e 's/<title>//'
  elif [[ -n $(echo "$1" | grep "<p") ]]; then
    echo "$1" | grep -om1 "<p>[^<]*" | sed -e 's/<p>//'
  else
		echo "Unexpected response from the API server."
	fi
}

function get_xml_message() {
  #set -x
	if [[ -n $(echo "$1" | grep -om1 "<ams:message>[^<]*") ]]; then
		echo "$1" | grep -om1 "<ams:message>[^<]*" | sed -e 's/<ams:message>//'
	elif [[ -n $(echo "$1" | grep -om1 "<am:description>[^<]*") ]]; then
		echo "$1" | grep -om1 "<am:description>[^<]*" | sed -e 's/<am:description>//'
  elif [[ -n $(echo "$1" | grep "<title") ]]; then
    echo "$1" | grep -om1 "<title>[^<]*" | sed -e 's/<title>//'
  else
		echo "$1"
	fi
  #set +x
}

function to_json_error_message() {
	printf '{"status":"error","message":"%s","result":null}' "$(echo "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\"/g')"

	#printf '{"status":"error","message":"%s","result":null}' "$1"
#	echo "{\"status\":\"error\",\"message\":\"${1}\",\"result\":null}"
#	response=`echo "$jsonresponsemessage" | python -mjson.tool`


}

function trim() {
	local var="$*"
	var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
	var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
	echo -n "$var"
}

# Adds the pagination params to each curl call by checking and formatting the url query
# values associated with the $limit, $offset, and $filter variables common to all scripts.
function pagination {

	pagination=''
	re='^[0-9]+$'
	if [[ "$limit" =~ $re ]] ; then
		pagination="&limit=$limit"
	fi

	if [[ "$offset" =~ $re ]] ; then
		pagination="${pagination}&offset=$offset"
	fi

	if [[ -n "$responsefilter" ]]; then
		pagination="${pagination}&filter=$responsefilter"
	fi

	if [[ -n "$sortOrder" ]]; then
		pagination="${pagination}&order=$sortOrder"
	fi

	if [[ -n "$sortBy" ]]; then
		pagination="${pagination}&orderBy=$sortBy"
	fi

	echo $pagination
}

function jsonquery {
    # set -x
  	if [[ -z "$1" ]]; then
    	if [[ "$2" = "message" ]]; then
      		echo "Unable to contact api server at $hosturl"
    	fi
    elif [[ -n "$(echo $1 | grep '^{"fault":{"code"')" ]]; then
      if [[ "$2" = "message" ]]; then
        if (( $veryverbose )); then
				  echo "$1"
        else
          apimerr=$(echo "$1" | grep -om1 '"message":"[^"]*"' | sed -e 's/"message":"//' | sed -e 's/"//')
          echo "$apimerr"
        fi
      fi
  	elif [[ -n $(ishtmlstring "$1") ]]; then
		  if [[ "$2" = "message" ]]; then
			  if (( $veryverbose )); then
				  echo "$1"
			  else
          echo $(get_html_message "$1")
				  # echo "Unexpected response from the API server."
			  fi
		  fi
	  elif [[ -n $(isxmlstring "$1") ]]; then
	    if [[ "$2" = "message" ]]; then

			  echo $(get_xml_message "$1")

			# echo $(echo "$1" | grep -oPm1 "(?<=<ams:message>)[^<]+")

#			responsemessage=${1#*<ams:message>}
#			responsemessage=${responsemessage%</ams:message>*}
#			echo $responsemessage
		fi
	else
		# Look for custom json parsers
		if [[ -n "$AGAVE_JSON_PARSER" ]]; then

			if [[ 'json-mirror' == "$AGAVE_JSON_PARSER" ]]; then

				$DIR/json-mirror.sh "${1}" "$2" "$3"

			elif [[ 'jq' == "$AGAVE_JSON_PARSER" ]]; then

				jpath=".${2}"

				if [[ -n "$3" ]]; then

				        if [[ "$jpath" =~ \[\] ]]; then
						oIFS="$IFS"
						IFS="[]" read fbefore fmiddle fafter <<< "$jpath"
						IFS="$oIFS"
						unset oIFS
						fbefore_noperiod="${fbefore%?}"

						if [[ -z "$fbefore_noperiod" ]]; then
				                	echo "$1" | jq ".[] | $fafter"
						else
				                	echo "$1" | jq "$fbefore_noperiod | .[] | $fafter"
						fi
				        else
				                echo "$1" | jq "$jpath"
				        fi
				else

				        if [[ "$jpath" =~ \[\] ]]; then
						oIFS="$IFS"
						IFS="[]" read fbefore fmiddle fafter <<< "$jpath"
						IFS="$oIFS"
						unset oIFS
						fbefore_noperiod="${fbefore%?}"

						if [[ -z "$fbefore_noperiod" ]]; then
				                	echo "$1" | jq -r ".[] | $fafter"
						else
				                	echo "$1" | jq -r "$fbefore_noperiod | .[] | $fafter"
						fi
				        else
				                echo "$1" | jq -r "$jpath"
				        fi
				fi

			elif [[ 'json' == "$AGAVE_JSON_PARSER" ]]; then

				if [[ -n "$3" ]]; then

					if [[ "$2" =~ \[\] ]]; then
						oIFS="$IFS"
						IFS="[]" read fbefore fmiddle fafter <<< "$2"
						IFS="$oIFS"
						unset oIFS
						echo "$1" | json $fbefore | json -j -a $fafter
					else
						echo "$1" | json -j $2
					fi
				else

					if [[ "$2" =~ \[\] ]]; then
						oIFS="$IFS"
						IFS="[]" read fbefore fmiddle fafter <<< "$2"
						IFS="$oIFS"
						unset oIFS
						echo "$1" | json $fbefore | json -a $fafter
					else
						echo "$1" | json $2
					fi
				fi

			elif [[ 'python' == "$AGAVE_JSON_PARSER" ]]; then

				[[ -z "$3" ]] && stripquotes='-s'

				echo "${1}" | python $DIR/python2/pydotjson.py -q ${2} $stripquotes

			elif [[ 'native' == "$AGAVE_JSON_PARSER" ]]; then

				oIFS="$IFS"
				IFS="."
				declare -a fields=($2)
				IFS="$oIFS"
				unset oIFS
				#printf "> [%s]\n" "${fields[@]}"

				re='^[0-9]+$'

				for x in "${fields[@]}"; do
					if [ "$x" == '\*' ]; then
						patharray=${patharray}',"[^"]*"'
						escpatharray=${escpatharray}',*'
					#echo $patharray"\\n"
					elif [[ $x = '[]' ]]; then
						patharray=${patharray}',[0-9]+'
						escpatharray=${escpatharray}',[0-9]*'
					elif [[ $x =~ $re ]] ; then
						patharray=${patharray}','$x
						escpatharray=${escpatharray}','$x
					#echo $patharray"\\n"
					else
						patharray=${patharray}',"'$x'"'
						escpatharray=${escpatharray}',\"'$x'\"'
					#echo $patharray"\\n"
					fi
				done

				patharray="${patharray:1:${#patharray}-1}"
				escpatharray="${escpatharray:1:${#escpatharray}-1}"

				patharray='\['${patharray}'\]'
				escpatharray='\['${escpatharray}'\]'

				if [ -z "$3" ]; then
					echo "$1" | $DIR/json.sh -p | egrep "$patharray" | sed s/"$escpatharray"//g | sed 's/^[ \t]*//g' | sed s/\"//g
				else
					# third argument says to leave the response quoted
					echo "$1" | $DIR/json.sh -p | egrep "$patharray" | sed s/"$escpatharray"//g
				fi
				unset patharray
				unset escpatharray
			fi
		fi
	fi
}

# }}}

# Boilerplate {{{

# Prompt the user to interactively enter desired variable values.
function prompt_options() {
  local desc=
  local val=
  tokenstore=$(kvget current)
  # if [ ! -z "$(kvget current)" ]; then
	#   tokenstore=$(kvget current)
  # fi

  for val in ${interactive_opts[@]}; do

	# Skip values which already are defined
    [[ $(eval echo "\$$val") ]] && continue

    # Parse the usage description for spefic option longname.
    desc=$(usage | awk -v val=$val -v awk=${awk} '
      BEGIN {
        # Separate rows at option definitions and begin line right before
        # longname.
        RS="\n +-([a-zA-Z0-9], )|-";
        ORS=" ";
      }
      NR > 3 {
        # Check if the option longname equals the value requested and passed
        # into awk. Adjust for bsd awk vs gnu awk
        newval="--" val;
        # print os " " $2 " = " newval "\n"
        if ( awk == "nawk" ) {

        	if ($2 == newval) {
        		# Print all remaining fields, ie. the description.
				for (i=3; i <= NF; i++) print $i
        	}
        } else {
			if ($1 == val) {
				# Print all remaining fields, ie. the description.
				for (i=2; i <= NF; i++) print $i
			}
		}
      }
    ')

    [[ ! "$desc" ]] && continue

	#echo -n "$desc: "

	# In case this is a password field, hide the user input
    if [[ $val == "apikey" ]]; then
    	jsonval savedapikey "${tokenstore}" "apikey"
      if [[ -n "$force" ]]; then
        apikey=$savedapikey
      else
  	    echo -n "API key [$savedapikey]: "
      	eval "read $val"
      	if  [[ -z $apikey ]]; then
      		apikey=$savedapikey
      	fi
      	#stty -echo; read apikey; stty echo
      	#echo
      fi
    elif [[ $val == "refresh_token" ]]; then
    	jsonval savedrefreshtoken "${tokenstore}" "refresh_token"
      if [[ -n "$force" ]]; then
        refresh_token=$savedrefreshtoken
      else
        echo -n "Refresh token [$savedrefreshtoken]: "
      	eval "read $val"
      	if  [[ -z $refresh_token ]]; then
      		refresh_token=$savedrefreshtoken
      	fi
      	#stty -echo; read apikey; stty echo
      	#echo
      fi
    elif [[ $val == "apisecret" ]]; then
    	jsonval savedapisecret "${tokenstore}" "apisecret"
      if [[ -n "$force" ]]; then
        apisecret=$savedapisecret
      else
  		  echo -n "API secret [$savedapisecret]: "
      	eval "read $val"
      	if  [[ -z $apisecret ]]; then
      		apisecret=$savedapisecret
      	fi
      fi
    elif [[ $val == "username" ]]; then
    	jsonval savedusername "${tokenstore}" "username"
		  if [[ -n "$force" ]]; then
        username=$savedusername
      else
        echo -n "API username [$savedusername]: "
      	eval "read $val"
      	if  [[ -z $username ]]; then
        		username=$savedusername
      	fi
      fi
    elif [[ $val == "password" ]]; then
    	echo -n "API password: "
    	stty -echo; read "password"; stty echo
    	echo -n "
";
    elif [[ $val == "apipassword" ]]; then
    	echo -n "API password: "
    	stty -echo; read "apipassword"; stty echo
    	echo -n "
";
	# Otherwise just read the input
    else
    	echo -n "$desc: "
		eval "read $val"
    fi
  done
}

function get_auth_header() {
	if [[ "$development" -ne 1 ]]; then
		echo "Authorization: Bearer $access_token"
	else
		if [[ -f "$DIR/auth-filter.sh" ]]; then
		  echo $(source $DIR/auth-filter.sh);
		else
		  echo " -u \"${username}:${password}\" "
		fi
	fi
}

function get_token_remaining_time() {

	auth_cache=`kvget current`

	jsonval expires_in "$auth_cache" "expires_in"
	jsonval created_at "$auth_cache" "created_at"

  if [[ -z "$expires_in" ]] || [[ -z "$created_at" ]]; then
    echo 0
  else
    created_at=${created_at%.*}
	expires_in=${expires_in%.*}
	expiration_time=`expr $created_at + $expires_in`
  	current_time=`date +%s`

  	time_left=`expr $expiration_time - $current_time`

  	echo $time_left
  fi
}

function is_valid_url() {
	regex='(\b(https?|ftp|file)://)?[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]'
	if [[ "$1" =~ $regex ]]
	then
		echo 1
	fi
}

# load tenant-specific settings
calling_cli_command=`caller |  awk '{print $2}' | xargs -n 1 sh -c 'basename $0'`
currentconfig=$(kvget current)

if [[ "auth-switch" != "$calling_cli_command" ]] && [[ "tenants-init" != "$calling_cli_command" ]] && [[ "tenants-list" != "$calling_cli_command" ]]; then
  if [[ -z $currentconfig ]]; then
    err "Please run $DIR/tenants-init to initialize your client before attempting to interact with the APIs."
    exit
  fi

  baseurl=$(jsonquery "$currentconfig" "baseurl")
  if  [[ -z $baseurl ]]; then
    err "Please run $DIR/tenants-init to configure your client endpoints before attempting to interact with the APIs."
    exit
  else
    baseurl="${baseurl%/}"
  fi

  devurl=$(jsonquery "$currentconfig" "devurl")
  if [[ -n "$AGAVE_DEVURL" ]]; then
	devurl=${AGAVE_DEVURL%/}
  fi
  if [[ -n "$devurl" ]]; then
    devurl="${devurl%/}"
  fi

  tenantid=$(jsonquery "$currentconfig" "tenantid")
  if [[ -z "$tenantid" ]]; then
    err "Please run $DIR/tenants-init to configure your client id before attempting to interact with the APIs."
    exit
  fi
fi
# }}}

function join {
  local IFS="$1"; shift; echo "$*";
}

function json_prettyify {

	# Look for custom json parsers
	if [[ 'python' == "$AGAVE_JSON_PARSER" ]]; then

		echo "$@" | python $DIR/python2/pydotjson.py

	elif [[ 'jq' == "$AGAVE_JSON_PARSER" ]]; then

		echo "$@" | jq -r '.'

	elif [[ 'json' == "$AGAVE_JSON_PARSER" ]]; then

		echo "$@" | json

	# If all else fails, we can use the jsonparser api
	#elif [[ -z "$AGAVE_JSON_PARSER" -o 'json-mirror' == "$AGAVE_JSON_PARSER" ]]; then
	else
		jsonparserresponse=$(echo "${1}" | curl -sk --globoff -X POST -H "Content-Type: application/json" --data-binary @- "https://agaveapi.co/json-mirror?pretty=true")

		if [ $? ]; then
			echo -e "${jsonparserresponse}"
		else
			echo "$@"
		fi
	fi
}

function auto_auth_refresh 

{



if [[ -z "$AGAVE_DISABLE_AUTO_REFRESH" ]]; then

		# If this function is entered, it assumes the user already stores keys in ~/.agave/current,
		# and that the bearer and refresh tokens have previously been created, and that the bearer token
		# is expired

		__hosturl="$baseurl"
		__hosturl=${__hosturl}/token
		__post_options="grant_type=refresh_token&refresh_token=${refresh_token}&scope=PRODUCTION"

		response=`curl -sku "$apikey:$apisecret" -X POST -d "${__post_options}" -H "Content-Type:application/x-www-form-urlencoded" "$__hosturl"`

		if [[ ! $? ]] && (($verbose)); then
			err "Unable to refresh token. If you do not update your token manually using the auth-tokens-refresh command, token refresh will be attempted again prior to your next request."
		else
			jsonval access_token "$response" "access_token"
			jsonval refresh_token "$response" "refresh_token"
			jsonval expires_in "$response" "expires_in"
			created_at=$(date +%s)
			if is_gnu ; then
				expires_at=`date -d @$(expr $created_at + $expires_in)`
			else
				expires_at=`date -r $(expr $created_at + $expires_in)`
			fi

			kvset current "{\"tenantid\":\"$tenantid\",\"baseurl\":\"$baseurl\",\"devurl\":\"$devurl\",\"apisecret\":\"$apisecret\",\"apikey\":\"$apikey\",\"username\":\"$username\",\"access_token\":\"$access_token\",\"refresh_token\":\"$refresh_token\",\"created_at\":\"$created_at\",\"expires_in\":\"$expires_in\",\"expires_at\":\"$expires_at\"}"

			if [[ $verbose -ne 1 ]]; then
				echo "Token for ${tenantid}:${username} successfully refreshed and cached for ${expires_in} seconds"
			fi

			jsonval result "$response" "access_token"
			echo "${result}"

			# The command call below here also works, if un-commented. But perhaps the above is preferable?
			#( /bin/bash $DIR/auth-tokens-refresh )
		fi
	fi
}

function is_gnu {
	date --version >/dev/null 2>&1 && exit 0 && exit 1
}

function richify {

	#
	# Generate rich plaintext response
	#

	# the first parameter passed here is the json response
	json_response=$1
	shift

	array_of_values=()
	return_string="| "
	return_string_divider="| "
	n=1

	# lookup the calling function to determine the
	# resource type from the calling script name. This
	# keeps the call to this function clean and lets
	# us localize the field name lookup.
	# Here we exec rather than subshell so we keep the reference
	# to the caller of this script
	cli_command=`caller |  awk '{print $2}' | xargs -n 1 sh -c 'basename $0'`

	# If the user is filtering the response, then we need to override the
	# default fields for the given response. Because we introspect the calling
	# script rather than passing in the script name, we can isolate the
	# field lookup here rather than including it in all the calling scripts
	if [[ -n "$responsefilter" && "*" != "$responsefilter" ]]; then
		richargs=($(echo $responsefilter | sed 's/,/ /g' | xargs -n 1))
	else
		richargs=($(grep -m1 $cli_command "${DIR}/richtext" | sed 's#^.*\:##'))
	fi

	# If json values have spaces in them, the loop below balks; IFS fixes it
	oldIFS="$IFS"
	IFS=$'\n'

	# Cut down very long responses so they fit in a table
	max_length="45"

	# the rest of the parameters in $@ are fields to parse
	for params in "${richargs[@]}"; do

		# save parameter names for table header
		return_string="$return_string $params | "

		# dynamically create table divider
		return_string_divider="$return_string_divider ${params//[A-Za-z0-9\[\]\.]/-} | "

		# grab array of values from json response
		results=($(jsonquery "$json_response" "result.[].$params"))
		if [[ -z $results ]]; then
			results=($(jsonquery "$json_response" "result.$params"))
		fi
		if [[ -z $results ]]; then
			results="null"
		fi


		# add these json values to the array of all json values
		for (( i=0; i<${#results[@]}; i++ )); do

			# Parse times into something friendly
			if [[ "$results" != "null" ]]; then
				if [[ "$params" == "lastModified" || "$params" == "lastUpdated" || "$params" == "lastSuccess" || "$params" == "created" || "$params" == "expires" || "$params" =~ /.*Time$/ || "$params" =~ /.*At$/ || "$params" =~ /.*Date$/ ]]; then
					# break date formatting out to its own function so we can
					# consistently reuse it across the cli
					results[$i]=$(format_iso8601_date_and_time "${results[$i]}" 1)

				fi
			fi

			if [[ "${#results[$i]}" -gt "$max_length" ]]; then
				results[$i]=${results[$i]:0:${max_length}}
				results[$i]="${results[$i]}..."
			fi

			array_of_values[$n]="${results[$i]}"
			n=$(expr $n + 1)
		done
	done

	IFS="$oldIFS"

	# print table header and dividing line
	echo $return_string
	echo $return_string_divider

	length_of_array=$(expr $n - 1)
	number_of_responses=$(( $length_of_array / ${#richargs[@]} ))

	# Print responses
	for (( i=1; i<=$number_of_responses; i++ )); do
		echo -n "| "
		for (( j=0; j<$length_of_array; j+=$number_of_responses )); do
			#echo -n "${array_of_values[$(expr $i+$j)]}\t| "
			echo -n "${array_of_values[$(expr $i+$j)]} | "
		done
		echo ""
	done
}

function columnize {

	python $DIR/python2/richtext.py $@

}

function columnize_old {
	#
	# Use awk to put rich text with pipe '|' separators into column format
	# (This replaces the bash 'column' command because 'column' is not 
	# pervasive across all systems)
	#

	# Fields may contain special chars; currently splitting on '|'
	# (subtract 2 because there are empty fields before the first column and after
	# the last column)
	number_of_columns=$( echo "${@}" | head -n1 | awk -F "|" '{print NF-2}' )

	# 'lengths' is an array that stores the max number of characters per column
	lengths=( $(echo "${@}" | awk -F "|" -v numcol="$number_of_columns" '
	{
		for (i=2; i<=numcol+1; i++)
			if ( length($i) > maxchar[i] )
				maxchar[i] = length($i)
	}
	END {
		for (j=2; j<=numcol+1; j++)
			printf "%d%s", maxchar[j], " "
			#printf "|%*-s", maxchar[j], $j
	}' ) )

	# Printf each column with width based on maximum length
	echo "${@}" | awk -F "|" -v numcol="$number_of_columns" -v len="${lengths[*]}" '
	BEGIN {
		split(len, list, " ")
	}
	{
		for (i=2; i<=numcol+1; i++) {
			printf "|%-"list[i-1]"s", $i
		}
		print "|"

	}'
}

# parses ISO8601 datetime to human readable formats
# default: 				Jan 11, 1977 00:00 format
# with second argument: Jan  1, 1977 12:00 am
function format_iso8601_date_and_time() {
	local thisyear iso8601 format_12_hour_clock moddate tmon tday modtime
	thisyear=$(date +%Y)
	iso8601="$1"
	[[ -n "$2" ]] && format_12_hour_clock=1

	moddate=( $(echo "$iso8601" | sed 's/T.*//' | sed 's/-/ /g' | xargs -n 1) )
	tmon=$(month_of_year ${moddate[1]})
	tday=$(echo ${moddate[2]} | sed -e 's/^0/ /')
	tyear=${moddate[0]}

	if (( format_12_hour_clock )); then

		modtime=$(format_iso8601_time "$iso8601" 1)
		echo "${tmon} ${tday}, ${tyear}  ${modtime}"

	elif [[ $thisyear = "${tyear}" ]]; then

		modtime=$(format_iso8601_time "$iso8601" 1)
		echo "${tmon} ${tday} ${modtime}"

	else

		echo "${tmon} ${tday} ${tyear}"
	fi

}

function format_iso8601_time() {
	local iso8601_date format_12_hour_clock iso8601_time modtime hours minutes
	iso8601_date="$1"
	[[ -n "$2" ]] && format_12_hour_clock=1

	# strip iso8601 time out, removing everything after minute place
	iso8601_time=$(echo "$1" | sed -e 's/.*T//' -e 's/\:..\....-..\:..//')
	modtime=( $( echo "$iso8601_time" | sed 's/\:/ /' | xargs -n 1) )
	hours=${modtime[0]#0}
	minutes=${modtime[1]}
	if (( format_12_hour_clock )); then

		if [[ $hours -eq 0 ]]; then
			meridian="am"
			hours=12
		elif [[ $hours -gt 12 ]]; then
			hours=$(expr $hours - 12 )
			meridian="pm"
		else
			meridian="am"
		fi

		if [[ $hours -gt 9 ]]; then
			echo "$hours:$minutes $meridian"
		else
			echo " $hours:$minutes $meridian"
		fi

	else
		echo "$iso8601_time"
	fi
}

function month_of_year() {
	if [[ "$1" = "01" ]]; then
		echo 'Jan';
	elif [[ "$1" = "02" ]]; then
		echo 'Feb';
	elif [[ "$1" = "03" ]]; then
		echo 'Mar';
	elif [[ "$1" = "04" ]]; then
		echo 'Apr';
	elif [[ "$1" = "05" ]]; then
		echo 'May';
	elif [[ "$1" = "06" ]]; then
		echo 'Jun';
	elif [[ "$1" = "07" ]]; then
		echo 'Jul';
	elif [[ "$1" = "08" ]]; then
		echo 'Aug';
	elif [[ "$1" = "09" ]]; then
		echo 'Sep';
	elif [[ "$1" = "10" ]]; then
		echo 'Oct';
	elif [[ "$1" = "11" ]]; then
		echo 'Nov';
	elif [[ "$1" = "12" ]]; then
		echo 'Dec';
	else
		echo ''
	fi
}

function progress() {
	[[ -z "$1" ]] && err "The job is not currently moving data"

	local _bytesTotal _bytesMoved _rate

	_bytesTotal=$( humanizeBytes $(jsonquery "$1" "totalBytes") )
	_bytesMoved=$( humanizeBytes $(jsonquery "$1" "totalBytesTransferred") )
	_rate=$( humanizeTransferRate $(jsonquery "$1" "averageRate") )

	echo "{\"averageRate\":\"${_rate}\",\"totalBytesTransferred\":\"${_bytesMoved}\",\"totalBytes\":\"${_bytesTotal}\"}"
}

function humanizeTransferRate() {
	echo "$(humanizeBytes $1 )/s"
}

function humanizeBytes() {
	echo $1 | awk '
		function readable( input,     v,s )
		  {
			split( "KB MB GB TB" , v )
			# confirms that the input is a number
			if( input + 0.0 == input )
			   {
				while( input > 1024 ) { input /= 1024 ; s++ }
				return sprintf( "%0.3f%s" , input , v[s] )
			   }
			else
			   {
				return input
			   }
		  }
		{sub(/^[0-9]+/, readable($1)); print}'
}
