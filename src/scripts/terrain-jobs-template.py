#!/usr/bin/env python

import terrainpy
import argparse
import json
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

if __name__ == '__main__':

    # arguments
    parser = argparse.ArgumentParser(description = 'Generate template for job given app ID.')
    parser.add_argument('-a', '--appID', dest = 'appID', nargs = '?', help = 'app ID with which to generate template')
    parser.add_argument('-v', '--verbose', dest = 'verbose', action = 'store_true', help = 'verbose output')
    parser.add_argument('-z', '--accesstoken', dest = 'accesstoken', nargs = '?', help = 'access token')
    args = parser.parse_args()

    # if token not supplied, get from token_cache
    if args.accesstoken is None:
    	args.accesstoken = terrainpy.get_cached_token()

    # build header
    header = {'Authorization': 'Bearer ' + args.accesstoken}

    # if -a not given
    if args.appID is None:
        args.appID = terrainpy.prompt_user('appID')

    # get app description
    url = 'https://agave.iplantc.org/terrain/v2/apps/de/' + args.appID
    description = requests.get(url, headers = header, verify = False)
    description.raise_for_status
    description = description.json()

    # get parameters
    parameters = {}   
    groups = description['groups']
    for item in groups:
        for parameter in item['parameters']:
            parameters[parameter['id']] = parameter['label']

    # build template
    template = {
        'app_Id': args.appID,
        'archive_logs': True,
        'config': parameters,
        'create_output_subdir': True,
        'debug': False,
        'name': '',
        'notify': True,
        'output_dir': ''
    }

    print json.dumps(template, sort_keys = True, indent = 4, separators = (',', ': '))
