#!/usr/bin/env python

import os
import argparse
import json
from pprint import pprint

parser = argparse.ArgumentParser()

parser.add_argument("tacc_username")
parser.add_argument("tacc_project")
parser.add_argument("storage_path")
parser.add_argument("private_key")
parser.add_argument("template_file")
parser.add_argument("tmp_dir")

args = parser.parse_args()

with open(args.template_file) as f:
	s = f.read()

s = s.replace('${USERNAME}', args.tacc_username)
s = s.replace('${PROJECT}', args.tacc_project)
s = s.replace('${WORKD}', args.storage_path)

jsonDoc = json.loads(s)

with open(args.private_key) as priv:
	privkey = priv.read()

pubkey_file = args.private_key + '.pub'
with open(pubkey_file) as publ:
	pubkey = publ.read()

stanzas = ['login', 'storage']
for stanza in stanzas:
	if stanza in jsonDoc:
		jsonDoc[stanza]['auth']['privateKey'] = privkey
		jsonDoc[stanza]['auth']['publicKey'] = pubkey

# Write out to ~/tmp/system.json
outfilename = args.tmp_dir + '/' + os.path.splitext( os.path.basename(args.template_file) )[0] + '.json'

if not os.path.exists(os.path.dirname(outfilename)):
    try:
        os.makedirs(os.path.dirname(outfilename))
    except OSError as exc: # Guard against race condition
        if exc.errno != errno.EEXIST:
            raise

with open(outfilename, 'w') as outfile:
    json.dump(jsonDoc, outfile, indent=4)
