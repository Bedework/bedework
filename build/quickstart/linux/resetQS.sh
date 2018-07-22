#!/usr/bin/env bash

# Reset a bedework quickstart to its initial state - for testing

saveddir=`pwd`
scriptName="$0"
restart=

trap 'cd $saveddir' 0
trap "exit 2" 1 2 3 15

if [ -z "$JAVA_HOME" -o ! -d "$JAVA_HOME" ] ; then
  echo "JAVA_HOME is not defined correctly for bedework."
  exit 1
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

wildflyVersion="wildfly-10.1.0.Final"

# -------------------------------------------------------------------
# Each step is a function
# -------------------------------------------------------------------

# These are the steps in the process
installData="installData"

installData() {
  echo "---------------------------------------------------------------"
  echo "Install data"

  rm -rf wfdata
  rm wfdata.zip
  rm -r ${wildflyVersion}/standalone/data

  wget https://github.com/Bedework/bedework-qsdata/releases/download/release-3.12.0/wfdata.zip
  unzip wfdata.zip
  mkdir ${wildflyVersion}/standalone/data
  cp -r wfdata/* ${wildflyVersion}/standalone/data/
  rm -rf wfdata
  rm wfdata.zip
}

installData

