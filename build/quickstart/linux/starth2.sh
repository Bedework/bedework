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

BW_DATA_DIR=$JBOSS_DATA_DIR/bedework

H2cp="$BASE_DIR/$JBOSS_VERSION/modules/system/layers/base/com/h2database/h2/main/h2*.jar"

$JAVA -cp $H2cp org.h2.tools.Server -tcp -web -baseDir $BW_DATA_DIR/h2 &
