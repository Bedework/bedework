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
deploySnapshot bw-util-conf
deploySnapshot bw-database
deploySnapshot bw-json
deploySnapshot bw-schemaorgforj
deploySnapshot bw-util-network
deploySnapshot bw-util-security
deploySnapshot bw-util-tz
deploySnapshot bw-util-index
deploySnapshot bw-icalendar-xml
deploySnapshot bw-calws-soap
# Require ical4j, ical4j-vcard
deploySnapshot bw-util2
deploySnapshot bw-logs
#deploySnapshot bw-jsforj
deploySnapshot bw-webcache
deploySnapshot bw-access
deploySnapshot bw-webdav
deploySnapshot bw-synch

# Requires apache-jdkim
deploySnapshot bw-caldav
deploySnapshot bw-timezone-server
deploySnapshot bw-self-registration
deploySnapshot bw-event-registration
deploySnapshot bw-notifier
# deploySnapshot bw-sometime
deploySnapshot bw-cliutil
deploySnapshot bw-cli
deploySnapshot bw-carddav
deploySnapshot bw-category
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
