#!/usr/bin/env bash

BASE_DIR=`pwd`
JBOSS_VERSION="wildfly"

JBOSS_CONFIG="standalone"
JBOSS_SERVER_DIR="$BASE_DIR/$JBOSS_VERSION/$JBOSS_CONFIG"

TMP_DIR="$JBOSS_SERVER_DIR/tmp"

export JBOSS_PIDFILE=$TMP_DIR/bedework.jboss.pid

if [ -e JBOSS_PIDFILE ]; then
  printf "Shutting down jboss:  "
  kill -15 `cat JBOSS_PIDFILE`
  rm JBOSS_PIDFILE
else
  echo "jboss doesn't appear to be running."
fi
