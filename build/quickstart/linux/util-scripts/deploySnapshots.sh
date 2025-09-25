#! /bin/bash

set -e

DIRNAME=`dirname "$0"`
base=$DIRNAME/../../../../../

cd $base

deploySnapshot() {
  cd $1
  mvn -Pbedework-dev clean deploy
  cd ..
}

deploySnapshot bedework-parent
deploySnapshot bw-util-deploy

deploySnapshot bw-base
deploySnapshot bw-util-logging
deploySnapshot bw-util
deploySnapshot bw-logs
deploySnapshot bw-util-conf
deploySnapshot bw-database
deploySnapshot bw-json
deploySnapshot bw-schemaorgforj
deploySnapshot bw-util-network
deploySnapshot bw-util-security
# ical4j required here
deploySnapshot bw-util-tz
deploySnapshot bw-util-index
deploySnapshot bw-icalendar-xml
deploySnapshot bw-calws-soap
# Require ical4j-vcard
deploySnapshot bw-util2
deploySnapshot bw-webcache
deploySnapshot bw-self-registration
deploySnapshot bw-access
deploySnapshot bw-webdav
deploySnapshot bw-synch
# Does not require apache-jdkim-api unless configured in.
deploySnapshot bw-timezone-server
deploySnapshot bw-caldav
deploySnapshot bw-event-registration
deploySnapshot bw-notifier
# deploySnapshot bw-sometime
deploySnapshot bw-cli
deploySnapshot bw-carddav
deploySnapshot bw-category
#deploySnapshot bw-jsforj
deploySnapshot bw-calendar-common
deploySnapshot bw-calendar-engine
deploySnapshot bw-calendar-dumprestore
deploySnapshot bw-calendar-client
deploySnapshot bw-calendar-xsl
deploySnapshot bw-calendar-deploy
deploySnapshot bw-testsuite
deploySnapshot bw-wf-extensions
deploySnapshot bw-quickstart


deploySnapshot bw-wfmodules
deploySnapshot bw-wildfly-galleon-feature-packs
deploySnapshot bedework
