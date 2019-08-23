#!/usr/bin/env bash

echo "About to stop ES docker image"

BASE_DIR=`pwd`
JBOSS_VERSION="wildfly"

JBOSS_CONFIG="standalone"
JBOSS_SERVER_DIR="$BASE_DIR/$JBOSS_VERSION/$JBOSS_CONFIG"

TMP_DIR="$JBOSS_SERVER_DIR/tmp"
CIDFILE="$TMP_DIR/es.cid"

if [ -e $CIDFILE ]; then
  printf "Shutting down ES:  "
  read -r CID<$CIDFILE
  echo "CID=$CID"
  docker stop $CID
  rm $CIDFILE
else
  echo "ES doesn't appear to be running."
fi

