#!/bin/env bash

# Implements encrypted key:value store atop the Agave metadata service

# Tooling
# keyval-addupdate -d <value> <key>
# keyval-search <key>
# keyval-delete <key>
# keyval-pems-update -u <user> -p READ|NONE <key>
# keyval-password-create -d <password> --auto -n <name>
# keyval-password-disable -n <name>
# keyval-passwword-pems-update -u <user> -p READ|NONE <name>

# Keys
# [x] Must be unique within combination of tenant/username
# [ ] Up to 64 bytes long, excluding the namespace data
# [ ] Must be URL-safe
# [ ] Searchable via wildcard

# Values
# [x] Any content is acceptable
# [ ] Up to 255 characters
# [x] Encrypted with aes-256-cbc at rest
# [x] Encryption is destructive with respect to password
# [ ] Multiple named passwords are supported

# Passwords
# [ ] Up to 64 characters
# [ ] Can consist of any Base64 character
# [ ] Cached with lightweight encryption in $HOME/.agave_store/.<tenant>.pass
# [x] System can autogenerate a compliant password for a user
# [ ] Can be stored/retrieved in database
# [ ] Sharable (read-only) with other users if stored in database

# Key:Value Pairs
# [ ] Shareable )read-only) for reading so long as recipient has password

if [[ -z "$DIR" ]]; then
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

_STORE_AGAVE_USERNAME=
_STORE_AGAVE_TENANT=
_STORE_OPENSSL_VERSION=
_STORE_TENANT_USER_DIGEST=
# Digest of tenant/username
# - Used to trivally encrypt your master passwords
# echo "vaughn.iplantc.org" | openssl dgst -hex -sha256 | awk '{print $2}'

get_agave_uname(){
	# Retrieve username for current Agave user
	if [ -z "${_STORE_AGAVE_USERNAME}" ];
	then
		local __auth_check=$(auth-check -v)
		local __tmp=$( _jsonval "${__auth_check}" "username" )
		export _STORE_AGAVE_USERNAME="${__tmp}"
	fi
	echo -n "${_STORE_AGAVE_USERNAME}"
}

get_agave_tenant(){
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

get_create_agave_store_password(){

	local _t=$(get_agave_tenant)
	local _pass=
	local _pf="$HOME/.agave_store/.${_t}.pass"

	if [ ! -d "$HOME/.agave_store" ]
	then
		mkdir -p "$HOME/.agave_store"
	fi

	if [ ! -f "${_pf}" ]
	then
		default="$(_rand_pass)"
		read -p "Enter (or create) the encryption password for your Agave key-value store [$default]: " XPASS
		XPASS=${XPASS:-$default}
		if [ -z "$XPASS" ]; then echo "Error: You cannot leave this empty."; exit 1; fi
		echo -e "Make sure to record this value somewhere as you will not be able to decrypt values without it.\nPassword: $XPASS\n"
		echo -n "$XPASS" > "${_pf}"
	fi

	local _pass=$(cat "${_pf}")
	echo -n "${_pass}"

}

read_agave_store_key_val(){

	local _key1="${1}"
	local _key=$(_construct_agave_store_key "${_key1}")
	local _dat=$(metadata-list -v -l 1 -Q "{\"name\":\"${_key}\"}")
	echo ${_dat}
}

write_agave_store_key_val(){

	local _key1="${1}"
	local _val1="${2}"

	local _key=$(_construct_agave_store_key "${_key1}")
	local _val=$(_encrypt_value "${_val1}")
	local _uuid=$(metadata-list -l 1 -Q "{\"name\":\"${_key}\"}")

	metadata-addupdate -v -F - "${_uuid}" <<EOM
{"name": "${_key}", "value": "${_val}" }
EOM

}

validate_agave_store_key(){
	return 0
}

_get_user_enc_digest(){
	local _user=
	local _tenant=$(get_agave_tenant)
#	local _tenant="iplantc.org"
	local _digest=

	if [ -n "$1" ];
	then
		# [TODO] Validate this is a valid user
		_user="$1"
	else
		_user=$(get_agave_uname)
	fi

	echo "${_STORE_TENANT_USER_DIGEST}"

	if [ -z "${_STORE_TENANT_USER_DIGEST}" ]
	then
		echo "Computing..."
		local _tmp=$(echo "${_tenant}:${_user}" | openssl dgst -hex -sha256 | awk '{print $2}')
		export _STORE_TENANT_USER_DIGEST="${_tmp}"
	fi
	echo -n "${_STORE_TENANT_USER_DIGEST}"

}

_construct_agave_store_key(){
	local _keyname=$1
	echo "store:$(get_agave_tenant):$(get_agave_uname):${_keyname}"
}

_jsonval(){
	local _json=$1
	local _query=$2
	local _stripquotes='-s'
	# [TODO] Remove hard-coded path
	local _tmp=$(echo "${_json}" | python /Users/mwvaughn/cyverse-cli/bin/python2/pydotjson.py -q ${_query} ${_stripquotes})
	echo -n $_tmp
}

_rand_pass(){
	# Generates a random base64 password
	# [TODO] Check against older openssl versions
	local __tmp=$(openssl rand -base64 12)
	echo -n "${__tmp}"
}

_encrypt_value(){
	local _val=$1
	local _pass=$(get_create_agave_store_password)
	local _vers=$(_openssl_get_version)
	# [TODO] Implement different forms depending on OpenSSL version + platform
	local _encrypted=$(echo "${_val}" | openssl enc -aes-256-cbc -a -k "${_pass}")
	echo -n "${_encrypted}"
}

_decrypt_value(){
	local _pass=$(get_create_agave_store_password)
	local _val=$1
	local _decrypted=$(echo "${_val}" | openssl enc -aes-256-cbc -d -a -k "${_pass}")
	echo -n "${_decrypted}"
}

_openssl_get_version(){
	if [ -z "${_STORE_OPENSSL_VERSION}" ]
	then
		if hash openssl 2>/dev/null; then
			local _vers=$(openssl version | awk '{print $2}')
			export _STORE_OPENSSL_VERSION="${_vers}"
		else
			exit 1
		fi
	fi
	echo -n "${_STORE_OPENSSL_VERSION}"
}

_vercomp () {
	# Do not use shell-based version comparisons from Stack Overflow

	# 0 $1 < $2
	# 1 $1 = $2
	# 2 $1 > $2

    local _result=$(${DIR}/vercomp.py $1 $2)
    echo -n "${_result}"
}

