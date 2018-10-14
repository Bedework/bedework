#! /bin/bash

if [ -z "$JAVA_HOME" -o ! -d "$JAVA_HOME" ] ; then
  errorUsage "JAVA_HOME is not defined correctly for bedework."
fi

version=$("$JAVA_HOME/bin/java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
#echo version "$version"
version="${version:2:1}"
#echo "$version"
if [[ "$version" -lt "8" ]]; then
  echo
  echo "************************************************"
  echo "*  Java 8 or greater is required for bedework."
  echo "************************************************"
  echo
  exit 1
fi

QS=/home/bedework/quickstart

cd $QS
export JBOSS_PIDFILE=/var/tmp/bedework.jboss.pid

if [ -e $JBOSS_PIDFILE ]; then
    echo -n "Shutting down jboss:  "
    kill -15 `cat $JBOSS_PIDFILE`
    rm $JBOSS_PIDFILE
    echo "[Closing down. Takes a while for everything to halt, tho]"
else
    echo "Jboss doesn't appear to be running."
fi

echo -n "Shutting down h2:  "
./stoph2

echo -n "Shutting down apacheds:  "
./dirstop

