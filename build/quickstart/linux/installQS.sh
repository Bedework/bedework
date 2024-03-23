#! /bin/sh

# Create a bedework quickstart

echo " "
echo " "
echo "***************** Currently out of date"
echo "Use the feature pack install. See https://bedework.github.io/bedework/#featurepack-install"
echo " "
echo " "
exit 1

BASE_DIR=`pwd`
scriptName="$0"
restart=
latestVersion="4.0.3"

bwOptions=$HOME/.bw

if [ -f "$bwOptions" ]; then
  . "$bwOptions"
fi

mvnProfile=${bw_mvnProfile:-"bedework-rel"}

jbossVersion=25.0.1.Final
galleonVersion="4.2.8.Final"
galleonFeaturePack="org.bedework:bw-wf-feature-pack:1.0.0-SNAPSHOT"

bwLayerspg="bw-demo-pg,web-console"
bwLayersh2="bw-demo-h2,web-console"
galleonLayers="$bwLayersh2"

# -------------------Package versions -----------------------------
bwAccessVersion="5.0.0"

bwBedeworkVersion="4.0.0"

bwCaldavVersion="5.0.0"
bwCalendarClientVersion="4.0.2"
bwCalendarCommonVersion="4.0.0"
bwCalendarDeployVersion="4.0.1"
bwCalendarEngineVersion="4.0.0"
bwCalendarXslVersion="4.0.0"
bwCarddavVersion="5.0.0"
bwCategoryVersion="4.0.0"
bwCliVersion="5.0.0"
bwCliutilVersion="5.0.0"

bwEventRegistrationVersion="5.0.1"

bwJsforJVersion="1.1.0"

bwLogsVersion="1.1.1"

bwNotifierVersion="5.0.0"

bwQuickstartVersion="4.0.1"

bwSelfRegistrationVersion="5.0.0"
bwSometimeVersion="2.0.0"
bwSynchVersion="5.0.0"

bwTimezoneServerVersion="5.0.0"

bwUtilLoggingVersion="5.2.0"
bwUtilVersion="5.2.0"
bwUtilConfVersion="5.0.2"
bwUtilDeployVersion="5.0.2"
bwUtilHibernateVersion="5.0.2"
bwUtilIndexVersion="5.0.0"
bwUtilNetworkVersion="5.0.1"
bwUtilTzVersion="5.0.0"
bwUtilSecurityVersion="5.0.0"
bwUtil2Version="5.0.0"

bwWebdavVersion="5.0.0"
bwWfmodulesVersion="1.0.4"
bwWildflyFeaturePackVersion="4.0.3"

bwXmlVersion="5.0.1"

# -------------------Ear locations -----------------------------
mvnrepo="https://repo1.maven.org/maven2/org/bedework/"

trap 'cd $BASE_DIR' 0
trap "exit 2" 1 2 3 15

if [ -z "$JAVA_HOME" ] || [ ! -d "$JAVA_HOME" ] ; then
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

JBOSS_BASE_DIR="wildfly-$jbossVersion"

# We create empty files in this directory to track progress
progressDir="bwinstaller-progress"

# Assigned below
progressPath=

JBOSS_CONFIG="standalone"

# These relative to $qs
JBOSS_SERVER_DIR="$JBOSS_BASE_DIR/$JBOSS_CONFIG"

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
      restart)
        shift
        restart="yes"
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
      <id>bedework-local</id>
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
installWildfly="installWildFly"
installScripts="installScripts"
installSources="installSources"
buildPackages="buildPackages"
indexData="indexData"

# Suffixed with package name
installPackage="installPackage-"
buildPackage="buildPackage-"

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

  ./galleon-$galleonVersion/bin/galleon.sh install $galleonFeaturePack --dir=$JBOSS_BASE_DIR --layers=$galleonLayers

  if [ ! -d "$qs/$TMP_DIR" ]; then
    mkdir -p "$qs"/$TMP_DIR
  fi

  # Add a generic named link to the current wildfly
  cd $qs || { echo "Quickstart directory $qs doesn't exist"; exit 1; }

  ln -s $JBOSS_BASE_DIR wildfly

  read -p "Enter the admin account: " adminId
  read -p "Enter the admin password: " -s adminPw

  ./wildfly/bin/add-user.sh -a -dc wildfly/standalone/configuration -g admin $adminId $adminPw

  markDone $installWildfly
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
    echo "Remove possible partial package"
    rm -rf bedework
    unmark $installScripts
  fi

  markStarted $installScripts

  if [ "$version" = "dev" ] ; then
    cloneRepo bedework
  elif [ "$prerelease" = "yes" ]; then
    cloneRepo bedework
  else
    cloneRepoBranch $latestVersion bedework
  fi

  chmod +x bedework/build/quickstart/linux/qs-scripts/*
  cp bedework/build/quickstart/linux/qs-scripts/* .

  markDone $installScripts
}


# $1 - name
cloneRepo() {
  packageName=$1

  echo "---------------------------------------------------------------"
  echo "Clone $packageName"

  stepName=${installPackage}$packageName

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
    rm -rf "$packageName"
  else
    markStarted "$stepName"
  fi

  echo "git clone https://github.com/Bedework/$packageName.git"
  git clone https://github.com/Bedework/"$packageName".git

  markDone "$stepName"

  sleep 5
}

# $1 - branch
# $2 - name
cloneRepoBranch() {
  packageName=$2

  echo "---------------------------------------------------------------"
  echo "Clone $packageName"

  stepName=${installPackage}$packageName

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
    rm -rf "$packageName"
  else
    markStarted "$stepName"
  fi

  echo "git clone -b $packageName-$1 https://github.com/Bedework/$packageName.git"
  git clone -b "$packageName"-"$1" https://github.com/Bedework/"$packageName".git

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

  if [ "$version" = "dev" ] ; then
    # Bedework below
    cloneRepo bw-access
    cloneRepo bw-caldav
    cloneRepo bw-caldavTest
    cloneRepo bw-calendar-client
    cloneRepo bw-calendar-common
    cloneRepo bw-calendar-deploy
    cloneRepo bw-calendar-engine
    cloneRepo bw-calendar-xsl
    cloneRepo bw-calsockets
    cloneRepo bw-carddav
    cloneRepo bw-category
    cloneRepo bw-cliutil
    cloneRepo bw-cli
    cloneRepo bw-dotwell-known
    cloneRepo bw-event-registration
    cloneRepo bw-jsforj
    cloneRepo bw-logs
    cloneRepo bw-notifier
    cloneRepo bw-quickstart
    cloneRepo bw-self-registration
    cloneRepo bw-synch
    cloneRepo bw-timezone-server
    cloneRepo bw-util
    cloneRepo bw-util-conf
    cloneRepo bw-util-deploy
    cloneRepo bw-util-hibernate
    cloneRepo bw-util-index
    cloneRepo bw-util-logging
    cloneRepo bw-util-network
    cloneRepo bw-util-security
    cloneRepo bw-util-tz
    cloneRepo bw-util2
    cloneRepo bw-webdav
    cloneRepo bw-wfmodules
    cloneRepo bw-wildfly-galleon-feature-packs
    cloneRepo bw-xml
  else
    cloneRepoBranch $bwAccessVersion bw-access
    cloneRepoBranch $bwCaldavVersion bw-caldav
    cloneRepoBranch $bwCalendarClientVersion bw-calendar-client
    cloneRepoBranch $bwCalendarCommonVersion bw-calendar-common
    cloneRepoBranch $bwCalendarDeployVersion bw-calendar-deploy
    cloneRepoBranch $bwCalendarEngineVersion bw-calendar-engine
    cloneRepoBranch $bwCalendarXslVersion bw-calendar-xsl
    cloneRepoBranch $bwCarddavVersion bw-carddav
    cloneRepoBranch $bwCategoryVersion bw-category
    cloneRepoBranch $bwCliutilVersion bw-cliutil
    cloneRepoBranch $bwCliVersion bw-cli

    cloneRepo bw-dotwell-known

    cloneRepoBranch $bwEventRegistrationVersion bw-event-registration

    cloneRepoBranch $bwJsforJVersion bw-jsforj

    cloneRepoBranch $bwLogsVersion bw-logs

    cloneRepoBranch $bwNotifierVersion bw-notifier

    cloneRepoBranch $bwQuickstartVersion bw-quickstart

    cloneRepoBranch $bwSelfRegistrationVersion bw-self-registration
    cloneRepoBranch $bwSynchVersion bw-synch

    cloneRepoBranch $bwTimezoneServerVersion bw-timezone-server

    cloneRepoBranch $bwUtilVersion bw-util
    cloneRepoBranch $bwUtilConfVersion bw-util-conf
    cloneRepoBranch $bwUtilDeployVersion bw-util-deploy
    cloneRepoBranch $bwUtilHibernateVersion bw-util-hibernate
    cloneRepoBranch $bwUtilIndexVersion bw-util-index
    cloneRepoBranch $bwUtilLoggingVersion bw-util-logging
    cloneRepoBranch $bwUtilNetworkVersion bw-util-network
    cloneRepoBranch $bwUtilSecurityVersion bw-util-security
    cloneRepoBranch $bwUtilTzVersion bw-util-tz
    cloneRepoBranch $bwUtil2Version bw-util2

    cloneRepoBranch $bwWebdavVersion bw-webdav
    cloneRepoBranch $bwWfmodulesVersion bw-wfmodules
    cloneRepoBranch $bwWildflyFeaturePackVersion bw-wildfly-galleon-feature-packs

    cloneRepoBranch $bwXmlVersion bw-xml
    #cloneRepo bw-calsockets
  fi

  markDone $installSources
}

# $1 - name
buildPackage() {
  packageName=$1

  echo "---------------------------------------------------------------"
  echo "Build $packageName"

  stepName=${buildPackage}$packageName

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

  ./bw -P "$mvnProfile" "$packageName"

  markDone "$stepName"

  sleep 5
}

buildPackages() {
  echo "---------------------------------------------------------------"
  echo "Build the packages"

  if stepDone "$buildPackages"; then
    echo "Already done"
    return
  fi

  if stepSkipped "$buildPackages"; then
    echo "Skipped"
    return
  fi

  if stepStarted "$buildPackages"; then
    echo "Restarting from partial build"
  else
    markStarted "$buildPackages"
  fi

# For the moment just build it all

  packages="xsl"
  # buildPackage xsl

# These and more get built by the build script
#  buildPackage bwutil
#  buildPackage bwutilhib
#  buildPackage bwxml
#  buildPackage bwutil2

  packages="$packages bwcalclient"
  # buildPackage bwcalclient

# These are the deployable or runnable components
  packages="$packages notifier"
  packages="$packages tzsvr"
  packages="$packages synch"
  packages="$packages eventreg"
  packages="$packages selfreg"
  packages="$packages bwcli"

  # buildPackage notifier
  # buildPackage tzsvr
  # buildPackage synch
  # buildPackage eventreg
  # buildPackage selfreg
  # buildPackage bwcli

  ./bw -P "$mvnProfile" $packages

  # Add some links

  ln -s bw-cli/target/client/bin/client .

  markDone $buildPackages
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
  ./startosch
  ./startwildfly

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

args $*

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
      ! echo "If you wish to restart the install specify '-restart' when"
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

echo "Select the version to install:"
echo "   latest: the latest release ($latestVersion)"
echo "   dev: the current development state of all projects"
echo "   prerelease: the latest release ($latestVersion) "
echo "         except for the bedework project which will be the current dev"

echo "Latest is probably the one you want."
echo "Dev is for serious developers."
echo "Prerelease allows testing of the release before finally committing a release version."
echo ""

prerelease="no"

echo "Which version - dev or latest ($latestVersion)?"
select version in "latest" "dev" "prerelease"; do
    case $version in
        latest ) version=$latestVersion; break;;
        dev ) break;;
        prerelease ) version=$latestVersion; prerelease="yes"; break;;
    esac
done

qs="quickstart-$version"
if ! sameVersion $qs ; then
  echo "Cannot restart install for a different version."
  echo "Delete the directory and start again."
  exit 1
fi

markVersion $qs

echo "A full quickstart with all sources will be installed. This"
echo "equires maven, git and a correct maven profile (one will be"
echo "displayed soon)."
echo ""

doBuild="no"

echo "Do you want a full build of all sources? Yes/No"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) doBuild="yes"; break;;
        No ) markSkipped ${buildPackages}; break;;
    esac
done

echo "Do you want a postgresql (pg) or h2 version (h2)"
select ph in "pg" "h2"; do
    case $ph in
        pg ) galleonLayers="$bwLayerspg"; break;;
        h2 ) galleonLayers="$bwLayersh2"; break;;
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

installScripts

installSources

cd $qs
if [ "$doBuild" = "yes" ] ; then
  buildPackages
fi

indexData
