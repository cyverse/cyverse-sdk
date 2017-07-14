#!/bin/bash

UTIL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

_AGAVE_EXEC_SYSTEM=
_STORE_AGAVE_USERNAME=
_STORE_AGAVE_TENANT=
_STORE_AGAVE_TOKEN=

function init(){
    echo ""
}

function get_agave_canary(){

    # Test for agave cli in $PATH
    # TODO - Replace with hash
    # TODO - Replace specific instance of hash with general function
    AGAVE_CANARY=$(which auth-check)
    if [ -z "${AGAVE_CANARY}" ]; then echo "The Cyverse CLI is not in your PATH. Please ensure that it is and re-run this script."; exit 1; fi

}

function get_agave_uname(){
    # Retrieve username for current Agave user
    if [ -z "${_STORE_AGAVE_USERNAME}" ];
    then
        local __auth_check=$(auth-check -v)
        local __tmp=$( _jsonval "${__auth_check}" "username" )
        export _STORE_AGAVE_USERNAME="${__tmp}"
    fi
    echo -n "${_STORE_AGAVE_USERNAME}"
}

function get_agave_tenant(){
    # Retrieve tenant ID for current Agave user
    # Useful for namespacing things
    if [ -z "${_STORE_AGAVE_TENANT}" ];
    then
        local __auth_check=$(auth-check -v)
        local __tmp=$( _jsonval "${__auth_check}" "tenantid" )
        export _STORE_AGAVE_TENANT="${__tmp}"
    fi
    echo -n "${_STORE_AGAVE_TENANT}"
}

function get_agave_access_bearer(){
    # Retrieve bearer (access) token for current Agave user
    # TODO - Verify it's not expired
    if [ -z "${_STORE_AGAVE_TOKEN}" ];
    then
        local __auth_check=$(auth-check -v)
        local __tmp=$( _jsonval "${__auth_check}" "access_token" )
        local _STORE_AGAVE_TOKEN="${__tmp}"
    fi
    echo -n "${_STORE_AGAVE_TOKEN}"
}

function get_agave_execsystem_type(){

    # Fetch details of default queue on a given execution system
    local _sysid=$1
    local _token=$(get_agave_access_bearer)
    local _description=$(curl -sk -H "Authorization: Bearer ${_token}" "https://agave.iplantc.org/systems/v2/${_sysid}?pretty=true&filter=executionType")
    local _res=$(echo ${_description} | python ${UTIL_DIR}/pydotjson.py -q .result.executionType -s)
    echo $_res
}

function get_default_queue_execsystem(){

    # Fetch details of default queue on a given execution system
    local _sysid=$1
    local _token=$(get_agave_access_bearer)
    local _description=$(curl -G -sk -H "Authorization: Bearer ${_token}" 'https://agave.iplantc.org/systems/v2?pretty=false&filter=id,queues'  --data id="${_sysid}" --data limit=1)
    echo $_description
}

function urandom_int(){
    # Poll built-in ultrarandom generator to return an integer
    #   Optional: $1 is max byte width of for result
    
    # Source
    #   http://www.linuxnix.com/generate-random-number-bash/
    # Whitespace cleanup
    #   Using tr avoids MacOS-specific behavior in sed and awk
    local _bytes=$1
    if [ -z "${_bytes}" ] || [ "${_bytes}" -le 0 ]; then _bytes=4; fi
    local _result=$(od -An -N${_bytes} -tu4 < /dev/urandom | tr -d "\n"  | tr -d " ")
    echo "${_result}"
}

# Pure bash implemenation of hashid
#   http://hashids.org/
#   https://github.com/benwilber/bashids/tree/v1.0.0

function shortid(){
    # Generate a fairly random shortid
    # Ideal for making app and system names unique
    # without subjecting users to UUID4 hell
    local _uint=$(urandom_int)
    encode_hashid "${_uint}"
}

function encode_hashid(){
    # Create a hashid from a positive integer
    local _salt="What starts here changes the world"
    local _intval=$1
    if [ -z "${_intval}" ] || [ "${_intval}" -le 0 ]; then _intval=0; fi
    echo $(${UTIL_DIR}/bashids -e -s "$_salt" -l 6 $_intval)
}

function decode_hashid(){
    # Decode a hashid back to its positive integer value
    local _salt="What starts here changes the world"
    local _hashid=$1
    if [ -n "${_hashid}" ]
    then
        echo $(${UTIL_DIR}/bashids -d -s "$_salt" $_hashid)
    else
        echo ""
    fi
}

# Pure bash implemenation of hashid
  
function _jsonval(){
    local _json=$1
    local _query=$2
    local _stripquotes='-s'
    # [TODO] Remove hard-coded path
    local _tmp=$(echo "${_json}" | python $UTIL_DIR/pydotjson.py -q ${_query} ${_stripquotes})
    echo -n $_tmp
}

function sysname () {
    echo $(echo -n $(hostname --fqdn | awk -F '.' '{ print $2 }'))
}

function sanitize_id () {
    echo $(echo "$1" | tr -cd '[[:alnum:]]_-')
}

