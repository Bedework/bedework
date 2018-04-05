#!/usr/bin/env bash

# Create a bedework quickstart

latestVersion="3.12.0"

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

# download and unpack wildfly

echo "Download wildfly"

wildflyVersion="wildfly-10.1.0.Final"

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

# Hawtio

cd ${wildflyVersion}/standalone/deployments
wget http://dev.bedework.org/downloads/hawtio.war
touch hawtio.war.dodeploy

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
