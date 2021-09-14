 #!/usr/bin/env bash

# Reset a bedework quickstart to its initial state - for testing with postgresql

BASE_DIR=`pwd`
scriptName="$0"
restart=

trap 'cd $BASE_DIR' 0
trap "exit 2" 1 2 3 15

bwOptions=$HOME/.bw

if [ -f "$bwOptions" ]; then
  . "$bwOptions"
fi

if [ -z "$JAVA_HOME" -o ! -d "$JAVA_HOME" ] ; then
  echo "JAVA_HOME is not defined correctly for bedework."
  exit 1
fi

# Figure out where java is for version checks
if [ "x$JAVA" = "x" ]; then
    if [ "x$JAVA_HOME" != "x" ]; then
	JAVA="$JAVA_HOME/bin/java"
    else
	JAVA="java"
    fi
fi

# Check our java version
version=$($JAVA -version 2>&1 | sed -E -n 's/.* version "([^.-]*).*/\1/p')
if [[ "$version" -lt "11" ]]; then
  echo "Java 11 or greater is required for bedework"
  exit 1
fi

JBOSS_VERSION="wildfly"

if [ ! -d "$JBOSS_VERSION" ]; then
  echo "Not located in the quickstart"
  exit 1
fi

resources=$BASE_DIR/bedework/build/quickstart

JBOSS_CONFIG="standalone"
JBOSS_SERVER_DIR="$BASE_DIR/$JBOSS_VERSION/$JBOSS_CONFIG"
JBOSS_DATA_DIR="$JBOSS_SERVER_DIR/data"
bedework_data_dir="$JBOSS_DATA_DIR/bedework"
es_data_dir="$bwESdatadir"

TMP_DIR="$JBOSS_SERVER_DIR/tmp"

echo "Temp dir is $TMP_DIR"

if [ ! -d "$TMP_DIR" ]; then
  mkdir -p $TMP_DIR
fi

# Ensure nothing running

echo -n "Shutting down h2:  "
./stoph2

echo -n "Shutting down apacheds:  "
./dirstop

echo -n "Shutting down elastic search:  "
./stopES

# -------------------------------------------------------------------
# Each step is a function
# -------------------------------------------------------------------

# These are the steps in the process
installData="installData"

installData() {
  echo "---------------------------------------------------------------"
  echo "Install data: this will stop h2 and apacheds but not restart them"

  cd $TMP_DIR/

  # ------------------------------------- h2 data

  rm -f h2.zip

  cp $resources/data/h2.zip .

  rm -rf h2/

  unzip h2.zip

  rm -f h2.zip

  rm -rf $bedework_data_dir/h2

  cp -r h2 $bedework_data_dir/
  rm -rf h2/

  # ------------------------------------- postgres data

  rm -f psql.zip

  cp $resources/data/psql.zip .

  rm -rf psql/

  unzip psql.zip

  rm -f psql.zip

  dropdb caldb
  createdb -O bw caldb
  psql -U bw caldb < psql/caldb.sql

  rm -rf psql/

  cd $BASE_DIR

  # ------------------------------------- ES data

  cd $TMP_DIR/
  rm elasticsearch.zip
  rm -rf nodes
  cp $resources/data/elasticsearch.zip .

  unzip elasticsearch.zip

  rm elasticsearch.zip

  rm -rf $es_data_dir
  mkdir $es_data_dir
  cp -r nodes $es_data_dir/

  # ------------------------------------- directory data

  cd $BASE_DIR

  rm -rf apacheds-1.5.3-fixed
  cp $resources/data/apacheds.zip .
  unzip apacheds.zip
  rm apacheds.zip
}

installData

