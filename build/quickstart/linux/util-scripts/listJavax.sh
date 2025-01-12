#! /bin/bash

listThem () {
  echo "$1:"
  cd $1
  mvn -Pbedework-dev dependency:resolve > /dev/null

  rm -f /tmp/.bwjavaxtemp*
  mvn -Pbedework-dev -o dependency:list | grep "javax\." | cut -d] -f2- | sed 's/:[a-z]*$//g' | sed 's/:compile//' | sed 's/:provided//' | sort -u | sed 's/ \-\-.*//' > /tmp/.bwjavaxtemp

  touch /tmp/.bwjavaxtemp-convert
  touch /tmp/.bwjavaxtemp-ok

  cat /tmp/.bwjavaxtemp | grep "javax.mail" >> /tmp/.bwjavaxtemp-convert

  cat /tmp/.bwjavaxtemp | grep "javax.servlet" >> /tmp/.bwjavaxtemp-convert

  cat /tmp/.bwjavaxtemp | grep -v "javax.mail"| grep -v "javax.servlet" > /tmp/.bwjavaxtemp-ok
  echo "----- Has references to the following to convert"
  cat /tmp/.bwjavaxtemp-convert

  echo "----- Has references to the following OK"
  cat /tmp/.bwjavaxtemp-ok

  if [ -s /tmp/.bwjavaxtemp-convert ]; then
    # Show the entire tree
    mvn -Pbedework-dev -o dependency:tree -Dverbose=true
  else
    printf "Nothing to convert"
  fi

  cd ..
}

listThem bw-timezone-server
exit 1



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
listThem bw-categories
listThem bw-wfmodules
listThem bw-wf-feature-pack
listThem bw-calendar-deploy

