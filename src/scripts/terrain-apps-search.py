#!/usr/bin/env python

import terrainpy
import argparse
import json
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

if __name__ == '__main__':

    # arguments
    parser = argparse.ArgumentParser(description = 'List apps found with search term provided.')
    parser.add_argument('-s', '--search', dest = 'search', nargs = '?', help = 'single term with which to search')
    parser.add_argument('-v', '--verbose', dest = 'verbose', action = 'store_true', help = 'verbose output')
    parser.add_argument('-z', '--accesstoken', dest = 'accesstoken', nargs = '?', help = 'access token')
    args = parser.parse_args()

    # if token not supplied, get from token_cache
    if args.accesstoken is None:
    	args.accesstoken = terrainpy.get_cached_token()

    # build header
    header = {'Authorization': 'Bearer ' + args.accesstoken}

    # if only -s given
    if args.search is None:
        args.search = terrainpy.prompt_user('search term')

    # search apps
    url = 'https://agave.iplantc.org/terrain/v2/apps?search=' + args.search
    search = requests.get(url, headers = header, verify = False)
    search.raise_for_status
    search = search.json()

    # print output based on -v flag
    if args.verbose:
	print json.dumps(search, sort_keys = True, indent = 4, separators = (',', ': '))
    else:
	for item in search['apps']:
	    print item['name'], '\t', item['id']
