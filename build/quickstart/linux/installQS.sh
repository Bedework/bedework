#!/usr/bin/env bash

# Create a bedework quickstart

BASE_DIR=`pwd`
scriptName="$0"
restart=
latestVersion="3.13.1"

esDockerPull="docker pull docker.elastic.co/elasticsearch/elasticsearch:7.2.0"
JBOSS_VERSION="17.0.1.Final"
galleonVersion="4.1.0.Final"

# -------------------Module versions -----------------------------
bwUtilLoggingVersion="4.0.4"
bwUtilVersion="4.0.26"
bwUtil2Version="4.0.5"
bwUtilDeployVersion="4.0.25"
bwXmlVersion="4.0.9"
bwUtilHibernateVersion="4.0.22"
bwAccessVersion="4.0.7"
bwWebdavVersion="4.0.8"
bwCaldavVersion="4.0.8"
bwTimezoneServerVersion="4.0.6"
bwSynchVersion="4.0.7"
bwSelfRegistrationVersion="4.0.9"
bwEventRegistrationVersion="4.0.8"
bwNotifierVersion="4.0.9"
bwCliVersion="4.0.8"
bwCarddavVersion="4.0.9"

bwCalendarEngineVersion="3.13.1"
bwCalendarClientVersion="3.13.1"
bwCalendarXslVersion="3.13.1"


trap 'cd $BASE_DIR' 0
trap "exit 2" 1 2 3 15

if [ -z "$JAVA_HOME" -o ! -d "$JAVA_HOME" ] ; then
  echo "JAVA_HOME is not defined correctly for bedework."
  exit 1
fi

# 11 onwards
version=$($JAVA_HOME/bin/java -version 2>&1 | sed -E -n 's/.* version "([^.-]*).*/\1/p')
if [[ "$version" -lt "11" ]]; then
  echo "Java 11 or greater is required for bedework"
  exit 1
fi

#javaVersion=$("$JAVA_HOME/bin/java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
#echo version "$version"
#javaVersion="${javaVersion:2:1}"
#echo "$version"
#if [[ "$javaVersion" -lt "8" ]]; then
#  echo
#  echo "************************************************"
#  echo "*  Java 8 or greater is required for bedework."
#  echo "************************************************"
#  echo
#  exit 1
#fi

JBOSS_BASE_DIR="wildfly-$JBOSS_VERSION"

# We create empty files in this directory to track progress
progressDir="bwinstaller-progress"

# Assigned below
progressPath=

wildflyConfDir="${JBOSS_BASE_DIR}/standalone/configuration"

resources=$BASE_DIR/bedework/build/quickstart

JBOSS_CONFIG="standalone"

# These relative to $qs
JBOSS_SERVER_DIR="$JBOSS_BASE_DIR/$JBOSS_CONFIG"
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
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
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
installWildfly="installWildFly"
installES="installES"
installScripts="installScripts"
installDrivers="installDrivers"
installHawtio="installHawtio"
installSources="installSources"
installData="installData"
installApacheds="installApacheds"
buildModules="buildModules"
updateWildfly="updateWildFly"
indexData="indexData"

# Suffixed with module name
installModule="installModule-"
buildModule="buildModule-"

# -------------------------------------------------------------------
# -------------------------------------------------------------------
# -------------------------------------------------------------------
installWildFly() {
  echo "---------------------------------------------------------------"
  echo "Install wildfly"

  if stepDone $installWildfly; then
    echo "Already done"
    return
  fi

  if stepStarted $installWildfly; then
    echo "Remove possible partial download"
    rm -rf galleon-$galleonVersion*
    rm -rf $JBOSS_BASE_DIR
  fi

  markStarted $installWildfly
# First download galleon

  wget https://github.com/wildfly/galleon/releases/download/$galleonVersion/galleon-$galleonVersion.zip
  unzip galleon-$galleonVersion.zip
  rm galleon-$galleonVersion.zip

  ./galleon-$galleonVersion/bin/galleon.sh install wildfly:17.0#$JBOSS_VERSION --dir=$JBOSS_BASE_DIR --layers=core-server,jms-activemq,core-tools

  if [ ! -d "$qs/$TMP_DIR" ]; then
    mkdir -p $qs/$TMP_DIR
  fi

  mkdir $qs/$JBOSS_DATA_DIR

  # Add a generic named link to the current wildfly
  cd $qs

  ln -s $JBOSS_BASE_DIR wildfly

  read -p "Enter the admin account: " adminId
  read -p "Enter the admin password: " -s adminPw

  ./wildfly/bin/add-user.sh -a -dc wildfly/standalone/configuration -g admin $adminId $adminPw

  markDone $installWildfly
}

# -------------------------------------------------------------------
# -------------------------------------------------------------------
# -------------------------------------------------------------------
installES() {
  echo "---------------------------------------------------------------"
  echo "Install elasticsearch"

  if stepDone $installES; then
    echo "Already done"
    return
  fi

  if stepSkipped $installES; then
    echo "Skipped"
    return
  fi

  if stepStarted $installES; then
    echo "Remove possible partial download"
  fi

  markStarted $installES

  $esDockerPull

  # can be started/stopped with the startES.sh and stopES.sh scripts

  markDone $installES
}

# -------------------------------------------------------------------
# -------------------------------------------------------------------
# -------------------------------------------------------------------
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

  markDone $installScripts
}

# -------------------------------------------------------------------
# -------------------------------------------------------------------
# -------------------------------------------------------------------
installDrivers() {
  echo "---------------------------------------------------------------"
  echo "Install wildfly drivers"

  if stepDone $installDrivers; then
    echo "Already done"
    return
  fi

  if stepStarted $installDrivers; then
    echo "Remove possible partial copy"
    unmark $installDrivers
  fi

  markStarted $installDrivers

  cp -r bedework/build/quickstart/resources/wfmodules/*  ${JBOSS_BASE_DIR}/modules/

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
    rm -r ${JBOSS_BASE_DIR}/standalone/deployments/hawtio.war*
    unmark $installHawtio
  fi

  markStarted $installHawtio

  wget https://github.com/Bedework/bedework-qsdata/releases/download/release-3.12.0/console.zip
  unzip console.zip
  cp console/hawtio.war ${JBOSS_BASE_DIR}/standalone/deployments/
  touch ${JBOSS_BASE_DIR}/standalone/deployments/hawtio.war.dodeploy
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
#    rm -r ${JBOSS_BASE_DIR}/standalone/data
    unmark $installData
  fi

  markStarted $installData

#  wget https://github.com/Bedework/bedework-qsdata/releases/download/release-3.12.0/wfdata.zip
#  unzip wfdata.zip
#  mkdir ${JBOSS_BASE_DIR}/standalone/data
#  cp -r wfdata/* ${JBOSS_BASE_DIR}/standalone/data/
#  rm -rf wfdata
#  rm wfdata.zip
  resources=$qs/bedework/build/quickstart
  mkdir $qs/$bedework_data_dir

  # Unpack here
  cd $qs/$TMP_DIR/

  # ------------------------------------- h2 data

  rm -f h2.zip
  cp $resources/data/h2.zip .
  rm -rf h2/
  unzip h2.zip
  rm -f h2.zip
  rm -rf $qs/$bedework_data_dir/h2
  cp -r h2 $qs/$bedework_data_dir/
  rm -rf h2/

  # ------------------------------------- ES data

  #rm -f elasticsearch.zip
  #rm -rf elasticsearch
  #cp $resources/data/elasticsearch.zip .
  #unzip elasticsearch.zip
  #rm elasticsearch.zip
  #rm -rf $qs/$es_data_dir
  #cp -r elasticsearch $qs/$bedework_data_dir/

  # ------------------------------------- TZ data

  rm -f tzsvr.zip
  rm -rf tzsvr
  cp $resources/data/tzsvr.zip .
  unzip tzsvr.zip
  rm tzsvr.zip
  rm -rf $qs/$bedework_data_dir/tzsvr
  cp -r tzsvr $qs/$bedework_data_dir/

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

  cd $qs

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
    cloneRepo bw-util-deploy
    cloneRepo bw-util-hibernate
    cloneRepo bw-util-logging
    cloneRepo bw-webdav
    cloneRepo bw-xml
  else
    cloneRepoBranch $bwUtilLoggingVersion bw-util-logging
    cloneRepoBranch $bwXmlVersion bw-xml
    cloneRepoBranch $bwUtilVersion bw-util
    cloneRepoBranch $bwUtil2Version bw-util2
    cloneRepoBranch $bwUtilDeployVersion bw-util-deploy
    cloneRepoBranch $bwUtilHibernateVersion bw-util-hibernate
    cloneRepoBranch $bwAccessVersion bw-access
    cloneRepoBranch $bwWebdavVersion bw-webdav
    cloneRepoBranch $bwCaldavVersion bw-caldav
    cloneRepoBranch $bwTimezoneServerVersion bw-timezone-server
    cloneRepoBranch $bwSynchVersion bw-synch
    cloneRepoBranch $bwSelfRegistrationVersion bw-self-registration
    cloneRepoBranch $bwEventRegistrationVersion bw-event-registration
    cloneRepoBranch $bwNotifierVersion bw-notifier
    cloneRepoBranch $bwCliVersion bw-cli
    cloneRepoBranch $bwCarddavVersion bw-carddav
    cloneRepoBranch $bwCalendarEngineVersion bw-calendar-engine
    cloneRepoBranch $bwCalendarClientVersion bw-calendar-client
    cloneRepoBranch $bwCalendarXslVersion bw-calendar-xsl
    #cloneRepo bw-calsockets
    cloneRepo bw-dotwell-known
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


  ./bw "$moduleName"

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
  buildModule bwutilhib
  buildModule bwxml
  buildModule bwutil2
  buildModule notifier
  buildModule tzsvr
  buildModule synch
  buildModule eventreg
  buildModule selfreg
  buildModule bwcli
  buildModule deploy

  # Add some links

  ln -s bw-cli/target/client/bin/client

  markDone $buildModules
}


# -------------------------------------------------------------------
# -------------------------------------------------------------------
# -------------------------------------------------------------------
updateWildFly() {
  echo "---------------------------------------------------------------"
  echo "update wildfly"

  if stepDone $updateWildfly; then
    echo "Already done"
    return
  fi

  if stepStarted $updateWildfly; then
    echo "Remove possible partial download"
  fi

  markStarted $updateWildfly

  cp $qs/bedework/config/standalone.xml ${wildflyConfDir}/

  mkdir $JBOSS_BASE_DIR/standalone/log
  mkdir $JBOSS_BASE_DIR/bedework-content
  cp $qs/bedework/content/resources/bedework.ico $JBOSS_BASE_DIR/bedework-content/favicon.ico
  cp $qs/bedework/content/resources/Error404.html $JBOSS_BASE_DIR/bedework-content/

  markDone $updateWildfly
}

indexData() {
  echo "---------------------------------------------------------------"
  echo "Index data"

  if stepDone $indexData; then
    echo "Already done"
    return
  fi

  if stepSkipped $indexData; then
    echo "Skipped"
    return
  fi

  if stepStarted $indexData; then
    unmark $indexData
  fi

  markStarted $indexData

  cd $qs

  ./starth2
  ./startES
  ./startjboss

  # We should have a test to see if it's up - just wait 30 secs
  sleep 30s

  # Wake it up
  wget http://localhost:8080/cal

  ./client -id $adminId -pw $adminPw <<EOF
rebuildidx
makeidxprod all
listidx
EOF

  markDone $indexData
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

echo "Which version - dev or latest ($latestVersion)?"
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

echo "Do you wish to install and start a docker image of elasticsearch?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) markSkipped ${installES}; markSkipped ${indexData}; break;;
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

installWildFly

installES

installScripts

installDrivers

installHawtio

installSources

installData

installApacheds

cd $qs
buildModules

updateWildFly

indexData
