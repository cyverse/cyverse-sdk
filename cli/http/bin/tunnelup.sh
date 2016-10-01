#!/usr/bin/env bash

VERBOSE=1

# get pwd of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# HTTP_PORT defaults to 3000
if [[ -z "$HTTP_PORT" ]]; then
    HTTP_PORT=3000
fi


####################################################
# Start a simple we server to listen for webhook
# from Agave and log them to a file
####################################################

# start the http mirror server.
export WEBHOOK_LOG=$AGAVE_CLI_HOME/http/log/httpmirror.log
if [[ ! -f "$WEBHOOK_LOG" ]]; then
    touch "$WEBHOOK_LOG"
fi
((VERBOSE)) && printf "Starting an Agave HttpMirror server..."
$DIR/HttpMirror -port $HTTP_PORT -log $WEBHOOK_LOG  >> /dev/null &
((VERBOSE)) && echo "done"

####################################################
# Start a ngrok client so external services can
# access the webhook server from a public URL
####################################################

((VERBOSE)) && printf "Starting a ngrok client..."
$DIR/ngrokup.sh &

i=30
while : ; do
    sleep 1
    ((VERBOSE)) && printf "."
    ((i=i-1))
    tunnel=$(curl -s http://localhost:4040/api/tunnels | jq -r ".tunnels[0].public_url")
    [[ "$tunnel" = 'null' ]] && (( $i )) || break
done
((VERBOSE)) && echo "done"

WEBHOOK_URL="$tunnel"

echo "#############################################################"
echo "# A http mirror server has been started and published at: "
echo "#"
echo "#   $WEBHOOK_URL "
echo "#"
echo "# All webhooks sent to that url will be logged at: "
echo "#"
echo "#   $WEBHOOK_LOG "
echo "#"
echo "# Run these commands to configure your environment: "
echo "#"
echo "#   export WEBHOOK_LOG=$WEBHOOK_LOG "
echo "#   export WEBHOOK_URL=$WEBHOOK_URL "
echo "#############################################################"