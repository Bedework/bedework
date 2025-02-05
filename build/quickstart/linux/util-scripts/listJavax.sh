#! /bin/bash

listThem () {
  echo "$1:"
  cd $1 || exit
  mvn -Pbedework-dev dependency:resolve > /dev/null

  echo "Start $1" >> "$2"
  mvn -Pbedework-dev dependency:tree -Dverbose -DoutputType=json -DoutputFile=$2 -DappendOutput=true
  echo "End $1" >> "$2"
  cd ..
}

listThem bw-timezone-server $1
#listThem bw-xml $1
listThem bw-util-deploy $1
listThem bw-util-logging $1
listThem bw-util $1
listThem bw-util-conf $1
listThem bw-util-network $1
listThem bw-util-security $1
listThem bw-logs $1
listThem bw-util-tz $1
listThem bw-util-index $1
listThem bw-util2 $1
#listThem bw-jsforj $1
listThem bw-util-hibernate $1
listThem bw-access $1
listThem bw-webdav $1
listThem bw-caldav $1
listThem bw-timezone-server $1
listThem bw-synch $1
listThem bw-self-registration $1
listThem bw-event-registration $1
listThem bw-notifier $1
listThem bw-sometime $1
listThem bw-cliutil $1
listThem bw-cli $1
listThem bw-carddav $1
listThem bw-calendar-common $1
listThem bw-calendar-engine $1
listThem bw-calendar-client $1
listThem bw-calendar-xsl $1
listThem bw-category $1
listThem bw-wfmodules $1
listThem bw-wildfly-galleon-feature-packs $1
listThem bw-calendar-deploy $1

