#! /bin/bash

set -e

#DIRNAME=`dirname "$0"`
#base=$DIRNAME/../../../../../

#cd $base
#echo "$base"

doPull() {
  echo "---- Pulling $1"
  cd $1
  git pull
  cd ..
}

doPull bedework-parent
doPull bw-util-deploy

doPull bw-base
doPull bw-util-logging
doPull bw-util
doPull bw-util-conf
doPull bw-database
doPull bw-json
doPull bw-schemaorgforj
doPull bw-util-network
doPull bw-util-security
# ical4j required here
doPull bw-util-tz
doPull bw-util-index
doPull bw-icalendar-xml
doPull bw-calws-soap
# Require ical4j-vcard
doPull bw-util2
doPull bw-logs
#doPull bw-jsforj
doPull bw-webcache
doPull bw-access
doPull bw-webdav
doPull bw-synch
# Requires apache-jdkim-api
doPull bw-caldav
doPull bw-timezone-server
doPull bw-self-registration
doPull bw-event-registration
doPull bw-notifier
# doPull bw-sometime
doPull bw-cliutil
doPull bw-cli
doPull bw-carddav
doPull bw-category
doPull bw-calendar-common
doPull bw-calendar-engine
doPull bw-calendar-dumprestore
doPull bw-calendar-client
doPull bw-calendar-xsl
doPull bw-calendar-deploy
doPull bw-testsuite
doPull bw-wf-extensions
doPull bw-quickstart


doPull bw-wfmodules
doPull bw-wildfly-galleon-feature-packs
doPull bedework
