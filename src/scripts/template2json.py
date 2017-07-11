#!/usr/bin/env python

import os
import sys
import argparse
import json

# tempate2json.py -k SYSTEM=lonestar.tacc.utexas.edu
#                 PATH=/home/vaughn/apps -i template.jsonx -o file.json

if __name__ == '__main__':

    parser = argparse.ArgumentParser()

    parser.add_argument("-k", dest='keys', help='Space-delimited VAR=Value sets', nargs='*')
    parser.add_argument("-i", dest='input', help='Input (template.jsonx)')
    parser.add_argument("-o", dest="output", help="Output (output.json)")

    args = parser.parse_args()

    try:
        with open(args.input) as f:
            s = f.read()
    except TypeError, e:
        print >> sys.stderr, "[FATAL]", "No filename was provided for -i"
        sys.exit(1)
    except IOError, e:
        print >> sys.stderr, "[FATAL]", args.input, "was not available for reading"
        print >> sys.stderr, "Exception: %s" % str(e)
        sys.exit(1)

    # Iterate through document, replacing variables with values
    for kvp in args.keys:

        try:
            (key, val) = kvp.split('=')
        except ValueError:
            print '[WARN]', kvp, 'not a valid VAR=Value pair'

        keyname = '${' + key + '}'

        s = s.replace(keyname, val)

    # Print out to JSON
    jsonDoc = json.loads(s)

    outpath = os.path.dirname(args.output)
    if outpath:
        if not os.path.exists(os.path.dirname(args.output)):
            try:
                os.makedirs(os.path.dirname(args.output))
            except OSError as exc:  # Guard against race condition
                print >> sys.stderr, "Exception: %s" % str(exc)
                sys.exit(1)

    with open(args.output, 'w') as outfile:
        json.dump(jsonDoc, outfile, indent=4)
