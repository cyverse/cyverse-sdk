#!/usr/bin/env python

import terrainpy
import argparse
import json
import requests
import urllib
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

if __name__ == '__main__':

    # arguments
    parser = argparse.ArgumentParser(description = 'List apps under hierarchy provided.')
    parser.add_argument('-i', '--iri', dest = 'iri', nargs = '?', help = 'hierarchy url for which to list apps')
    parser.add_argument('-v', '--verbose', dest = 'verbose', action = 'store_true', help = 'verbose output')
    parser.add_argument('-z', '--accesstoken', dest = 'accesstoken', nargs = '?', help = 'access token')
    args = parser.parse_args()

    # if token not supplied, get from token_cache
    if args.accesstoken is None:
    	args.accesstoken = terrainpy.get_cached_token()

    # build header
    header = {'Authorization': 'Bearer ' + args.accesstoken}

    # if only -i given
    if args.iri is None:
        args.iri = terrainpy.prompt_user('iri')
    args.iri = '/' + urllib.quote(args.iri, '') + '/apps?attr=rdf%3Atype'

    # list hierarchys
    url = 'https://agave.iplantc.org/terrain/v2/apps/hierarchies' + args.iri
    list_apps = requests.get(url, headers = header)
    list_apps.raise_for_status
    list_apps = list_apps.json()

    # print output based on -v flag
    if args.verbose:
	print json.dumps(list_apps, sort_keys = True, indent = 4, separators = (',', ': '))
    else:
	for item in list_apps['apps']:
	    print item['name'], item['id']
