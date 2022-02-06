#! /bin/bash

DIRNAME=`dirname "$0"`
base=$DIRNAME/../../../../../

cd $base

deploySnapshot() {
  cd $1
  mvn -Pbedework-dev clean deploy
  cd ..
}

deploySnapshot bedework-parent
deploySnapshot bw-apacheds
deploySnapshot bedework
deploySnapshot bw-util-deploy
deploySnapshot bw-bedeworkqs
deploySnapshot bw-xml
deploySnapshot bw-util-logging
deploySnapshot bw-util
deploySnapshot bw-util-conf
deploySnapshot bw-util-network
deploySnapshot bw-util-security
deploySnapshot bw-logs
deploySnapshot bw-util-tz
deploySnapshot bw-util-index
deploySnapshot bw-util2
deploySnapshot bw-jsforj
deploySnapshot bw-util-hibernate
deploySnapshot bw-access
deploySnapshot bw-webdav
deploySnapshot bw-caldav
deploySnapshot bw-timezone-server
deploySnapshot bw-synch
deploySnapshot bw-self-registration
deploySnapshot bw-event-registration
deploySnapshot bw-notifier
deploySnapshot bw-sometime
deploySnapshot bw-cliutil
deploySnapshot bw-cli
deploySnapshot bw-carddav
deploySnapshot bw-category
deploySnapshot bw-calendar-common
deploySnapshot bw-calendar-engine
deploySnapshot bw-calendar-client
deploySnapshot bw-calendar-xsl
deploySnapshot bw-calendar-deploy
deploySnapshot bw-calendar-data
deploySnapshot bw-oschdata
deploySnapshot bw-wfmodules
deploySnapshot bw-wf-feature-pack
