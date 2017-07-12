#!/usr/bin/python
# jsonquery.py
#
# A Python >=2.7 command line utility for querying JSON data using dot notation.

from easydict import EasyDict as edict
import json, sys, argparse, re
from operator import attrgetter

debug = False

def parse_args():
    parser = argparse.ArgumentParser(prog="jsonquery.py", description="A command line utility for querying JSON data using dot notation.")

    parser.add_argument("-d", "--debug", action='store_true', default=False,
                        help="Show debug information")
    parser.add_argument("-s", "--stripquotes", action='store_true', default=False,
                        help="If specified, the resulting response will not be quoted")
    parser.add_argument("-q", "--query", dest="query", type=str, nargs='?', default=None,
                        help="The JSON dot notation query.")
    parser.add_argument('input', nargs='?', type=argparse.FileType('r'), default=sys.stdin,
                        help="The JSON file to import or stdin if provided.")

    args = parser.parse_args()

    return args


def main():

    global debug

    args = parse_args()
    debug = args.debug

    if args.query is None:

        print json.dumps(args.input, sort_keys=True, indent=2, separators=(',', ': '))

    else:

        raw = args.input.read()

        if args.query.startswith('[]') == 1:
            # Modify this json to be compatible with EasyDict
            raw = '{"things":' + raw + '}'

        if debug:
            print 'Original JSON: ' + raw

        raw = json.loads(raw)

        d = edict(raw)

        if d is None:

            if not args.query:
                print ''
            else:
                print 'Empty object has no attribute {0}'.format(args.query)

        else:

            # skipping interpolation of the path in favor of a raw eval here.
            # not as safe, but this is an internal process
            if args.query.startswith('[]') == 1:
                json_path = 'd.things.' + args.query
            else:
                json_path = 'd.' + args.query

            json_path = json_path.strip('[]').strip('.')
            json_path = re.sub(r'\.\[(\d+)\]', '[\1]', json_path, flags=re.IGNORECASE)
            json_path = re.sub(r'\.\[(.+)\]', '[\'\1\']', json_path, flags=re.IGNORECASE)
            json_path = re.sub(r'\[\]\.', '.[].', json_path, flags=re.IGNORECASE)
            json_path = re.sub(r'\.\.', '.', json_path, flags=re.IGNORECASE)

            if json_path.find('[]') != -1:
                tokens = json_path.split('.[].', 1)
                if debug: print 'Resulting path query is: map(attrgetter({0}), eval({1}))'.format(tokens[0], tokens[1])
                query_result = map(attrgetter(tokens[1]), eval(tokens[0]))
            else:
                if debug:
                    print 'Resulting path query is: ' + json_path
                query_result = eval(json_path)

            # query produced a primary type
            if isinstance(query_result, basestring):

                if args.stripquotes is False:
                    print '"{0}"'.format(query_result)
                else:
                    print query_result

            elif isinstance(query_result, int) or isinstance(query_result, float):

                print query_result

            elif isinstance(query_result, bool):

                if query_result:
                    print 'true'
                else:
                    print 'false'

            elif isinstance(query_result, list):

                if args.stripquotes:
                    for r in query_result:
                        print r
                else:
                    print json.dumps(query_result, sort_keys=True, indent=2, separators=(',', ': '))


            # result is dict, object, etc
            else:

                #if isinstance(query_result, list) || isinstance(query_result, dict) || isinstance(query_result, tuple):
                print json.dumps(query_result, sort_keys=True, indent=2, separators=(',', ': '))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        if debug:
            raise
        else:
            print e
