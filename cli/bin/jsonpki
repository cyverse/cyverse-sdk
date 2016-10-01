#!/bin/bash
#
# Name: jsonpki.sh
#
# Author: Rion Dooley - deardooley
#
# Description: This is a utility script to serialize keys and passwords into
# strings that can be included safely in json objects and sent to a remote
# server. There are surely other ways to do this, but this seems to work well
# in situations such as creating system descriptions for use in the Agave
# platform.
#

usage() {
 echo -n "$(basename $0) [CMD] [OPTIONS] [PATH | -]

This script serializes and delimits various kinds of credentials
in JSON friendly way. Specify the credential type and either the
path to the file you would like to serialize or a dash, '-', if
providing the contents via stdin. You can also pipe directly into
this script just specifying the command.

Commands:
  --public      Serialize a public key
  --private     Serialize a private key (default)
  --password    Serialize a password

Options:
  -h            This help message

"
}

out() {
  echo $@
}

die() {
  out "$@"; exit 1;
} >&2

err() {
  if ((piped)); then
    out "$@"
  else
    printf '%b\n' "\033[1;31m$@\033[0m"
  fi
} >&2

main() {

  if [[ "$#" -eq 2 ]]; then

    if [[ "$1" = "-h" ]]; then

      usage

    # make sure the input is valid
    elif [ ! -e "$2" -a "$2" != '-' ]; then

      err "Invalid input specified"

    # public keys are escaped one way
    elif [[ "$1" = "--public" ]]; then

      out $(cat $2 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')

      # passwords are escaped another
    elif [[ "$1" = "--password" ]]; then

      out $(cat $2 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g' -e 's/\$/\\\$/g')

    elif [[ "$1" = "--private" ]]; then

      # private keys are escaped yet one way
      out $(cat $2 | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' -e 's/\//\\\//g')

    else

      err "Invalid command specified"

    fi

  # if they are piping
  elif [[ -t 1 ]]; then

    if [[ "$1" = "-h" ]]; then

      usage

    elif [[ "$1" = "--public" ]]; then

      out $(cat - | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')

      # passwords are escaped another
    elif [[ "$1" = "--password" ]]; then

      out $(cat - | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g' -e 's/\$/\\\$/g')

    elif [[ "$1" = "--private" ]]; then

      # private keys are escaped yet one way
      out $(cat - | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\\\n/g' -e 's/\//\\\//g')

    else

      err "Invalid command specified"

    fi

  else

    usage;

  fi
}

# set -x
main $@
