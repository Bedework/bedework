#!/usr/bin/env bash

echo "About to start h2 process"

BASE_DIR=`pwd`

# Figure out where java is for version checks

if [ "x$JAVA" = "x" ]; then
  if [ "x$JAVA_HOME" != "x" ]; then
    JAVA="$JAVA_HOME/bin/java"
  else
    JAVA="java"
  fi
fi

JBOSS_VERSION="wildfly-10.1.0.Final"

JBOSS_CONFIG="standalone"
JBOSS_SERVER_DIR="$BASE_DIR/$JBOSS_VERSION/$JBOSS_CONFIG"
JBOSS_DATA_DIR="$JBOSS_SERVER_DIR/data"

TMP_DIR="$JBOSS_SERVER_DIR/tmp"
PIDFILE="$TMP_DIR/h2.pid"

if [ ! -d "$TMP_DIR" ]; then
  mkdir -p $TMP_DIR
fi

if [ -f "$PIDFILE" ]; then
  printf "Warning: pidfile $PIDFILE exists - trying to shut down running process"
  $BASE_DIR/stoph2
fi

rm $PIDFILE

BW_DATA_DIR=$JBOSS_DATA_DIR/bedework

H2cp="$BASE_DIR/bedework/build/quickstart/data/h2/h2*.jar"

$JAVA -cp $H2cp org.h2.tools.Server -tcp -web -baseDir $BW_DATA_DIR/h2 & echo $! >>$PIDFILE
