#!/usr/bin/env bash

# Create a bedework quickstart

BASE_DIR=`pwd`
scriptName="$0"
restart=

trap 'cd $BASE_DIR' 0
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
JBOSS_VERSION="wildfly-10.1.0.Final"

# We create empty files in this directory to track progress
progressDir="bwinstaller-progress"

# Assigned below
progressPath=

wildflyConfDir="${JBOSS_VERSION}/standalone/configuration"

resources=$BASE_DIR/bedework/build/quickstart

JBOSS_CONFIG="standalone"
JBOSS_SERVER_DIR="$BASE_DIR/$quickstart/$JBOSS_VERSION/$JBOSS_CONFIG"
JBOSS_DATA_DIR="$JBOSS_SERVER_DIR/data"
bedework_data_dir="$JBOSS_DATA_DIR/bedework"
es_data_dir="$bedework_data_dir/elasticsearch"

TMP_DIR="$JBOSS_SERVER_DIR/tmp"

echo "Temp dir is $TMP_DIR"

sameVersion() {
  if [ ! -f "$progressPath/installVersion" ]
  then
    return 0
  fi

  read -r version < ${progressPath}/installVersion

  if [ "$version" != "$1" ] ; then
    return 1
  fi

  return 0
}

markVersion() {
  echo "$1" > $progressPath/installVersion
}

stepDone() {
  if [ -f "$progressPath/${1}.done" ]
  then
    return 0
  fi

  return 1
}

stepStarted() {
  if [ -f "$progressPath/${1}.started" ]
  then
    return 0
  fi

  return 1
}

stepSkipped() {
  if [ -f "$progressPath/${1}.skipped" ]
  then
    return 0
  fi

  return 1
}

unmark() {
  rm "$progressPath/${1}.*"
}

markStarted() {
  touch $progressPath/"${1}".started
}

markSkipped() {
  touch $progressPath/"${1}".skipped
}

markDone() {
  if [ ! -f "$progressPath/${1}.started" ]
  then
    echo "Warning: missing marker $progressPath/${1}.started"
    touch $progressPath/"${1}".done
  else
    mv $progressPath/"${1}".started $progressPath/"${1}".done
  fi
}

args() {
  while [ "$1" != "" ]
  do
    # Process the next arg
    case $1       # Look at $1
    in
      -usage | -help | -? | ?)
        usage
        exit
        shift
        ;;
      -restart)
        shift
        restart="yes"
        shift
        ;;
    esac
  done
}

usage() {
  echo "$scriptName [restart]"
  echo ""
  echo "Will prompt for a directory in which to build the quickstart."
  echo "This is to avoid any unfortunate overwriting of pre-existing"
  echo "files."
  echo ""
}

createProfile() {
cat <<EOT >> "$qs"/profile.txt
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                         http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <pluginGroups>
    <pluginGroup>org.bedework</pluginGroup>
  </pluginGroups>

  <profiles>
    <profile>
      <id>bedework-3</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <properties>
        <org.bedework.deployment.basedir>$qs</org.bedework.deployment.basedir>
        <org.bedework.deployment.properties>$qs/bedework/config/wildfly.deploy.properties</org.bedework.deployment.properties>
      </properties>
    </profile>
  </profiles>
</settings>
EOT
  cat "$qs"/profile.txt
}

# -------------------------------------------------------------------
# Each step is a function
# -------------------------------------------------------------------

# These are the steps in the process
downloadWildfly="downloadWildFly"
unpackWildfly="unpackWildFly"
installScripts="installScripts"
installDrivers="installDrivers"
installHawtio="installHawtio"
installSources="installSources"
installData="installData"
installApacheds="installApacheds"
buildModules="buildModules"

# Suffixed with module name
installModule="installModule-"
buildModule="buildModule-"

# -------------------------------------------------------------------
# download wildfly
# -------------------------------------------------------------------
downloadWildFly() {
  echo "---------------------------------------------------------------"
  echo "Download wildfly"

  if stepDone $downloadWildfly; then
    echo "Already done"
    return
  fi

  if stepStarted $downloadWildfly; then
    echo "Remove possible partial download"
    rm ${JBOSS_VERSION}.zip
  fi

  markStarted $downloadWildfly
  wget http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.zip
  markDone $downloadWildfly
}

# -------------------------------------------------------------------
# unpack wildfly
# -------------------------------------------------------------------
unpackWildFly() {
  echo "---------------------------------------------------------------"
  echo "unpack wildfly"

  if stepDone $unpackWildfly; then
    echo "Already done"
    return
  fi

  if stepStarted $unpackWildfly; then
    echo "Remove possible partial wildfly"
    rm -rf ${JBOSS_VERSION}
    unmark $unpackWildfly
  fi

  markStarted $unpackWildfly
  unzip ${JBOSS_VERSION}.zip
  rm ${JBOSS_VERSION}.zip

  if [ ! -d "$TMP_DIR" ]; then
    mkdir -p $TMP_DIR
  fi

  markDone $unpackWildfly
}

installScripts() {
  echo "---------------------------------------------------------------"
  echo "Install scripts from bedework repo"

  if stepDone $installScripts; then
    echo "Already done"
    return
  fi

  if stepStarted $installScripts; then
    echo "Remove possible partial module"
    rm -rf bedework
    unmark $installScripts
  fi

  markStarted $installScripts

  if [ "$version" == "dev" ] ; then
    cloneRepo bedework
  else
    cloneRepoBranch $latestVersion bedework
  fi

  chmod +x bedework/build/quickstart/linux/qs-scripts/*
  cp bedework/build/quickstart/linux/qs-scripts/* .

  # Copy the config files into the appserver

  cp -r bedework/config/bedework ${wildflyConfDir}
  cp bedework/config/standalone.xml ${wildflyConfDir}

  markDone $installScripts
}

installDrivers() {
  echo "---------------------------------------------------------------"
  echo "Install wildfly drivers"

  if stepDone $installDrivers; then
    echo "Already done"
    return
  fi

  if stepStarted $installDrivers; then
    echo "Remove possible partial downloads"
    rm wfmodules.zip
    rm -r wfmodules
    unmark $installDrivers
  fi

  markStarted $installDrivers

  wget https://github.com/Bedework/bedework-qsdata/releases/download/release-3.12.0/wfmodules.zip

  unzip wfmodules.zip
  cp -r wfmodules/* ${JBOSS_VERSION}/modules/
  rm wfmodules.zip
  rm -r wfmodules

  # Replace h2 jar with later version
  rm -r ${JBOSS_VERSION}/modules/system/layers/base/com/h2database
  cp -r bedework/build/quickstart/resources/h2database  ${JBOSS_VERSION}/modules/system/layers/base/com/

  markDone $installDrivers
}

installHawtio() {
  echo "---------------------------------------------------------------"
  echo "Install hawtio JMX console"

  if stepDone $installHawtio; then
    echo "Already done"
    return
  fi

  if stepStarted $installHawtio; then
    echo "Remove possible partial downloads"
    rm console.zip
    rm -r console
    rm -r ${JBOSS_VERSION}/standalone/deployments/hawtio.war*
    unmark $installHawtio
  fi

  markStarted $installHawtio

  wget https://github.com/Bedework/bedework-qsdata/releases/download/release-3.12.0/console.zip
  unzip console.zip
  cp console/hawtio.war ${JBOSS_VERSION}/standalone/deployments/
  touch ${JBOSS_VERSION}/standalone/deployments/hawtio.war.dodeploy
  rm console.zip
  rm -r console

  markDone $installHawtio
}

installData() {
  echo "---------------------------------------------------------------"
  echo "Install data"

  if stepDone $installData; then
    echo "Already done"
    return
  fi

  if stepStarted $installData; then
#    echo "Remove possible partial downloads"
#    rm -rf wfdata
#    rm wfdata.zip
#    rm -r ${JBOSS_VERSION}/standalone/data
    unmark $installData
  fi

  markStarted $installData

#  wget https://github.com/Bedework/bedework-qsdata/releases/download/release-3.12.0/wfdata.zip
#  unzip wfdata.zip
#  mkdir ${JBOSS_VERSION}/standalone/data
#  cp -r wfdata/* ${JBOSS_VERSION}/standalone/data/
#  rm -rf wfdata
#  rm wfdata.zip
  resources=$BASE_DIR/bedework/build/quickstart

  # Unpack here
  cd $TMP_DIR/

  # ------------------------------------- h2 data

  rm -f h2.zip
  cp $resources/data/h2.zip .
  rm -rf h2/
  unzip h2.zip
  rm -f h2.zip
  rm -rf $bedework_data_dir/h2
  cp -r h2 $bedework_data_dir/
  rm -rf h2/

  # ------------------------------------- ES data

  rm =f elasticsearch.zip
  rm -rf elasticsearch
  cp $resources/data/elasticsearch.zip .
  unzip elasticsearch.zip
  rm elasticsearch.zip
  rm -rf $es_data_dir
  cp -r elasticsearch $bedework_data_dir/

  cd $BASE_DIR

  markDone $installData
}

installApacheds() {
  echo "---------------------------------------------------------------"
  echo "Install Apache DS"

  if stepDone $installApacheds; then
    echo "Already done"
    return
  fi

  if stepSkipped $installApacheds; then
    echo "Skipped"
    return
  fi

  if stepStarted $installApacheds; then
    unmark $installApacheds
  fi

  markStarted $installApacheds

#  wget https://github.com/Bedework/bedework-qsdata/releases/download/release-3.12.0/apacheds.zip
#  unzip apacheds.zip
#  rm apacheds.zip

  cd $BASE_DIR

  rm -f apacheds.zip
  rm -rf apacheds-1.5.3-fixed
  cp $resources/data/apacheds.zip .
  unzip apacheds.zip
  rm apacheds.zip

  markDone $installApacheds
}

# $1 - name
cloneRepo() {
  moduleName=$1

  echo "---------------------------------------------------------------"
  echo "Clone $moduleName"

  stepName=${installModule}$moduleName

  if stepDone "${stepName}"; then
    echo "Already done"
    return
  fi

  if stepSkipped "$stepName"; then
    echo "Skipped"
    return
  fi

  if stepStarted "$stepName"; then
    echo "Restarting from partial install"
    rm -rf "$moduleName"
  else
    markStarted "$stepName"
  fi

  echo "git clone https://github.com/Bedework/$moduleName.git"
  if [ "$2" == "echo" ] ; then
    return
  fi

  git clone https://github.com/Bedework/"$moduleName".git

  markDone "$stepName"

  sleep 5
}

# $1 - branch
# $2 - name
cloneRepoBranch() {
  moduleName=$2

  echo "---------------------------------------------------------------"
  echo "Clone $moduleName"

  stepName=${installModule}$moduleName

  if stepDone "${stepName}"; then
    echo "Already done"
    return
  fi

  if stepSkipped "$stepName"; then
    echo "Skipped"
    return
  fi

  if stepStarted "$stepName"; then
    echo "Restarting from partial install"
    rm -rf "$moduleName"
  else
    markStarted "$stepName"
  fi

  echo "git clone -b $moduleName-$1 https://github.com/Bedework/$moduleName.git"
  if [ "$2" == "echo" ] ; then
    return
  fi
  git clone -b "$moduleName"-"$1" https://github.com/Bedework/"$moduleName".git

  markDone "$stepName"

  sleep 5
}

installSources() {
  echo "---------------------------------------------------------------"
  echo "Install sources"

  if stepDone $installSources; then
    echo "Already done"
    return
  fi

  if stepSkipped $installSources; then
    echo "Skipped"
    return
  fi

  if stepStarted $installSources; then
    echo "Restarting from partial install"
  else
    markStarted $installSources
  fi

  # Clone the repos

  if [ "$version" == "dev" ] ; then
    # Bedework below
    cloneRepo bw-access "$1"
    cloneRepo bw-caldav "$1"
    cloneRepo bw-caldavTest "$1"
    cloneRepo bw-calendar-client "$1"
    cloneRepo bw-calendar-engine "$1"
    cloneRepo bw-calendar-xsl "$1"
    cloneRepo bw-calsockets "$1"
    cloneRepo bw-carddav "$1"
    cloneRepo bw-cli "$1"
    cloneRepo bw-dotwell-known "$1"
    cloneRepo bw-event-registration "$1"
    cloneRepo bw-notifier "$1"
    cloneRepo bw-self-registration "$1"
    cloneRepo bw-synch "$1"
    cloneRepo bw-timezone-server "$1"
    cloneRepo bw-util "$1"
    cloneRepo bw-util2 "$1"
    cloneRepo bw-util-hibernate "$1"
    cloneRepo bw-webdav "$1"
    cloneRepo bw-xml "$1"
  else
    cloneRepoBranch 4.0.2 bw-access "$1"
    cloneRepoBranch 4.0.3 bw-caldav "$1"
    cloneRepoBranch 3.12.0 bw-calendar-client "$1"
    cloneRepoBranch 3.12.0 bw-calendar-engine "$1"
    cloneRepoBranch 3.12.1 bw-calendar-xsl "$1"
    #cloneRepo bw-calsockets "$1"
    cloneRepoBranch 4.0.2 bw-carddav "$1"
    cloneRepoBranch 4.0.0 bw-cli "$1"
    cloneRepo bw-dotwell-known "$1"
    cloneRepoBranch 4.0.1 bw-event-registration "$1"
    cloneRepoBranch 4.0.2 bw-notifier "$1"
    cloneRepoBranch 4.0.3 bw-self-registration "$1"
    cloneRepoBranch 4.0.0 bw-synch "$1"
    cloneRepoBranch 4.0.1 bw-timezone-server "$1"
    cloneRepoBranch 4.0.18 bw-util "$1"
    cloneRepoBranch 4.0.0 bw-util2 "$1"
  ###  cloneRepoBranch 4.x.x bw-util-hibernate "$1"
    cloneRepoBranch 4.0.2 bw-webdav "$1"
    cloneRepoBranch 4.0.5 bw-xml "$1"
  fi

  markDone $installSources
}

# $1 - name
buildModule() {
  moduleName=$1

  echo "---------------------------------------------------------------"
  echo "Build $moduleName"

  stepName=${buildModule}$moduleName

  if stepDone "${stepName}"; then
    echo "Already done"
    return
  fi

  if stepSkipped "$stepName"; then
    echo "Skipped"
    return
  fi

  if stepStarted "$stepName"; then
    echo "Restarting from partial build"
  else
    markStarted "$stepName"
  fi


  if [ "$moduleName" = "deploy" ] ; then
    ./bw deploy
  else
    ./bw -"$moduleName"
  fi

  markDone "$stepName"

  sleep 5
}

buildModules() {
  echo "---------------------------------------------------------------"
  echo "Build the modules"

  if stepDone "$buildModules"; then
    echo "Already done"
    return
  fi

  if stepSkipped "$buildModules"; then
    echo "Skipped"
    return
  fi

  if stepStarted "$buildModules"; then
    echo "Restarting from partial build"
  else
    markStarted "$buildModules"
  fi

# For the moment just build it all

  buildModule xsl
  buildModule bwutil
  buildModule bwxml
  buildModule bwutil2
  buildModule notifier
  buildModule tzsvr
  buildModule synch
  buildModule eventreg
  buildModule selfreg
  buildModule deploy

  markDone $buildModules
}

read -p "Enter path or name of empty or new directory: " dirpath

if [ ! -d "$dirpath" ]; then
  mkdir -p "$dirpath"
fi

cd "$dirpath"
dirpath=`pwd`

progressPath="$dirpath/$progressDir"

if ls -1qA "$dirpath" | grep -q .
then
  # It's not empty. Does it contain our progress directory
  if [ -d "$progressPath" ]; then
    if [ "$restart" != "" ] ; then
      echo "Restarting installation of quickstart"
    else
      ! echo "$dirpath is not empty but contains the progress marker."
      ! echo "If you wish to restart the install specify 'restart' when"
      ! echo "running the script"
      exit 1
    fi
  else
    ! echo "$dirpath" is not empty
    exit 1
  fi
else
  mkdir $progressDir
fi

echo "-------------------------------------------------------------"
echo " Building in $dirpath"

echo "Which version"
select version in "dev" "latest"; do
    case $version in
        dev ) break;;
        latest ) version=$latestVersion; break;;
    esac
done

qs="quickstart-$version"
if ! sameVersion $qs ; then
  echo "Cannot restart install for a different version."
  echo "Delete the directory and start again."
  exit 1
fi

markVersion $qs

echo "Do you wish to install the sources?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) markSkipped ${installSources}; break;;
    esac
done

mkdir $qs
cd $qs

qs=`pwd`

echo
echo "Either merge these settings (from profile.txt) into your ~/.m2/settings.xml file"
echo "or create that file with the content"
echo
echo "You need to do this before continuing or subsequent builds will fail."
echo

createProfile

echo
read -p "Hit enter/return to continue" ignore

# -------------------------------------------------------------------
#  Installation starts here
# -------------------------------------------------------------------

downloadWildFly

unpackWildFly

installScripts

installDrivers

installHawtio

installSources

installData

installApacheds

buildModules
