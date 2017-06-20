#!/usr/bin/env bash

####################################################
# Establish a tunnel outboud from the container so
# external services can address it directly
####################################################

if [ "$1" = "/bin/sh" ]; then
    shift
fi

if [ -n "$HTTPS_PORT" ]; then
    FWD="`echo $HTTPS_PORT | sed 's|^tcp://||'`"
elif [ -n "$HTTP_PORT" ]; then
    FWD="`echo $HTTP_PORT | sed 's|^tcp://||'`"
elif [ -n "$APP_PORT" ]; then
    FWD="`echo $APP_PORT | sed 's|^tcp://||'`"
fi

ARGS=""

if [ -n "$NGROK_HEADER" ]; then
    ARGS="$ARGS -host-header=$NGROK_HEADER "
fi

PROTOCOL="http"

if [ "$NGROK_PROTOCOL" == "TCP" ]; then
    PROTOCOL="tcp "
fi

ARGS="$PROTOCOL $ARGS -config /.ngrok2/ngrok.yml -log stdout $FWD"

exec /bin/ngrok $ARGS 2>&1 > $AGAVE_CLI_HOME/http/log/ngrok.log
