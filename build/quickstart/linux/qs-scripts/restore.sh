#!/usr/bin/env bash

# This must be executed from the quickstart home directory.

BASE_DIR=`pwd`

JBOSS_VERSION="wildfly"

if [ ! -d "$JBOSS_VERSION" ]; then
  echo "Not located in the quickstart"
  exit 1
fi

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

# This script will do the following
#     stop h2
#     replace the h2 database files
#     start h2
#     replace the elasticsearch data
#     stop the directory
#     Replace the directory data
#     start the directory
#

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
./starth2

# ------------------------------------- ES data

cd $TMP_DIR/
rm elasticsearch.zip
rm -rf elasticsearch
cp $resources/data/elasticsearch.zip .

unzip elasticsearch.zip

rm elasticsearch.zip

rm -rf $es_data_dir/elasticsearch
cp -r elasticsearch $es_data_dir/

# ------------------------------------- directory data

cd $BASE_DIR
./dirstop

rm -rf apacheds-1.5.3-fixed
cp $resources/data/apacheds.zip .
unzip apacheds.zip
rm apacheds.zip

./dirstart
