#!/usr/bin/env bash

# get pwd of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PID_DIR="$( cd "$DIR/.." && pwd );"
SUCCESS=1

####################################################
# Kill the HttpMirror process
####################################################

MIRROR_PID=$(ps x | grep "HttpMirror" | grep -iv "grep" | awk '{ printf("%s\n", $1); }')
if [[ -n "$MIRROR_PID" ]]; then
    echo "Stopping HttpMirror server $MIRROR_PID..."
    kill -9 $MIRROR_PID
    if [ ! $? ]; then
        echo "Failed to kill HttpMirror server!" > 2
        SUCCESS=0
    fi
fi

####################################################
# Kill the ngrok process
####################################################

NGROK_PID=$(ps x | grep "ngrok" | grep -iv "grep" | awk '{ printf("%s\n", $1); }')
if [[ -n "$NGROK_PID" ]]; then
    echo "Stopping ngrok client $NGROK_PID..."
    kill -9 $NGROK_PID
    if [ ! $? ]; then
        echo "Failed to kill ngrok client!" > 2
        SUCCESS=0
    fi
fi

# clean up pid files for both services
rm -f "$PID_DIR/HttpMirror.pid"
rm -f "$PID_DIR/ngrok.pid"

# return proper exit code
if (($SUCCESS)); then
    exit 0;
else
    exit 1;
fi