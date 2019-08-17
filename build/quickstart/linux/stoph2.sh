#!/usr/bin/env bash

BASE_DIR=`pwd`
JBOSS_VERSION="wildfly"

JBOSS_CONFIG="standalone"
JBOSS_SERVER_DIR="$BASE_DIR/$JBOSS_VERSION/$JBOSS_CONFIG"

TMP_DIR="$JBOSS_SERVER_DIR/tmp"
PIDFILE="$TMP_DIR/h2.pid"

if [ -e $PIDFILE ]; then
  printf "Shutting down h2:  "
  kill -15 `cat $PIDFILE`
  rm $PIDFILE
else
  echo "h2 doesn't appear to be running."
fi
