#!/usr/bin/env bash

echo "About to start ES docker image"

BASE_DIR=`pwd`

configFile=$BASE_DIR/bedework/config/bedework/elasticsearch/elasticsearch.yml
container=docker.elastic.co/elasticsearch/elasticsearch:7.2.0

JBOSS_VERSION="wildfly"

JBOSS_CONFIG="standalone"
JBOSS_SERVER_DIR="$BASE_DIR/$JBOSS_VERSION/$JBOSS_CONFIG"
JBOSS_DATA_DIR="$JBOSS_SERVER_DIR/data"

TMP_DIR="$JBOSS_SERVER_DIR/tmp"
CIDFILE="$TMP_DIR/es.cid"

if [ ! -d "$TMP_DIR" ]; then
  mkdir -p $TMP_DIR
fi

if [ -f "$CIDFILE" ]; then
  printf "Warning: cidfile $CIDFILE exists - trying to shut down running process"
  $BASE_DIR/stopES
fi

rm $CIDFILE

docker run -d --cidfile $CIDFILE -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -v $configFile:/usr/share/elasticsearch/config/elasticsearch.yml $container
