#! /bin/sh

# Clone all bedework projects

BASE_DIR=`pwd`

trap 'cd $BASE_DIR' 0
trap "exit 2" 1 2 3 15

# $1 - name
cloneRepo() {
  packageName=$1

  echo "---------------------------------------------------------------"
  echo "Clone $packageName"

  echo "git clone https://github.com/Bedework/$packageName.git"
  git clone https://github.com/Bedework/"$packageName".git
}

installSources() {
  # Clone the repos

  # Bedework below
  cloneRepo bw-access
  cloneRepo bw-caldav
  cloneRepo bw-caldavTest
  cloneRepo bw-calendar-client
  cloneRepo bw-calendar-common
  cloneRepo bw-calendar-deploy
  cloneRepo bw-calendar-engine
  cloneRepo bw-calendar-xsl
  cloneRepo bw-calsockets
  cloneRepo bw-carddav
  cloneRepo bw-category
  cloneRepo bw-cliutil
  cloneRepo bw-cli
  cloneRepo bw-dotwell-known
  cloneRepo bw-event-registration
  cloneRepo bw-jsforj
  cloneRepo bw-logs
  cloneRepo bw-notifier
  cloneRepo bw-quickstart
  cloneRepo bw-self-registration
  cloneRepo bw-synch
  cloneRepo bw-timezone-server
  cloneRepo bw-util
  cloneRepo bw-util-conf
  cloneRepo bw-util-deploy
  cloneRepo bw-util-hibernate
  cloneRepo bw-util-index
  cloneRepo bw-util-logging
  cloneRepo bw-util-network
  cloneRepo bw-util-security
  cloneRepo bw-util-tz
  cloneRepo bw-util2
  cloneRepo bw-webdav
  cloneRepo bw-wfmodules
  cloneRepo bw-wildfly-galleon-feature-packs
  cloneRepo bw-xml
}

installSources
