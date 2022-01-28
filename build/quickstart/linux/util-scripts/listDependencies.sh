#! /bin/bash

listThem () {
  echo "$1:"
  cd $1
  mvn -Pbedework-dev dependency:resolve > /dev/null

# List all
# mvn -o dependency:list | grep ":.*:.*:.*" | cut -d] -f2- | sed 's/:[a-z]*$//g' | sort -u

  # Bedework only
  mvn -Pbedework-dev -o dependency:list | grep "org\.bedework.*:.*:.*:.*" | cut -d] -f2- | sed 's/:[a-z]*$//g' | sort -u
  cd ..
}

listThem bw-xml
listThem bw-util-deploy
listThem bw-util-logging
listThem bw-util
listThem bw-util-conf
listThem bw-util-network
listThem bw-util-security
listThem bw-logs
listThem bw-util-tz
listThem bw-util-index
listThem bw-util2
listThem bw-jsforj
listThem bw-util-hibernate
listThem bw-access
listThem bw-webdav
listThem bw-caldav
listThem bw-timezone-server
listThem bw-synch
listThem bw-self-registration
listThem bw-event-registration
listThem bw-notifier
listThem bw-sometime
listThem bw-cliutil
listThem bw-cli
listThem bw-carddav
listThem bw-calendar-common
listThem bw-calendar-engine
listThem bw-calendar-client
listThem bw-calendar-xsl
listThem bw-wfmodules
listThem bw-wf-feature-pack
listThem bw-calendar-deploy

