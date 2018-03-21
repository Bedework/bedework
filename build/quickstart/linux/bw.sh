#! /bin/sh

#
# This file is included by the quickstart script file "bw" so that it can live
# within the svn repository.
#

saveddir=`pwd`

trap 'cd $saveddir' 0
trap "exit 2" 1 2 3 15

export QUICKSTART_HOME=$saveddir

ANT_HOME=`dirname "$PRG"`/apache-ant-1.7.0
ANT_HOME=`cd "$ANT_HOME" && pwd`

#ant_listener="-listener org.apache.tools.ant.listener.Log4jListener"
#ant_xmllogfile="-DXmlLogger.file=log.xml"
#ant_logger="-logger org.apache.tools.ant.XmlLogger"

deployableDir="$QUICKSTART_HOME/bedework/dist/deployable"

ant_listener=
ant_xmllogfile=
ant_logger=

ant_loglevel="-quiet"
bw_loglevel=""
postDeployDebug="";

mvn_quiet=   # "-q"

#mvn_binary="/usr/share/maven/bin/mvn";
mvn_binary="mvn"

maven=

# Projects we need to update - these are the svn projects - not internal variables
# or user parameters.
#updateProjects="access"
updateProjects="bedework"
updateProjects="$updateProjects  bedework-carddav"
updateProjects="$updateProjects  bwannotations"
updateProjects="$updateProjects  bwcalcore"
updateProjects="$updateProjects  bwcaldav"
updateProjects="$updateProjects  bwcalFacade"
#updateProjects="$updateProjects  bwdeployutil"
updateProjects="$updateProjects  bwical"
updateProjects="$updateProjects  bwinterfaces"
updateProjects="$updateProjects  bwsysevents"
#updateProjects="$updateProjects  bwtzsvr"
updateProjects="$updateProjects  bwtools"
updateProjects="$updateProjects  bwwebapps"
# updateProjects="$updateProjects  bwxml"
#updateProjects="$updateProjects  caldav"
updateProjects="$updateProjects  dumprestore"
#updateProjects="$updateProjects  eventreg"
updateProjects="$updateProjects  indexer"
# updateProjects="$updateProjects  rpiutil"
#updateProjects="$updateProjects  selfreg"
#updateProjects="$updateProjects  synch"
#updateProjects="$updateProjects  webdav"

mvnUpdateProjects="bw-notifier"
mvnUpdateProjects="$mvnUpdateProjects  bw-access"
mvnUpdateProjects="$mvnUpdateProjects  bw-caldav"
mvnUpdateProjects="$mvnUpdateProjects  bw-cli"
mvnUpdateProjects="$mvnUpdateProjects  bw-event-registration"
mvnUpdateProjects="$mvnUpdateProjects  bw-self-registration"
mvnUpdateProjects="$mvnUpdateProjects  bw-synch"
mvnUpdateProjects="$mvnUpdateProjects  bw-timezone-server"
mvnUpdateProjects="$mvnUpdateProjects  bw-webdav"
mvnUpdateProjects="$mvnUpdateProjects  bw-calsockets"
mvnUpdateProjects="$mvnUpdateProjects  bw-xml"
mvnUpdateProjects="$mvnUpdateProjects  bw-util"
mvnUpdateProjects="$mvnUpdateProjects  bw-util2"
mvnUpdateProjects="$mvnUpdateProjects  bw-cache-proxy"

# Projects we will build - pkgdefault (bedework) is built if nothing specified
pkgdefault=yes
access=
bedework=
bwannotations=
bwcalcore=
bwcaldav=
bwcalfacade=
bwcli=
bwdeployutil=
bwicalendar=
bwinterfaces=
bwnotifier=
bwsysevents=
bwtools=
bwwebapps=
bwcalsockets=
bwxml=
caldav=
caldavTest=
carddav=
catsvr=
client=
dumprestore=
eventreg=
exchgGateway=
geronimoHib=
indexer=
naming=
bwutil=
bwutil2=
selfreg=
synch=
testsuite=
tzsvr=
webdav=

# Special targets - avoiding dependencies

cmdutil=
deployer=
deploylog4j=
deploywf=
deployConf=
deployData=
deployDotWellKnown=
deployWebcache=
dirstart=
saveData=

specialTarget=

dobuild=yes
earName=
warNames=
deployEarsUrl=

mavenRepoLocal=

earNameDefault="bwcal"
earNameCacheProxy="bw-cache"
earNameCarddav="bw-carddav"
#earNameEventreg="bw-eventreg"
earNameNotifier="bw-notifier"
#earNameSelfreg="bw-selfreg"
#earNameSynch="bw-synch"
#earNameTzsvr="bw-tzsvr"
# earNameXml="bw-xml"

# warnamescalsockets="pubcalwskt,ucalwskt"

appserver="-Dorg.bedework.target.appserver=wildfly"

echo ""
echo "  Bedework Calendar System"
echo "  ------------------------"
echo ""

PRG="$0"

usage() {
  echo "The build and deploy process is changed from previous releases."
  echo ""
  echo "Nearly all configuration is handled by the run-time configuration"
  echo "files deployed with the "
  echo "   deployConf "
  echo "target. That target should be executed ONCE only after download "
  echo "to copy a set of config files into jboss."
  echo ""
  echo "A small amount of post-build configuration may be needed. This "
  echo "allows you to set the security-domain, transport guarantees, "
  echo "virtual hosts and add or remove calendar suites."
  echo "See"
  echo "http://wiki.jasig.org/display/BWK310/Configuring+Bedework"
  echo ""
  echo "  $PRG ACTION"
  echo "  $PRG [CONFIG-SOURCE] [PROJECT] [ -offline ] [-appserver=<server>]"
  echo "              [LOG_LEVEL] [ target ] "
  echo ""
  echo " where:"
  echo ""
  echo "   ACTION defines an action to take usually in the context of the quickstart."
  echo "    In a deployed system many of these actions are handled directly by a"
  echo "    deployed application. ACTION may be one of"
  echo "      -updateall  Does an svn update of all projects"
  echo ""
  echo "   CONFIG-SOURCE optionally defines the location of configurations and is"
  echo "     -dc      to specify the location of the deploy properties"
  echo "   The default is in bedework/config/deploy.properties."
  echo ""
  echo "   -offline     Build without attempting to retrieve library jars"
  echo ""
  echo "   -appserver=wildfly Build for wildfly - the default"
  echo "   -appserver=jboss5  Build for jboss 5"
  echo ""
  echo "   LOG_LEVEL sets the level of logging and can be"
  echo "      -log-silent   Nearly silent"
  echo "      -log-quiet    The default"
  echo "      -log-inform   A little more noisy"
  echo "      -log-verbose  Noisier"
  echo "      -log-configs  Some info about configurations"
  echo "      -ant-debug    Vast amounts of ant output"
  echo "      -build-debug  Some bedework build debug output"
  echo ""
  echo "   target       Special target or Ant target to execute"
  echo ""
  echo "   Special targets"
  echo "      deployer          builds the deployer"
  echo "      deploylog4j       deploys a log4j configuration"
  echo "      deploywf          deploys wildfly configuration"
  echo "      deployConf        deploys the configuration files"
  echo ""
  echo "   PROJECT optionally defines the package to build. If omitted the main"
  echo "           bedework calendar system will be built otherwise it is one of"
  echo "           the core, ancillary or experimental targets below:"
  echo ""
  echo "   Core sub-projects: required for a functioning system"
  echo "     -access       Target is for the access classes"
  echo "     -bwann        Target is for the annotation classes"
  echo "     -bwcalcore    Target is for the bedework core api implementation"
  echo "     -bwcaldav     Target is for the bedework CalDAV implementation"
  echo "     -bwcalfacade  Target is for the bedework api interface classes"
  echo "     -bwicalendar  Target is for the bedework icalendar classes"
  echo "     -bwinterfaces Target is for the bedework service and api interfaces"
  echo "     -bwsysevents  Target is for the system JMS event classes"
  echo "     -bwwebapps    Target is for the bedework web ui classes"
  echo "     -bwcalsockets Target is for the bedework calsockets classes"
  echo "     -bwxml        Target is for the Bedework XML schemas build"
  echo "                        (usually built automatically be dependent projects"
  echo "     -caldav       Target is for the generic CalDAV server"
  echo "     -carddav      Target is for the CardDAV build"
  echo "     -carddav deploy-addrbook    To deploy the Javascript Addressbook client."
  echo "     -dumprestore  Target is for the Bedework dump/restore service"
  echo "     -eventreg     Target is for the event registration service build"
  echo "     -indexer      Target is for the Bedework indexer service"
  echo "     -notifier     Target is the Bedework notification service"
  echo "     -bwutil       Target is for the Bedework util classes"
  echo "     -bwutil2      Target is for the Bedework util2 classes"
  echo "     -selfreg      Target is for the self registration build"
  echo "     -synch        Target is for the synch build"
  echo "     -tzsvr        Target is for the timezones server build"
  echo "     -webdav       Target is for the WebDAV build"
  echo "   Ancillary projects: not required"
  echo "     -bwtools      Target is for the Bedework tools build"
  echo "     -caldavTest   Target is for the CalDAV Test build"
  echo "     -deployutil   Target is for the Bedework deployment classes"
  echo "     -testsuite    Target is for the bedework test suite"
  echo "   Experimental projects: no guarantees"
  echo "     -catsvr       Target is for the Catsvr build"
  echo "     -client       Target is for the bedework client application build"
  echo "     -naming       Target is for the abstract naming api"
  echo ""
  echo "   Invokes ant to build or deploy the Bedework system. Uses a configuration"
  echo "   directory which contains one directory per configuration."
  echo ""
  echo "   Within each configuration directory we expect a file called build.properties"
  echo "   which should point to the property and options file needed for the deploy process"
  echo ""
  echo "   In general these files will be in the same directory as build.properties."
  echo "   The environment variable BEDEWORK_CONFIG contains the path to the current"
  echo "   configuration directory and can be used to build a path to the other files."
  echo ""
}

errorUsage() {
  echo "*******************************************************************************************"
  echo "Error: $1"
  echo "*******************************************************************************************"
  echo
  echo "Sleeping 5 seconds before displaying usage. Safe to ctrl-C."
  sleep 5
  echo ""
  usage
  exit 1
}

# $1 - target directory
# $2 - ear name without version or ".ear"
# Used to copy out of the maven world into our deployable directory
copyDeployable() {
  basedir=$1
#  echo "copyDeployable par 1 = $1"
#  echo "copyDeployable par 2 = $2"

  for dir in "$basedir"/$2*; do
    if test -d "$dir"; then
#      echo "copyDeployable dir = $dir"

      mkdir -p $deployableDir
      rm -r $deployableDir/$2*.ear
      echo "cp -r $dir $deployableDir/$(basename $dir).ear"
      cp -r $dir $deployableDir/$(basename $dir).ear
    fi
  done
}

# ----------------------------------------------------------------------------
# Update the projects
# ----------------------------------------------------------------------------
actionUpdateall() {
  for project in $updateProjects
  do
    if [ ! -d "$project" ] ; then
      echo "*********************************************************************"
      echo "Project $project is missing. Check it out from the repository"
      echo "*********************************************************************"
      exit 1
    else
      echo "*********************************************************************"
      echo "Updating project $project"
      echo "*********************************************************************"
      svn cleanup $project
      svn update --non-interactive --trust-server-cert $project
    fi
  done

  for project in $mvnUpdateProjects
  do
    if [ ! -d "$QUICKSTART_HOME/$project" ] ; then
      echo "*********************************************************************"
      echo "Project $project is missing. Check it out from the repository"
      echo "Continuing build"
      echo "*********************************************************************"
    else
      echo "*********************************************************************"
      echo "Updating project $QUICKSTART_HOME/$project"
      echo "*********************************************************************"
      cd $project
      git pull
      cd $QUICKSTART_HOME
    fi
  done

  exit 0
}

# Change to the next project to build. Exit if we're done.
# The order below reflects the dependencies
setDirectory() {
  specialTarget=
  postDeploy=
  postDeployWars=
  maven=

#     Special targets
    if [ "$dirstart" != "" ] ; then
      cd $QUICKSTART_HOME
      specialTarget=dirstart
      dirstart=
      return
    fi

    if [ "$deployer" != "" ] ; then
      cd $QUICKSTART_HOME
      specialTarget=deployer
      deployer=
      return
    fi

    if [ "$deploylog4j" != "" ] ; then
      cd $QUICKSTART_HOME
      specialTarget=deploylog4j
      deploylog4j=
      return
    fi

    if [ "$deploywf" != "" ] ; then
      cd $QUICKSTART_HOME
      specialTarget=deploywf
      deploywf=
      return
    fi

  if [ "$deployConf" != "" ] ; then
    cd $QUICKSTART_HOME
    specialTarget=deployConf
    deployConf=
    return
  fi

  if [ "$deployDotWellKnown" != "" ] ; then
    cd $QUICKSTART_HOME
    specialTarget=deployDotWellKnown
    deployDotWellKnown=
    return
  fi

  if [ "$deployWebcache" != "" ] ; then
    cd $QUICKSTART_HOME
    specialTarget=deployWebcache
    deployWebcache=
    return
  fi

  if [ "$deployData" != "" ] ; then
    cd $QUICKSTART_HOME
    specialTarget=deployData
    deployData=
    return
  fi

  if [ "$saveData" != "" ] ; then
    cd $QUICKSTART_HOME
    specialTarget=saveData
      saveData=
    return
  fi

#     projects

	if [ "$bwnotifier" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-notifier
      bwnotifier=
      maven=yes
      #deploy="$QUICKSTART_HOME/bw-notifier/bw-note-ear/target/"
	  return
	fi

	if [ "$bwdeployutil" != "" ] ; then
	  cd $QUICKSTART_HOME/bwdeployutil
      bwdeployutil=
	  return
	fi

	if [ "$bwutil" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-util
      bwutil=
      maven=yes
	  return
	fi

	if [ "$bwxml" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-xml
      bwxml=
      maven=yes
	  return
	fi

	if [ "$bwutil2" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-util2
      bwutil2=
      maven=yes
	  return
	fi

	if [ "$access" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-access
      access=
      maven=yes
	  return
	fi

	if [ "$eventreg" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-event-registration
      eventreg=
      maven=yes
	  return
	fi

	if [ "$webdav" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-webdav
      webdav=
      maven=yes
	  return
	fi

	if [ "$caldav" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-caldav
      caldav=
      maven=yes
	  return
	fi

	if [ "$caldavTest" != "" ] ; then
	  cd $QUICKSTART_HOME/caldavTest
      caldavTest=
	  return
	fi

	if [ "$carddav" != "" ] ; then
	  cd $QUICKSTART_HOME/bedework-carddav
      carddav=
	  return
	fi

	if [ "$bwannotations" != "" ] ; then
	  cd $QUICKSTART_HOME/bwannotations
      bwannotations=
	  return
	fi

	if [ "$bwcalfacade" != "" ] ; then
	  cd $QUICKSTART_HOME/bwcalFacade
      bwcalfacade=
	  return
	fi

	if [ "$bwcli" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-cli
      bwcli=
      maven=yes
	  return
	fi

	if [ "$bwinterfaces" != "" ] ; then
	  cd $QUICKSTART_HOME/bwinterfaces
      bwinterfaces=
	  return
	fi

	if [ "$bwsysevents" != "" ] ; then
	  cd $QUICKSTART_HOME/bwsysevents
      bwsysevents=
	  return
	fi

	if [ "$bwicalendar" != "" ] ; then
	  cd $QUICKSTART_HOME/bwical
      bwicalendar=
	  return
	fi

	if [ "$bwwebapps" != "" ] ; then
	  cd $QUICKSTART_HOME/bwwebapps
      bwwebapps=
	  return
	fi

	if [ "$bwcaldav" != "" ] ; then
	  cd $QUICKSTART_HOME/bwcaldav
      bwcaldav=
	  return
	fi

	if [ "$bwcalcore" != "" ] ; then
	  cd $QUICKSTART_HOME/bwcalcore
      bwcalcore=
	  return
	fi

	if [ "$catsvr" != "" ] ; then
	  cd $QUICKSTART_HOME/catsvr
      catsvr=
	  return
	fi

	if [ "$client" != "" ] ; then
	  cd $QUICKSTART_HOME/bwclient
      client=
	  return
	fi

	if [ "$bwtools" != "" ] ; then
	  cd $QUICKSTART_HOME/bwtools
      bwtools=
	  return
	fi

	if [ "$indexer" != "" ] ; then
	  cd $QUICKSTART_HOME/indexer
      indexer=
	  return
	fi

	if [ "$dumprestore" != "" ] ; then
	  cd $QUICKSTART_HOME/dumprestore
      dumprestore=
	  return
	fi

	if [ "$bwcalsockets" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-calsockets
    bwcalsockets=
      maven=yes
	  return
	fi

	if [ "$bedework" != "" ] ; then
	  cd $QUICKSTART_HOME
      bedework=
	  return
	fi

	if [ "$naming" != "" ] ; then
	  cd $QUICKSTART_HOME/bwnaming
      naming=
	  return
	fi

	if [ "$exchgGateway" != "" ] ; then
	  cd $QUICKSTART_HOME/exchgGateway
      exchgGateway=
	  return
	fi

	if [ "$selfreg" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-self-registration
      selfreg=
      maven=yes
	  return
	fi

  if [ "$synch" != "" ] ; then
    cd $QUICKSTART_HOME/bw-synch
      synch=
      maven=yes
    return
  fi

	if [ "$testsuite" != "" ] ; then
	  cd $QUICKSTART_HOME/testsuite
      testsuite=
	  return
	fi

	if [ "$tzsvr" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-timezone-server
      tzsvr=
      maven=yes
	  return
	fi

	if [ "$earName" != "" ] ; then
	  cd $QUICKSTART_HOME
      postDeploy="$earName"
      earName=
      if [ "$deploy" != "" ] ; then
        copyDeployable "$deploy" "$postDeploy"
      fi
	  return
	fi

	if [ "$warNames" != "" ] ; then
	  cd $QUICKSTART_HOME
      postDeployWars="$warNames"
      warNames=
#      if [ "$deploy" != "" ] ; then
#        copyDeployable "$deploy" "$postDeploy"
#      fi
	  return
	fi

# Nothing left to do
    echo "Finished at $(date)"
	exit 0;
}

if [ -z "$JAVA_HOME" -o ! -d "$JAVA_HOME" ] ; then
  errorUsage "JAVA_HOME is not defined correctly for bedework."
fi

version=$("$JAVA_HOME/bin/java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
#echo version "$version"
#echo "${version:0:3}"
java8plus=false
if [[ "${version:0:3}" > "1.7" ]]; then
  java8plus=true
fi

CLASSPATH=$ANT_HOME/lib/ant-launcher.jar
CLASSPATH=$CLASSPATH:$QUICKSTART_HOME/bedework/build/quickstart/antlib

# Default some parameters

BWCONFIGS=
BWJMXCONFIG=
bwc=default
BWCONFIG=
offline=
deployConfig=

action=

if [ "$1" = "" ] ; then
  usage
  exit 1
fi

if [ "$1" = "?" ] ; then
  usage
  exit 1
fi

# look for actions first

if [ "$1" = "-updateall" ] ; then
  actionUpdateall
fi

# ----------------------------------------------------------------------------
#  Here we go through looking for arguments.
#
#  Look further down for where we are specifying projects to build. I've
#  not tried specifying more than one but I think it would work.
#
#  There's a hidden default project "bedework" which you get if you don't specify
#  any of the below projects. That gets turned off by each of them  with
#        pkgdefault=
#  Each also turns on it's own project build and any dependencies it has.
#  Further up in this file is where we build each project that has been turned
#  on. That processing is done in dependency order. Of course this whole process
#  fails if we ever build in a circular dependency - that's why it's important to
#  do a clean build fairly regularly. So as an example
#   -webdav)
#      webdav="yes"
#
#      access="yes"
#      bwxml="yes"
#      bwutil="yes"
#      pkgdefault=
#  Turns on the webdav build and also access, bwxml and bwutil because it depends
#  on them.
# ----------------------------------------------------------------------------

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
    -mrl)
      shift
      mavenRepoLocal="$1"
      shift
      ;;
    -dc)
      shift
      deployConfig="$1"
      shift
      ;;
    -bwjmxconf)
      shift
      BWJMXCONFIG="$1"
      shift
      ;;
    -nobuild)
      dobuild="no"
      shift
      ;;
    -deployUrl)
      shift
      deployEarsUrl="$1"
      shift
      ;;
    -offline)
      offline="-Dorg.bedework.offline.build=yes"
      shift
      ;;
    -wildfly)
      bwc="wildfly"
      appserver="-Dorg.bedework.target.appserver=wildfly"
      deployConfig=./bedework/config/wildfly.deploy.properties
      shift
      ;;
    -appserver)
      shift
      appserver="-Dorg.bedework.target.appserver=$1"
      shift
      ;;
# ----------------------- Log level
    -log-silent)
      ant_loglevel="-quiet"
      bw_loglevel="-Dorg.bedework.build.silent=true"
      shift
      ;;
    -log-quiet)
      ant_loglevel="-quiet"
      bw_loglevel=""
      shift
      ;;
    -log-inform)
      ant_loglevel=""
      bw_loglevel="-Dorg.bedework.build.inform=true"
      shift
      ;;
    -log-verbose)
      ant_loglevel="-verbose"
      bw_loglevel="-Dorg.bedework.build.inform=true -Dorg.bedework.build.noisy=true"
      shift
      ;;
    -log-configs)
      bw_loglevel="$bw_loglevel -Dorg.bedework.build.showconfigs=true"
      shift
      ;;
    -ant-debug)
      ant_loglevel="-debug"
      shift
      ;;
    -pd-debug)
      postDeployDebug=" --debug "
      shift
      ;;
    -build-debug)
      bw_loglevel="-Dorg.bedework.build.inform=true -Dorg.bedework.build.noisy=true -Dorg.bedework.build.debug=true "
      shift
      ;;
# ------------------------Special targets
    cmdutil)
    cmdutil="yes"
      pkgdefault=
      shift
      ;;
    deployer)
	  deployer="yes"
      pkgdefault=
      shift
      ;;
    deploylog4j)
	  deploylog4j="yes"
      pkgdefault=
      shift
      ;;
    deploywf)
	  deploywf="yes"
      pkgdefault=
      shift
      ;;
  deployConf)
    deployConf="yes"
      pkgdefault=
      shift
      ;;
  deployDotWellKnown)
    deployDotWellKnown="yes"
      pkgdefault=
      shift
      ;;
  deployWebcache)
    deployWebcache="yes"
      pkgdefault=
      shift
      ;;
  deployData)
    deployData="yes"
      pkgdefault=
      shift
      ;;
  dirstart)
	  dirstart="yes"
      pkgdefault=
      shift
      ;;
  saveData)
    saveData="yes"
      pkgdefault=
      shift
      ;;
# ------------------------Projects
    -access)
      access="yes"

      bwxml="yes"
      bwutil="yes"
      pkgdefault=
      shift
      ;;
    -bwann)
      bwannotations="yes"
      pkgdefault=
      shift
      ;;
    -bwcaldav)
      bwcaldav="yes"

      access="yes"
      bwannotations="yes"
      bwcalfacade="yes"
      bwicalendar="yes"
      bwinterfaces="yes"
      bwsysevents="yes"
      bwxml="yes"
      caldav="yes"
      bwutil="yes"
      bwutil2="yes"
      webdav="yes"
      pkgdefault=
      shift
      ;;
    -bwcalcore)
      bwcalcore="yes"

      access="yes"
      bwannotations="yes"
      bwcalfacade="yes"
      bwicalendar="yes"
      bwinterfaces="yes"
      bwsysevents="yes"
      bwxml="yes"
      caldav="yes"
      bwutil="yes"
      bwutil2="yes"
      webdav="yes"
      pkgdefault=
      shift
      ;;
    -bwcalfacade)
      bwcalfacade="yes"

      access="yes"
      bwannotations="yes"
      bwxml="yes"
      caldav="yes"
      bwutil="yes"
      bwutil2="yes"
      webdav="yes"
      pkgdefault=
      shift
      ;;
    -bwcli)
      bwcli="yes"

      bwutil="yes"
      bwutil2="yes"
      pkgdefault=
      shift
      ;;
    -bwicalendar)
      bwicalendar="yes"

      bwannotations="yes"
      bwcalfacade="yes"
      bwxml="yes"

      pkgdefault=
      shift
      ;;
    -bwinterfaces)
      bwinterfaces="yes"

      access="yes"
      bwannotations="yes"
      bwcalfacade="yes"
      bwxml="yes"
      caldav="yes"
      bwutil="yes"
      bwutil2="yes"
      webdav="yes"

      pkgdefault=
      shift
      ;;
    -notifier)
      bwnotifier="yes"
      #earName="$earNameNotifier"
      pkgdefault=
      shift
      ;;
    -bwsysevents)
      bwsysevents="yes"

      bwinterfaces="yes"
      bwutil="yes"
      pkgdefault=
      shift
      ;;
    -bwtools)
      bwtools="yes"

      bwannotations="yes"
      bwcalfacade="yes"
      bwinterfaces="yes"
      bwxml="yes"
      bwutil="yes"
      bwutil2="yes"
      pkgdefault=
      shift
      ;;
    -bwwebapps)
      bwwebapps="yes"

      access="yes"
      bwannotations="yes"
      bwcalfacade="yes"
      bwicalendar="yes"
      bwinterfaces="yes"
      bwxml="yes"
      caldav="yes"
      bwutil="yes"
      bwutil2="yes"
      webdav="yes"

      pkgdefault=
      shift
      ;;
    -bwcalsockets)
      bwcalsockets="yes"
      #warNames="$warnamescalsockets"

      access="yes"
      bwxml="yes"
      bwutil="yes"

      pkgdefault=
      shift
      ;;

    -bwxml)
      bwxml="yes"
      #earName="$earNameXml"
      pkgdefault=
      shift
      ;;
    -caldav)
      caldav="yes"

      access="yes"
      bwxml="yes"
      bwutil="yes"
      webdav="yes"
      pkgdefault=
      shift
      ;;
    -caldavTest)
      caldavTest="yes"

      access="yes"
      bwxml="yes"
      bwutil="yes"
      bwutil2="yes"
      webdav="yes"
      pkgdefault=
      shift
      ;;
    -carddav)
      carddav="yes"
      earName="$earNameCarddav"

      access="yes"
      bwxml="yes"
      bwutil="yes"
      bwutil2="yes"
      webdav="yes"
      pkgdefault=
      shift
      ;;
    -catsvr)
      catsvr="yes"

      access="yes"
      bwxml="yes"
      bwutil="yes"
      webdav="yes"
      pkgdefault=
      shift
      ;;
    -client)
      client="yes"
      pkgdefault=
      shift
      ;;
    -deployutil)
      bwdeployutil="yes"

      pkgdefault=
      shift
      ;;
    -dumprestore)
      dumprestore="yes"

      access="yes"
      bwannotations="yes"
      bwcalcore="yes"
      bwcalfacade="yes"
      bwicalendar="yes"
      bwinterfaces="yes"
      bwsysevents="yes"
      indexer="yes"
      bwutil="yes"
      bwutil2="yes"
      pkgdefault=
      shift
      ;;
    -eventreg)
      eventreg="yes"
      #earName="$earNameEventreg"

      bwxml="yes"
      bwutil="yes"
      bwutil2="yes"
      pkgdefault=
      shift
      ;;
    -indexer)
      indexer="yes"

      access="yes"
      bwannotations="yes"
      bwcalcore="yes"
      bwcalfacade="yes"
      bwicalendar="yes"
      bwinterfaces="yes"
      bwsysevents="yes"
      bwutil="yes"
      bwutil2="yes"
      pkgdefault=
      shift
      ;;
    -naming)
      naming="yes"
      pkgdefault=
      shift
      ;;
    -bwutil)
      bwutil="yes"

      pkgdefault=
      shift
      ;;
    -bwutil2)
      bwutil2="yes"

      bwxml="yes"
      pkgdefault=
      shift
      ;;
    -exchgGateway)
      exchgGateway="yes"

#      access="yes"
      bwxml="yes"
#      bwutil="yes"
      pkgdefault=
      shift
      ;;
    -selfreg)
      selfreg="yes"
      #earName="$earNameSelfreg"

      bwutil="yes"
      pkgdefault=
      shift
      ;;
    -synch)
      synch="yes"
      #earName="$earNameSynch"

      access="yes"
      bwxml="yes"
      bwutil="yes"
      bwutil2="yes"
      pkgdefault=
      shift
      ;;
    -testsuite)
      testsuite="yes"

      pkgdefault="yes"
      shift
      ;;
    -tzsvr)
      tzsvr="yes"

      bwxml="yes"
      bwutil="yes"
      bwutil2="yes"
      pkgdefault=
      shift
      ;;
    -webdav)
      webdav="yes"

      access="yes"
      bwutil="yes"
      pkgdefault=
      shift
      ;;
    -*)
      usage
      exit 1
      ;;
    *)
      # Assume we've reached the target(s)
      break
      ;;
  esac
done

if [ "$pkgdefault" = "yes" ] ; then
  bedework="yes"
  earName="$earNameDefault"

  access="yes"
  bwannotations="yes"
  bwcalcore="yes"
  bwcaldav="yes"
  bwcalfacade="yes"
  bwicalendar="yes"
  bwinterfaces="yes"
  bwsysevents="yes"
  bwtools="yes"
  bwwebapps="yes"
  bwxml="yes"
  caldav="yes"
  dumprestore="yes"
  indexer="yes"
  bwutil="yes"
  bwutil2="yes"
  webdav="yes"
fi

BWCONFIGS=$QUICKSTART_HOME/bedework/config/bwbuild

if [ "$BWJMXCONFIG" = "" ] ; then
  BWJMXCONFIG=$QUICKSTART_HOME/bedework/config/bedework
fi

export BEDEWORK_CONFIGS_HOME=$BWCONFIGS
export BEDEWORK_CONFIG=$BWCONFIGS/$bwc
export BEDEWORK_JMX_CONFIG=$BWJMXCONFIG

if [ ! -d "$BEDEWORK_CONFIGS_HOME/.platform" ] ; then
  errorUsage "Configurations directory $BEDEWORK_CONFIGS_HOME is missing directory '.platform'."
fi

if [ ! -d "$BEDEWORK_CONFIGS_HOME/.defaults" ] ; then
  errorUsage "Configurations directory $BEDEWORK_CONFIGS_HOME is missing directory '.defaults'."
fi

if [ ! -f "$BEDEWORK_CONFIG/build.properties" ] ; then
  errorUsage "Configuration $BEDEWORK_CONFIG does not exist or is not a bedework configuration."
fi

# Make available for ant
export BWCONFIG="-Dorg.bedework.build.properties=$BEDEWORK_CONFIG/build.properties"
export QUICKSTART_HOME

echo "BWCONFIGS=$BWCONFIGS"
echo "BWCONFIG=$BWCONFIG"

javacmd="$JAVA_HOME/bin/java -classpath $CLASSPATH"
# Build (of bwxml) blew up with permgen error
if [ "$java8plus" = "true" ] ; then
  javacmd="$javacmd -Xmx512M -XX:MaxMetaspaceSize=512m"
else
  javacmd="$javacmd -Xmx512M -XX:MaxPermSize=512M"
fi

javacmd="$javacmd $ant_xmllogfile $offline $appserver"
javacmd="$javacmd -Dant.home=$ANT_HOME org.apache.tools.ant.launch.Launcher"
javacmd="$javacmd $BWCONFIG"
javacmd="$javacmd $ant_listener $ant_logger $ant_loglevel $bw_loglevel"
javacmd="$javacmd -lib $QUICKSTART_HOME/bedework/build/quickstart/antlib"

if [ "$mavenRepoLocal" != "" ] ; then
  javacmd="$javacmd -Dorg.bedework.appserver.repository.dir=$mavenRepoLocal"
fi

mvncmd=

if [ "$1" = "clean" ] ; then
  mvncmd="$mvn_binary -P bedework-3 clean"
else
  mvncmd="$mvn_binary $mvn_quiet -P bedework-3 -Dmaven.test.skip=true install"
fi

echo "mvncmd = $mvncmd"

if [ "$maven" = "" ] ; then
  # We do the deploy
  if [ "$deployConfig" = "" ] ; then
    deployConfig=./bedework/config/wildfly.deploy.properties
  fi

  postDeploycmd="./bw-util/bw-util-bw-deploy/target/rundeploy/bin/rundeploy $postDeployDebug--noversion --delete"

  if [ "$deployEarsUrl" != "" ] ; then
    postDeploycmd="$postDeploycmd --inurl $deployEarsUrl"
  fi

  postDeploycmd="$postDeploycmd --baseDir $QUICKSTART_HOME"

  postDeploycmd="$postDeploycmd --props $deployConfig"

  postDeploycmd="$postDeploycmd --in ./bedework/dist/deployable"

  postDeploycmd="$postDeploycmd --out ./bedework/dist/deployableModified"
fi

while true
do
  setDirectory

  #echo "!!! postDeploy=$postDeploy postDeployWars=$postDeployWars "
  #echo "!!! warNames=$warNames earName=$earName "

  if [ "$specialTarget" != "" ] ; then
    # echo "Special target - command is $javacmd $specialTarget"
    $javacmd $specialTarget
  elif [ "$maven" != "" ] ; then
    echo "mvncmd = $mvncmd"
    $mvncmd
    if [ "$?" -ne 0 ]; then
        echo "Maven build unsuccessful"
        exit 1
    fi
  elif [ "$postDeploy" != "" ] ; then
    # Don't do this if bedework/dist does not exist. Probably a clean
    if [ -d "./bedework/dist/" ] ; then
      echo "$postDeploycmd --ear $postDeploy"
      $postDeploycmd --ear $postDeploy
    fi
  elif [ "$postDeployWars" != "" ] ; then
    # Don't do this if bedework/dist does not exist. Probably a clean
    if [ -d "./bedework/dist/" ] ; then
      echo "$postDeploycmd --war $postDeployWars"
      $postDeploycmd --war $postDeployWars
    fi
  elif [ "$dobuild" = "yes" ] ; then
#    echo $javacmd $*
    $javacmd $*
    if [ "$?" -ne 0 ]; then
        echo "Java build unsuccessful"
        exit 1
    fi
  fi
done

