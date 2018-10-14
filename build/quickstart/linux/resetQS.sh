 #!/usr/bin/env bash

# Reset a bedework quickstart to its initial state - for testing

BASE_DIR=`pwd`
scriptName="$0"
restart=

trap 'cd $BASE_DIR' 0
trap "exit 2" 1 2 3 15

if [ -z "$JAVA_HOME" -o ! -d "$JAVA_HOME" ] ; then
  echo "JAVA_HOME is not defined correctly for bedework."
  exit 1
fi

version=$("$JAVA_HOME/bin/java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
#echo version "$version"
version="${version:2:1}"
#echo "$version"
if [[ "$version" -lt "8" ]]; then
  echo
  echo "************************************************"
  echo "*  Java 8 or greater is required for bedework."
  echo "************************************************"
  echo
  exit 1
fi

JBOSS_VERSION="wildfly-10.1.0.Final"

resources=$BASE_DIR/bedework/build/quickstart

JBOSS_CONFIG="standalone"
JBOSS_SERVER_DIR="$BASE_DIR/$quickstart/$JBOSS_VERSION/$JBOSS_CONFIG"
JBOSS_DATA_DIR="$JBOSS_SERVER_DIR/data"
bedework_data_dir="$JBOSS_DATA_DIR/bedework"
es_data_dir="$bedework_data_dir/elasticsearch"

TMP_DIR="$JBOSS_SERVER_DIR/tmp"

echo "Temp dir is $TMP_DIR"

if [ ! -d "$TMP_DIR" ]; then
  mkdir -p $TMP_DIR
fi

# -------------------------------------------------------------------
# Each step is a function
# -------------------------------------------------------------------

# These are the steps in the process
installData="installData"

installData() {
  echo "---------------------------------------------------------------"
  echo "Install data: this will stop h2 and apacheds but not restart them"

  # ------------------------------------- h2 data

  cd $BASE_DIR
  ./stoph2

  cd $TMP_DIR/

  rm -f h2.zip

  cp $resources/data/h2.zip .

  rm -rf h2/

  unzip h2.zip

  rm -f h2.zip

  rm -rf $bedework_data_dir/h2

  cp -r h2 $bedework_data_dir/
  rm -rf h2/

  cd $BASE_DIR

  # ------------------------------------- ES data

  cd $TMP_DIR/
  rm elasticsearch.zip
  rm -rf elasticsearch
  cp $resources/data/elasticsearch.zip .

  unzip elasticsearch.zip

  rm elasticsearch.zip

  rm -rf $es_data_dir
  cp -r elasticsearch $bedework_data_dir/

  # ------------------------------------- directory data

  cd $BASE_DIR
  ./dirstop

  rm -rf apacheds-1.5.3-fixed
  cp $resources/data/apacheds.zip .
  unzip apacheds.zip
  rm apacheds.zip

}

installData

