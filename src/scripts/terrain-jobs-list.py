#!/usr/bin/env python

import terrainpy
import argparse
import json
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

token_cache = '~/.agave/current'

if __name__ == '__main__':

    # arguments
    parser = argparse.ArgumentParser(description = 'List previous jobs. If a jobID is provided, only the verbose description of that job will be provided.')
    parser.add_argument('-j', '--jobID', dest = 'jobID', default = '', nargs = '?', help = 'ID of job for which to give verbose output')
    parser.add_argument('-v', '--verbose', dest = 'verbose', action = 'store_true', help = 'verbose output')
    parser.add_argument('-z', '--accesstoken', dest = 'accesstoken', nargs = '?', help = 'access token')
    args = parser.parse_args()

    # if token not supplied, get from token_cache
    if args.accesstoken is None:
    	args.accesstoken = terrainpy.get_cached_token()

    # build header
    header = {'Authorization': 'Bearer ' + args.accesstoken}

    # list jobs
    url = 'https://agave.iplantc.org/terrain/v2/analyses'
    list_jobs = requests.get(url, headers = header)
    list_jobs.raise_for_status
    list_jobs = list_jobs.json()

    # print individual job description if --jobID given
    if args.jobID != '':
	if args.jobID is None:
	    args.jobID = terrainpy.prompt_user('jobID')
	for job in list_jobs['analyses']:
	    if job['id'] == args.jobID:
		print json.dumps(job, sort_keys = True, indent = 4, separators = (',', ': '))
		break

    # print comprehensive output based on -v flag if --jobID not given
    elif args.verbose:
	print json.dumps(list_jobs, sort_keys = True, indent = 4, separators = (',', ': '))
    else:
	for job in list_jobs['analyses']:
	    print job['name'], job['id'], job['status']
