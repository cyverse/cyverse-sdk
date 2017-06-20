#!/usr/bin/python
# embedcurl.py
#
# A Python 2.7 command line utility for exporting curl commands to
# embedcurl.io and hurl.it references you can share
#

import json, sys, argparse, re, urllib, base64
from operator import attrgetter

debug = False

def parse_args():
    parser = argparse.ArgumentParser(prog="embedcurl.py", description="A command line utility for exporting curl commands to embedcurl.io and hurl.it references you can share .")

    parser.add_argument("-v", "--verbose", action='store_true', default=False,
                            help="Show full embed code for the curl statement")
    parser.add_argument("-V", "--veryverbose", action='store_true', default=False,
                        help="Show request and embed codes")
    parser.add_argument("-H", "--hurlit", action='store_true', default=True,
                                help="Show only the hurl.it url to this curl command")
    parser.add_argument('input', nargs='?', type=argparse.FileType('r'), default=sys.stdin,
                        help="The file containing the curl command to import or stdin if provided.")

    args = parser.parse_args()

    return args

def encodeURIComponent(str):
    def replace(match):
        return "%" + hex( ord( match.group() ) )[2:].upper()
    return re.sub(r"([^0-9A-Za-z!'()*\-._~])", replace, str.encode('utf-8') )
def unescape(str):
    def replace(match):
        return unichr(int(match.group(1), 16))
    return re.sub(r'%u([a-fA-F0-9]{4}|[a-fA-F0-9]{2})', replace, str)

def main():

    global debug

    args = parse_args()
    
    debug = args.debug

    response = ''
    curly = base64.b64encode(args.input.read())
    curly = re.sub(r'o=$', '==', curly)

    remotequery = 'https://www.embedcurl.com/view?curl=' + curly

    if args.veryverbose:

        print "Calling " + remotequery + "\n"

    response = urllib.urlopen(remotequery).read()

    if args.hurlit or True:

        print 'Showing hurl.it url here'
        p = re.compile('<span class="hurl"><a href="(.*)" target="_blank">')
        hurls = p.findall(response)

        if len(hurls) > 0:
            print hurls[0]
        else:
            raise Exception('No hurl.it url found')

    if args.verbose or args.veryverbose :

        print response + "\n"

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        if debug:
            raise
        else:
            print e