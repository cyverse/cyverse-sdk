#!/usr/bin/env python

import terrainpy
import argparse
import json
import os.path
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

if __name__ == '__main__':

    # arguments
    parser = argparse.ArgumentParser(description = 'List hierarchys in nested format')
    parser.add_argument('-v', '--verbose', dest = 'verbose', action = 'store_true', help = 'verbose output')
    parser.add_argument('-z', '--accesstoken', dest = 'accesstoken', nargs = '?', help = 'access token')
    args = parser.parse_args()

    # if token not supplied, get from token_cache
    if args.accesstoken is None:
    	args.accesstoken = terrainpy.get_cached_token()

    # build header
    header = {'Authorization': 'Bearer ' + args.accesstoken}

    # list hierarchys
    url = 'https://agave.iplantc.org/terrain/v2/apps/hierarchies'
    list_hierarchys = requests.get(url, headers = header, verify = False)
    list_hierarchys.raise_for_status
    list_hierarchys = list_hierarchys.json()

    # print output based on -v flag
    if args.verbose:
	print json.dumps(list_hierarchys, sort_keys = True, indent = 4, separators = (',', ': '))
    else:
	for item in list_hierarchys['hierarchies']:
	    print item['label'], '\t', item['iri']
