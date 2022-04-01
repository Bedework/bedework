#!/usr/bin/env bash

# Reset a bedework quickstart to its initial state - for testing

BASE_DIR=`pwd`
scriptName="$0"
restart=

trap 'cd $BASE_DIR' 0
trap "exit 2" 1 2 3 15

bwOptions=$HOME/.bw

if [ -f "$bwOptions" ]; then
  . "$bwOptions"
fi

JBOSS_VERSION="wildfly"

if [ ! -d "$JBOSS_VERSION" ]; then
  echo "Not located in the quickstart"
  exit 1
fi

h2calresources=$BASE_DIR/bw-quickstart/bw-calendar-data-h2/src/main/resources
h2cardresources=$BASE_DIR/bw-wildfly-galleon-feature-packs/bw-wf-carddav-feature-pack/src/main/resources/packages/data.carddav-h2/pm/wildfly/resources/h2
h2evregresources=$BASE_DIR/bw-wildfly-galleon-feature-packs/bw-wf-event-registration-feature-pack/src/main/resources/packages/data.eventreg-h2/pm/wildfly/resources/h2
h2noteresources=$BASE_DIR/bw-wildfly-galleon-feature-packs/bw-wf-note-feature-pack/src/main/resources/packages/data.notify-h2/pm/wildfly/resources/h2
h2selfregresources=$BASE_DIR/bw-wildfly-galleon-feature-packs/bw-wf-self-registration-feature-pack/src/main/resources/packages/data.selfreg-h2/pm/wildfly/resources/h2
h2synchresources=$BASE_DIR/bw-wildfly-galleon-feature-packs/bw-wf-synch-feature-pack/src/main/resources/packages/data.synch-h2/pm/wildfly/resources/h2

JBOSS_CONFIG="standalone"
JBOSS_BIN=JBOSS_VERSION/bin
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
$JBOSS_BIN/bwstoph2.sh

echo -n "Shutting down apacheds:  "
$JBOSS_BIN/bwdirstop.sh

echo -n "Shutting down opensearch:  "
$JBOSS_BIN/bwstoposchqs.sh

# -------------------------------------------------------------------
# Each step is a function
# -------------------------------------------------------------------

# These are the steps in the process
installData="installData"

installData() {
  echo "---------------------------------------------------------------"
  echo "Install data: this will stop h2 and apacheds but not restart them"

  # ------------------------------------- h2 data

  rm -f $bedework_data_dir/h2/*

  cp -r $h2calresources $bedework_data_dir/h2/
  cp -r $h2cardresources $bedework_data_dir/h2/
  cp -r $h2evregresources $bedework_data_dir/h2/
  cp -r $h2noteresources $bedework_data_dir/h2/
  cp -r $h2selfregresources $bedework_data_dir/h2/
  cp -r $h2synchresources $bedework_data_dir/h2/

  # ------------------------------------- opensearch data

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

