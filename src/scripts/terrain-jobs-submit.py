#!/usr/bin/env python

import terrainpy
import argparse
import json
import os.path
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

token_cache = '~/.agave/current'

if __name__ == '__main__':

    # arguments
    parser = argparse.ArgumentParser(description = 'Submit a job.')
    parser.add_argument('-f', '--description_file', dest = 'description_file', nargs = '?', help = 'file containing JSON job description')
    parser.add_argument('-v', '--verbose', dest = 'verbose', action = 'store_true', help = 'verbose output')
    parser.add_argument('-z', '--accesstoken', dest = 'accesstoken', nargs = '?', help = 'access token')
    args = parser.parse_args()

    # if token not supplied, get from token_cache
    if args.accesstoken is None:
    	args.accesstoken = terrainpy.get_cached_token()

    # if description file not supplied, prompt user
    if args.description_file is None:
        args.description_file = terrainpy.prompt_user('description_file')

    # build header
    header = {
   	'Authorization': 'Bearer ' + args.accesstoken,
   	'Content-Type' : 'application/json'
    }

    # get job description from description_file
    job_description = open(args.description_file)

    # submit job
    submit_job = requests.post('https://agave.iplantc.org/terrain/v2/analyses', 
   				headers = header, 
   				data = job_description
   			      )
    submit_job.raise_for_status
    submit_job = submit_job.json()

    # print output based on -v flag
    if args.verbose:
	print json.dumps(submit_job, sort_keys = True, indent = 4, separators = (',', ': '))
    else:
	print submit_job['name'], submit_job['id'], submit_job['status']
