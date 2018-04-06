#!/usr/bin/env bash

# Create a bedework quickstart

saveddir=`pwd`

trap 'cd $saveddir' 0
trap "exit 2" 1 2 3 15

if [ -z "$JAVA_HOME" -o ! -d "$JAVA_HOME" ] ; then
  echo "JAVA_HOME is not defined correctly for bedework."
  exit 1
fi

version=$("$JAVA_HOME/bin/java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
#echo version "$version"
#echo "${version:0:3}"
if [[ "${version:0:3}" <= "1.7" ]]; then
  echo "Java 8 is required for bedework."
  exit 1
fi

latestVersion="3.12.0"
wildflyVersion="wildfly-10.1.0.Final"

wildflyConfDir="${wildflyVersion}/standalone/configuration"

# $1 - branch
# $2 - name
cloneRepoBranch() {
  git clone -b $1 https://github.com/Bedework/$2.git
}

# $1 - name
cloneRepo() {
  git clone https://github.com/Bedework/$1.git
}

installSources() {
  # Clone the repos

  if [ "$version" == "dev" ] ; then
    # Bedework below
    cloneRepo bw-access
    cloneRepo bw-caldav
    cloneRepo bw-caldavTest
    cloneRepo bw-calendar-client
    cloneRepo bw-calendar-engine
    cloneRepo bw-calendar-xsl
    cloneRepo bw-calsockets
    cloneRepo bw-carddav
    cloneRepo bw-cli
    cloneRepo bw-dotwell-known
    cloneRepo bw-event-registration
    cloneRepo bw-notifier
    cloneRepo bw-self-registration
    cloneRepo bw-synch
    cloneRepo bw-timezone-server
    cloneRepo bw-util
    cloneRepo bw-util2
    cloneRepo bw-webdav
    cloneRepo bw-xml
  else
    echo "later"
  fi
}

installScripts() {
  if [ "$version" == "dev" ] ; then
    cloneRepo bedework
  else
    echo "later"
  fi

  chmod +x bedework/build/quickstart/linux/qs-scripts/*
  cp bedework/build/quickstart/linux/qs-scripts/* .
}

#read -p "Enter version - 'dev' or 'latest'" version

echo "Which version"
select version in "dev" "latest"; do
    case $version in
        dev ) break;;
        latest ) version=latestVersion; break;;
    esac
done

qs="quickstart-$version"

read -p "Enter path of empty or new directory: " dirpath

if [ ! -d "$dirpath" ]; then
  mkdir -p $dirpath
fi

if    ls -1qA $dirpath | grep -q .
then
  ! echo $dirpath is not empty
  exit 1
fi

cd $dirpath

mkdir $qs
cd $qs

qs=`pwd`

# download and unpack wildfly

echo "Download wildfly"

wget http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.zip

unzip ${wildflyVersion}.zip
rm ${wildflyVersion}.zip

echo "Do you wish to install the sources?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) installSources; break;;
        No ) break;;
    esac
done

installScripts

# Install drivers
wget http://dev.bedework.org/downloads/wfmodules.zip

unzip wfmodules.zip
cp -r wfmodules/* ${wildflyVersion}/modules/
rm wfmodules.zip
rm -r wfmodules

# Hawtio

cd ${wildflyVersion}/standalone/deployments
wget http://dev.bedework.org/downloads/hawtio.war
touch hawtio.war.dodeploy

cd $qs

# For the moment just build it all

./bw -bwutil
./bw -bwxml
./bw -bwutil2
./bw -notifier
./bw -tzsvr
./bw -synch
./bw -eventreg
./bw -selfreg
./bw deploy

# Deploy config Copy the config files into the appserver

cp -r bedework/config/bedework ${wildflyConfDir}
cp bedework/config/standalone.xml ${wildflyConfDir}

# Download and install data

wget http://dev.bedework.org/downloads/qsdata.zip
unzip qsdata.zip
mkdir ${wildflyVersion}/standalone/data
cp -r qsdata/* ${wildflyVersion}/standalone/data/
rm -rf qsdata
rm qsdata.zip
