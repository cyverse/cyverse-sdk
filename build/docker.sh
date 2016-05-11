#!/bin/bash

IMAGENAME=$1
SDKVERSION=$2
COMMAND=$3

if [ -z "$COMMAND" ]; then COMMAND="build"; fi

function die {

	die "$1"
	exit 1

}

DOCKER_INFO=`docker info > /dev/null`
if [ $? -ne 0 ] ; then die "Docker not found or unreachable. Exiting." ; fi

if [ "$COMMAND" == 'build' ];
then

docker build --rm=true -t cyverse/${IMAGENAME}:${SDKVERSION} .
if [ $? -ne 0 ] ; then die "Error on build. Exiting." ; fi

IMAGEID=`docker images -q  cyverse/${IMAGENAME}:${SDKVERSION}`
if [ $? -ne 0 ] ; then die "Can't find image cyverse/${IMAGENAME}:${SDKVERSION}. Exiting." ; fi

docker tag ${IMAGEID} cyverse/${IMAGENAME}:latest
if [ $? -ne 0 ] ; then die "Error tagging with 'latest'. Exiting." ; fi

fi


if [ "$COMMAND" == 'release' ];
then

docker push cyverse/${IMAGENAME}:${SDKVERSION} && docker push cyverse/${IMAGENAME}:latest

if [ $? -ne 0 ] ; then die "Error pushing to Docker Hub. Exiting." ; fi
fi


if [ "$COMMAND" == 'clean' ];
then

docker rmi -f cyverse/${IMAGENAME}:${SDKVERSION} && docker rmi -f cyverse/${IMAGENAME}:latest

if [ $? -ne 0 ] ; then die "Error deleting local images. Exiting." ; fi
fi
