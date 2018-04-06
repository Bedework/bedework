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

latestVersion="3.12.0"
wildflyVersion="wildfly-10.1.0.Final"

wildflyConfDir="${wildflyVersion}/standalone/configuration"

# $1 - branch
# $2 - name
cloneRepoBranch() {
  git clone -b $1 https://github.com/Bedework/$2.git
  sleep 5
}

# $1 - name
cloneRepo() {
  git clone https://github.com/Bedework/$1.git
  sleep 5
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

createProfile() {
cat <<EOT >> $qs/profile.txt
    <profile>
      <id>bedework-3</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <properties>
        <org.bedework.deployment.properties>$qs/bedework/config/wildfly.deploy.properties</org.bedework.deployment.properties>
      </properties>
    </profile>
EOT

echo "Insert the following text (from profile.txt) into your settings.xml file"
cat $qs/profile.txt
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

createProfile

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
wget https://github.com/Bedework/bedework-qsdata/releases/download/release-3.12.0/wfmodules.zip

unzip wfmodules.zip
cp -r wfmodules/* ${wildflyVersion}/modules/
rm wfmodules.zip
rm -r wfmodules

# Replace h2 jar with later version
rm -r ${wildflyVersion}/modules/system/layers/base/com/h2database
cp -r bedework/build/quickstart/resources/h2database  ${wildflyVersion}/modules/system/layers/base/com/

# Hawtio

wget https://github.com/Bedework/bedework-qsdata/releases/download/release-3.12.0/console.zip
unzip console.zip
cp console/hawtio.war ${wildflyVersion}/standalone/deployments/
touch ${wildflyVersion}/standalone/deployments/hawtio.war.dodeploy
rm console.zip
rm console

# Deploy config Copy the config files into the appserver

cp -r bedework/config/bedework ${wildflyConfDir}
cp bedework/config/standalone.xml ${wildflyConfDir}

# Download and install data

wget https://github.com/Bedework/bedework-qsdata/releases/download/release-3.12.0/wfdata.zip
unzip wfdata.zip
mkdir ${wildflyVersion}/standalone/data
cp -r wfdata/* ${wildflyVersion}/standalone/data/
rm -rf wfdata
rm wfdata.zip

# For the moment just build it all

./bw -xsl
./bw -bwutil
./bw -bwxml
./bw -bwutil2
./bw -notifier
./bw -tzsvr
./bw -synch
./bw -eventreg
./bw -selfreg
./bw deploy
