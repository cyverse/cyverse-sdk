#!/usr/bin/env python

import os
import argparse
import json

parser = argparse.ArgumentParser()

parser.add_argument("identifier")
parser.add_argument("xsede_username")
parser.add_argument("xsede_password")
parser.add_argument("xsede_project")
parser.add_argument("oasis_comet_scratch")
parser.add_argument("oasis_projects")
parser.add_argument("template_file")
parser.add_argument("tmp_dir")

args = parser.parse_args()

with open(args.template_file) as f:
    s = f.read()

s = s.replace('${IDENTIFIER}', args.identifier)
s = s.replace('${XSEDE_USERNAME}', args.xsede_username)
s = s.replace('${XSEDE_PASSWORD}', args.xsede_password)
s = s.replace('${PROJECT}', args.xsede_project)
s = s.replace('${WORKDIR}', args.oasis_comet_scratch)
s = s.replace('${DATADIR}', args.oasis_projects)

jsonDoc = json.loads(s)

# Write out to ~/tmp/system.json
outfilename = args.tmp_dir + '/' + os.path.splitext(os.path.basename(args.template_file))[0] + '.json'

if not os.path.exists(os.path.dirname(outfilename)):
    try:
        os.makedirs(os.path.dirname(outfilename))
    except OSError as exc:  # Guard against race condition
        if exc.errno != errno.EEXIST:
            raise

with open(outfilename, 'w') as outfile:
    json.dump(jsonDoc, outfile, indent=4)
