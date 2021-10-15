#! /bin/bash

# -------------------------------------------------------------------
# Standalone install of wildfly
#
# -------------------------------------------------------------------

BASE_DIR=`pwd`
scriptName="$0"
restart=

trap 'cd $BASE_DIR' 0
trap "exit 2" 1 2 3 15

if [ -z "$JAVA_HOME" ] || [ ! -d "$JAVA_HOME" ] ; then
  echo "JAVA_HOME is not defined correctly for bedework."
  exit 1
fi

# 11 onwards
version=$($JAVA_HOME/bin/java -version 2>&1 | sed -E -n 's/.* version "([^.-]*).*/\1/p')
if [[ "$version" -lt "11" ]]; then
  echo "Java 11 or greater is required for bedework"
  exit 1
fi

bwOptions=$HOME/.bw

if [ -f "$bwOptions" ]; then
  . "$bwOptions"
fi

JBOSS_VERSION="22.0.0.Final"
galleonVersion="4.2.5.Final"
galleonFeaturePack="wildfly:22.0#$JBOSS_VERSION"
galleonLayers="datasources-web-server,jms-activemq,webservices"

JBOSS_BASE_DIR="wildfly-$JBOSS_VERSION"

# These relative to $qs
JBOSS_SERVER_DIR="$JBOSS_BASE_DIR/$JBOSS_CONFIG"
JBOSS_DATA_DIR="$JBOSS_SERVER_DIR/data"
bedework_data_dir="$JBOSS_DATA_DIR/bedework"

TMP_DIR="$JBOSS_SERVER_DIR/tmp"

# -------------------------------------------------------------------
args() {
  while [ "$1" != "" ]
  do
    # Process the next arg
    case $1       # Look at $1
    in
      -usage | -help | -? | ?)
        usage
        exit
        shift
        ;;
      qs)
        shift
        qs=$1
        cd $qs
        qs=`pwd`

        shift
        ;;
    esac
  done
}

usage() {
  echo "$scriptName qs <path>"
  echo ""
  echo "qs is a directory in which to build wildfly."
  echo ""
}

# -------------------------------------------------------------------
installWildFly() {
  echo "---------------------------------------------------------------"
  echo "Install wildfly"

# First download galleon

  wget https://github.com/wildfly/galleon/releases/download/$galleonVersion/galleon-$galleonVersion.zip
  unzip galleon-$galleonVersion.zip
  rm galleon-$galleonVersion.zip

  ./galleon-$galleonVersion/bin/galleon.sh install $galleonFeaturePack --dir=$JBOSS_BASE_DIR --layers=galleonLayers

  if [ ! -d "$qs" ]; then
    echo "Quickstart directory $qs doesn't exist"; exit 1;
  fi

  if [ ! -d "$qs/$TMP_DIR" ]; then
    mkdir -p "$qs"/$TMP_DIR
  fi

  mkdir "$qs"/$JBOSS_DATA_DIR
}
