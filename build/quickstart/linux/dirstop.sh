#!/usr/bin/env bash

BASE_DIR=`pwd`

# Figure out where java is

if [ "x$JAVA" = "x" ]; then
  if [ "x$JAVA_HOME" != "x" ]; then
    JAVA="$JAVA_HOME/bin/java"
  else
    JAVA="java"
  fi
fi

cd apacheds-1.5.3-fixed/bin

$JAVA -jar apacheds-tools.jar graceful
