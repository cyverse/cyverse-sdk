#!/usr/bin/env python

import json
import os.path

token_cache = '~/.agave/current'

def get_cached_token():
    token = None
    if os.path.isfile(os.path.expanduser(token_cache)):
        with open(os.path.expanduser(token_cache), 'r') as json_file:
            token = str(json.load(json_file)['access_token'])
    return token

def prompt_user(keyword):
    """Prompt user to enter value for given key at command line."""
    print 'Enter', keyword.replace('_', ' ') + ':'
    return_key = raw_input('')
    return return_key
