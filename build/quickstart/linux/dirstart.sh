#! /bin/sh

BASE_DIR=`pwd`
JBOSS_VERSION="wildfly-10.1.0.Final"

JBOSS_CONFIG="standalone"
JBOSS_SERVER_DIR="$BASE_DIR/$JBOSS_VERSION/$JBOSS_CONFIG"

TMP_DIR="$JBOSS_SERVER_DIR/tmp"
PIDFILE="$TMP_DIR/apachedir.pid"

if [ ! -d "$TMP_DIR" ]; then
  mkdir -p $TMP_DIR
fi

if [ -f "$PIDFILE" ]; then
  printf "Warning: pidfile $PIDFILE exists - trying to shut down running process"
  $BASE_DIR/stopdir
fi

rm $PIDFILE

cd apacheds-1.5.3-fixed
./apacheds.sh & echo $! >>$PIDFILE
