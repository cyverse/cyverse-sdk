#!/usr/bin/env python

import terrainpy
import argparse
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

token_cache = '~/.agave/current'

if __name__ == '__main__':

    # arguments
    parser = argparse.ArgumentParser(description = 'Delete job specified by given jobID.')
    parser.add_argument('-j', '--jobID', dest = 'jobID', default = '', nargs = '?', help = 'ID of job for which to give verbose output')
    parser.add_argument('-z', '--accesstoken', dest = 'accesstoken', nargs = '?', help = 'access token')
    args = parser.parse_args()

    # if token not supplied, get from token_cache
    if args.accesstoken is None:
    	args.accesstoken = terrainpy.get_cached_token()

    # if only a jobID is not given
    if args.jobID is None or args.jobID == '':
        args.jobID = terrainpy.prompt_user('jobID')

    # build header
    header = {'Authorization': 'Bearer ' + args.accesstoken}

    # delete job
    url = 'https://agave.iplantc.org/terrain/v2/analyses/' + args.jobID
    delete_job = requests.delete(url, headers = header)
    delete_job.raise_for_status

    print 'Job', args.jobID, 'successfully deleted.'
