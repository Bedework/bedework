#! /bin/bash

DIRNAME=`dirname "$0"`
base=$DIRNAME/../../../../../

cd $base

listCommits() {
  cd $1
  echo
  echo "========================== $1"
  git log --pretty=format:"%ar : %s" -3
  cd ..
}

listCommits bedework-parent
listCommits bedework
listCommits bw-util-deploy
listCommits bw-xml
listCommits bw-util-logging
listCommits bw-util
listCommits bw-util-conf
listCommits bw-util-network
listCommits bw-util-security
listCommits bw-logs
listCommits bw-util-tz
listCommits bw-util-index
listCommits bw-util2
listCommits bw-jsforj
listCommits bw-util-hibernate
listCommits bw-access
listCommits bw-webdav
listCommits bw-caldav
listCommits bw-timezone-server
listCommits bw-synch
listCommits bw-self-registration
listCommits bw-event-registration
listCommits bw-notifier
listCommits bw-sometime
listCommits bw-cliutil
listCommits bw-cli
listCommits bw-carddav
listCommits bw-category
listCommits bw-calendar-common
listCommits bw-calendar-engine
listCommits bw-calendar-client
listCommits bw-calendar-xsl
listCommits bw-calendar-deploy
listCommits bw-wfmodules
listCommits bw-quickstart
listCommits bw-wildfly-galleon-feature-packs
