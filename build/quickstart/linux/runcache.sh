#!/bin/sh

# Script to start jboss with properties defined
# This currently needs to be executed out of the quickstart directory
# (via a source)

BASE_DIR=`pwd`

PRG="$0"

usage() {
  echo "  $PRG [-instances n] [-conf path] [-module mdl]"
  echo ""
  echo " Where:"
  echo ""
  echo "-instances tells vert.x how many copies to start up"
  echo "      typically this would be 1 per CPU core you "
  echo "    have on the server running it."
}

cd vert.x

# ===================== Defaults =================================

instances="2"
mdl="org.bedework~bw-cache-proxy-vertx~3.10-SNAPSHOT"
conf="conf/cache.conf"

# =================== End defaults ===============================

while [ "$1" != "" ]
do
  # Process the next arg
  case $1       # Look at $1
  in
    -usage | -help | -? | ?)
      usage
      exit
      ;;
    -instances)
      shift
      instances="$1"
      shift
      ;;
    -mdl)
      shift
      mdl="$1"
      shift
      ;;
    -conf)
      shift
      conf="$1"
      shift
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

runcmd="bin/vertx "
runcmd="$runcmd runmod $mdl"
runcmd="$runcmd -instances $instances"
runcmd="$runcmd -conf $conf"

echo $runcmd

$runcmd
