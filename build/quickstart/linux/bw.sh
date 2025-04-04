#! /bin/bash

#
# This file is included by the quickstart script file "bw" so that it can live
# within the svn repository.
#

saveddir=$(pwd)

trap 'cd $saveddir' 0
trap "exit 2" 1 2 3 15

export QUICKSTART_HOME=$saveddir

bwOptions=$HOME/.bw

if [ -f "$bwOptions" ]; then
  . "$bwOptions"
fi

bw_loglevel=""
postDeployDebug="";

mvn_quiet=   # "-q"
mvnProfile=${bw_mvnProfile:-}
echoOnly=false

#mvn_binary="/usr/share/maven/bin/mvn";
mvn_binary="mvn"

bedeworkProjects="bedework"
bedeworkProjects="$bedeworkProjects  bw-access"
bedeworkProjects="$bedeworkProjects  bw-cache-proxy"
bedeworkProjects="$bedeworkProjects  bw-caldav"
bedeworkProjects="$bedeworkProjects  bw-calendar-client"
bedeworkProjects="$bedeworkProjects  bw-calendar-common"
bedeworkProjects="$bedeworkProjects  bw-calendar-engine"
bedeworkProjects="$bedeworkProjects  bw-calsockets"
bedeworkProjects="$bedeworkProjects  bw-carddav"
bedeworkProjects="$bedeworkProjects  bw-cli"
bedeworkProjects="$bedeworkProjects  bw-cliutil"
bedeworkProjects="$bedeworkProjects  bw-deploy"
bedeworkProjects="$bedeworkProjects  bw-dotwell-known"
bedeworkProjects="$bedeworkProjects  bw-event-registration"
bedeworkProjects="$bedeworkProjects  bw-jsforj"
bedeworkProjects="$bedeworkProjects  bw-logs"
bedeworkProjects="$bedeworkProjects  bw-notifier"
bedeworkProjects="$bedeworkProjects  bw-self-registration"
bedeworkProjects="$bedeworkProjects  bw-synch"
bedeworkProjects="$bedeworkProjects  bw-timezone-server"
bedeworkProjects="$bedeworkProjects  bw-util"
bedeworkProjects="$bedeworkProjects  bw-util-conf"
bedeworkProjects="$bedeworkProjects  bw-util-deploy"
bedeworkProjects="$bedeworkProjects  bw-util-hibernate"
bedeworkProjects="$bedeworkProjects  bw-util-index"
bedeworkProjects="$bedeworkProjects  bw-util-logging"
bedeworkProjects="$bedeworkProjects  bw-util-network"
bedeworkProjects="$bedeworkProjects  bw-util-security"
bedeworkProjects="$bedeworkProjects  bw-util-tz"
bedeworkProjects="$bedeworkProjects  bw-util2"
bedeworkProjects="$bedeworkProjects  bw-webdav"
bedeworkProjects="$bedeworkProjects  bw-wfmodules"
bedeworkProjects="$bedeworkProjects  bw-xml"

# Projects we will build
buildall=
access=
bedework=
bwcal=
bwcalclient=
bwcalcommon=
bwcaleng=
bwcalsockets=
bwcli=
bwcliutil=
bwdeploy=
bwlogs=
bwnotifier=
bwutil=
bwutilconf=
bwutilnetwork=
bwutilsecurity=
bwutiltz=
bwutilindex=
bwutilhib=
bwutil2=
bwutildeploy=
bwutillog=
bwxml=
caldav=
caldavTest=
carddav=
catsvr=
client=
dotWellKnown=
eventreg=
exchgGateway=
jsforj=
naming=
selfreg=
synch=
testsuite=
tzsvr=
webdav=
wfmodules=
xsl=

# Special targets - avoiding dependencies

deployConf=

specialTarget=

mavenRepoLocal=

echo ""
echo "  Bedework Calendar System"
echo "  ------------------------"
echo ""

PRG="$0"

echoExec() {
  echo "$@"
  if [ "$echoOnly" = false ] ; then
    eval "$@"
    return $?
  fi

  return 0
}

mvnExec() {
  echoExec "$mvn_binary" "$@"
}

usage() {
  echo "See"
  echo "http://bedework.github.io/bedework/"
  echo "for information on configuring bedework."
  echo ""
  echo "  $PRG -cleanall      Do clean on all projects"
  echo "  $PRG -updateall     Does a git update of all projects"
  echo "  $PRG [-P PROFILE] <clean-build> [PROJECT] <options>"
  echo "              [LOG_LEVEL] [ target ] "
  echo ""
  echo " where:"
  echo "   PROFILE optionally defines the maven profile to use"
  echo "   Otherwise the maven default is used"
  echo ""
  echo "   <options> is zero or more of:"
  echo "     -echoonly    Show the commands but don't execute"
  echo "     -offline     Build without attempting to retrieve library jars"
  echo ""
  echo "   <clean-build> is zero or more of:"
  echo "     clean          Do a maven clean"
  echo "     build          Do a maven install (default)"
  echo ""
  echo "   LOG_LEVEL sets the level of logging and can be"
  echo "      -log-silent   Nearly silent"
  echo "      -log-quiet    The default"
  echo "      -log-inform   A little more noisy"
  echo "      -log-verbose  Noisier"
  echo "      -log-configs  Some info about configurations"
  echo "      -build-debug  Some bedework build debug output"
  echo ""
  echo "   target       Special target or compile target"
  echo ""
  echo "   Special targets"
  echo "      deployConf        deploys the configuration files"
  echo ""
  echo "   PROJECT optionally defines the package to build. If omitted the main"
  echo "           bedework calendar system will be built otherwise it is one of"
  echo "           the core, ancillary or experimental targets below:"
  echo ""
  echo "   Top level deployable or runnable projects"
  echo ""
  echo "     bwcal        Build and deploy full bedework calendar"
  echo "     bwcalq       Just redeploy bedework calendar ear(s)"
  echo "     bwcli        Target is for the bedework cli implementation"
  echo "     bwxml        Target is for the Bedework XML schemas build"
  echo "     carddav      Target is for the CardDAV build"
  echo "     eventreg     Target is for the event registration service build"
  echo "     notifier     Target is the Bedework notification service"
  echo "     selfreg      Target is for the self registration build"
  echo "     synch        Target is for the synch build"
  echo "     tzsvr        Target is for the timezones server build"
  echo "     xsl          Target is for the XSL module build"
  echo ""
  echo "   Core sub-projects: required for the above"
  echo "                      Do not need to be explicitly built"
  echo "     wfmodules    Build rw and ro full set of bedework wildfly modules"
  echo "     access       Target is for the access classes"
  echo "     bwcalclient  Target is for the bedework client implementation"
  echo "     bwcaleng     Target is for the bedework cal engine implementation"
  echo "     bwcalcommon  Target is for the bedework calendar common classes"
  echo "     bwcalsockets Target is for the bedework calsockets classes"
  echo "     bwcliutil    Target is for the bedework cli util library"
  echo "     caldav       Target is for the generic CalDAV server"
  echo "     carddav deploy-addrbook    To deploy the Javascript Addressbook client."
  echo "     bwlogs       Target is the Bedework log processing library"
  echo "     bwutil       Target is for the Bedework util classes"
  echo "     bwutilConf   Target is for the Bedework config util classes"
  echo "     bwutilNetwork Target is for the Bedework networking util classes"
  echo "     bwutilSecurity Target is for the Bedework security util classes"
  echo "     bwutilTz     Target is for the Bedework timezone util classes"
  echo "     bwutilIndex  Target is for the Bedework indexing util classes"
  echo "     bwutil       Target is for the Bedework util classes"
  echo "     bwutil2      Target is for the Bedework util2 classes"
  echo "     bwutilhib    Target is for the Bedework hibernate util classes"
  echo "     bwutillog    Target is for the Bedework logging util classes"
  echo "     bwutildeploy Target is for the Bedework deployment util classes"
  echo "     jsforj       Target is for the JSCalendar library build"
  echo "     webdav       Target is for the WebDAV build"
  echo "   Ancillary projects: not required"
  echo "     caldavTest   Target is for the CalDAV Test build"
  echo "     testsuite    Target is for the bedework test suite"
  echo "   Experimental projects: no guarantees"
  echo "     catsvr       Target is for the Catsvr build"
  echo "     client       Target is for the bedework client application build"
  echo "     naming       Target is for the abstract naming api"
  echo ""
  echo "   Invokes maven to build or deploy the Bedework system. "
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

setDir() {
  echoExec cd "$1"
}

# ----------------------------------------------------------------------------
# Update the projects
# ----------------------------------------------------------------------------
actionUpdateall() {
  for project in $bedeworkProjects
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
      setDir "$project"
      git pull
      setDir "$QUICKSTART_HOME"
    fi
  done

  exit 0
}

# ----------------------------------------------------------------------------
# Clean the projects
# ----------------------------------------------------------------------------
actionCleanall() {
  for project in $bedeworkProjects
  do
    if [ ! -d "$QUICKSTART_HOME/$project" ] ; then
      echo "*********************************************************************"
      echo "Project $project is missing. Check it out from the repository"
      echo "*********************************************************************"
    else
      echo "*********************************************************************"
      echo "Cleaning project $QUICKSTART_HOME/$project"
      echo "*********************************************************************"
      setDir "$project"
      mvnExec $mvn_quiet "$mvnProfile" clean
      setDir "$QUICKSTART_HOME"
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

#     Special targets
    if [ "$deployer" != "" ] ; then
      setDir "$QUICKSTART_HOME"
      specialTarget=deployer
      deployer=
      return
    fi

    if [ "$deploylog4j" != "" ] ; then
      setDir "$QUICKSTART_HOME"
      specialTarget=deploylog4j
      deploylog4j=
      return
    fi

    if [ "$deploywf" != "" ] ; then
      setDir "$QUICKSTART_HOME"
      specialTarget=deploywf
      deploywf=
      return
    fi

  if [ "$deployConf" != "" ] ; then
    setDir "$QUICKSTART_HOME"
    specialTarget=deployConf
    deployConf=
    return
  fi

  if [ "$deployWebcache" != "" ] ; then
    setDir "$QUICKSTART_HOME"
    specialTarget=deployWebcache
    deployWebcache=
    return
  fi

  if [ "$deployData" != "" ] ; then
    setDir "$QUICKSTART_HOME"
    specialTarget=deployData
    deployData=
    return
  fi

  if [ "$saveData" != "" ] ; then
    setDir "$QUICKSTART_HOME"
    specialTarget=saveData
      saveData=
    return
  fi

#     projects

	if [ "$xsl" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-calendar-xsl
      xsl=
	  return
	fi

	if [ "$bwutildeploy" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-util-deploy
      bwutildeploy=
	  return
	fi

	if [ "$bwutillog" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-util-logging
      bwutillog=
	  return
	fi

	if [ "$module_bwutillog" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-wfmodules/bw-wfmodules-logging
      module_bwutillog=
	  return
	fi

	if [ "$bwutil" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-util
      bwutil=
	  return
	fi

	if [ "$module_bwutil" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-wfmodules/bw-wfmodules-util
      module_bwutil=
	  return
	fi

	if [ "$bwutilconf" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-util-conf
      bwutilconf=
	  return
	fi

	if [ "$module_bwutilconf" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-wfmodules/bw-wfmodules-util-conf
      module_bwutilconf=
	  return
	fi

	if [ "$bwutilnetwork" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-util-network
      bwutilnetwork=
	  return
	fi

	if [ "$module_bwutilnetwork" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-wfmodules/bw-wfmodules-util-network
      module_bwutilnetwork=
	  return
	fi

	if [ "$bwutilsecurity" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-util-security
      bwutilsecurity=
	  return
	fi

	if [ "$module_bwutilsecurity" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-wfmodules/bw-wfmodules-util-security
    module_bwutilsecurity=
	  return
	fi

	if [ "$bwutiltz" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-util-tz
      bwutiltz=
	  return
	fi

	if [ "$bwutilindex" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-util-index
      bwutilindex=
	  return
	fi

	if [ "$bwutilhib" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-util-hibernate
      bwutilhib=
	  return
	fi

	if [ "$bwxml" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-xml
      bwxml=
	  return
	fi

	if [ "$bwutil2" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-util2
      bwutil2=
	  return
	fi

	if [ "$jsforj" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-jsforj
      jsforj=
	  return
	fi

	if [ "$access" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-access
      access=
	  return
	fi

	if [ "$bwnotifier" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-notifier
      bwnotifier=
	  return
	fi

	if [ "$eventreg" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-event-registration
      eventreg=
	  return
	fi

	if [ "$webdav" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-webdav
      webdav=
	  return
	fi

	if [ "$dotWellKnown" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-dotwell-known
      dotWellKnown=
	  return
	fi

	if [ "$caldav" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-caldav
      caldav=
	  return
	fi

	if [ "$caldavTest" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/caldavTest
      caldavTest=
	  return
	fi

	if [ "$carddav" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-carddav
      carddav=
	  return
	fi

	if [ "$bwcalcommon" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-calendar-common
      bwcalcommon=
	  return
	fi

	if [ "$bwcaleng" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-calendar-engine
      bwcaleng=
	  return
	fi

	if [ "$bwcalclient" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-calendar-client
      bwcalclient=
	  return
	fi

	if [ "$bwcal" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-deploy
      bwcal=
	  return
	fi

	if [ "$bwlogs" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-logs
      bwlogs=
	  return
	fi

	if [ "$bwcli" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-cli
      bwcli=
	  return
	fi

	if [ "$bwcliutil" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-cliutil
      bwcliutil=
	  return
	fi

	if [ "$catsvr" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/catsvr
      catsvr=
	  return
	fi

	if [ "$client" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bwclient
      client=
	  return
	fi

	if [ "$bwcalsockets" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-calsockets
    bwcalsockets=
	  return
	fi

	if [ "$bedework" != "" ] ; then
	  setDir "$QUICKSTART_HOME"
      bedework=
	  return
	fi

	if [ "$naming" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bwnaming
      naming=
	  return
	fi

	if [ "$exchgGateway" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/exchgGateway
      exchgGateway=
	  return
	fi

	if [ "$selfreg" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-self-registration
      selfreg=
	  return
	fi

  if [ "$synch" != "" ] ; then
    setDir "$QUICKSTART_HOME"/bw-synch
      synch=
    return
  fi

	if [ "$module_synch" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-wfmodules/bw-wfmodules-synch
    module_synch=
	  return
	fi

	if [ "$testsuite" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/testsuite
      testsuite=
	  return
	fi

	if [ "$tzsvr" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-timezone-server
      tzsvr=
	  return
	fi

	if [ "$module_tzsvr" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-wfmodules/bw-wfmodules-timezone-server
    module_tzsvr=
	  return
	fi

	if [ "$wfmodules" != "" ] ; then
	  setDir "$QUICKSTART_HOME"/bw-wfmodules
      wfmodules=
	  return
	fi

# Nothing left to do
    echo "Finished at $(date)"
	exit 0;
}

if [ -z "$JAVA_HOME" ] || [ ! -d "$JAVA_HOME" ] ; then
  errorUsage "JAVA_HOME is not defined correctly for bedework."
fi

version=$("$JAVA_HOME"/bin/java -version 2>&1 | sed -E -n 's/.* version "([^.-]*).*/\1/p')
if [[ "$version" -lt "11" ]]; then
  echo
  echo "************************************************"
  echo "Java 11 or greater is required for bedework"
  echo "************************************************"
  echo
  exit 1
fi

# Default some parameters

BWCONFIGS=
BWJMXCONFIG=
bwc=default
BWCONFIG=
offline=
clean=
build=

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
  exit 0
fi

if [ "$1" = "-cleanall" ] ; then
  actionCleanall
  exit 0
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
    -usage | -help | -\? | ?)
      usage
      exit
      shift
      ;;
    -echoonly)
      echoOnly=true
      shift
      ;;
    -mrl)
      shift
      mavenRepoLocal="$1"
      shift
      ;;
    -P)
      shift
      mvnProfile="-P $1"
      shift
      ;;
    -bwjmxconf)
      shift
      BWJMXCONFIG="$1"
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
# ----------------------- Log level
    -log-silent)
      mvn_loglevel="-quiet"
      shift
      ;;
    -log-inform)
      mvn_loglevel=""
      shift
      ;;
    -log-verbose)
      mvn_loglevel="-verbose"
      shift
      ;;
    -mvn-debug)
      mvn_loglevel="-debug"
      shift
      ;;
    -pd-debug)
      postDeployDebug=" --debug "
      shift
      ;;
# ------------------------Special targets
    build)
      build="yes"
      shift
      ;;
    clean)
      clean="yes"
      shift
      ;;
    cmdutil)
    cmdutil="yes"
      pkgdefault=
      shift
      ;;
  deployConf)
    deployConf="yes"
      pkgdefault=
      shift
      ;;
  deployDotWellKnown)
    dotWellKnown="yes"
      pkgdefault=
      shift
      ;;
  deployWebcache)
    deployWebcache="yes"
      pkgdefault=
      shift
      ;;
# ------------------------Projects
    access)
      access="yes"

      bwxml="yes"
      bwutil="yes"
      bwutillog="yes"
      pkgdefault=
      shift
      ;;
    bwcal)
      bwcal="yes"

      bwcalclient="yes"
      pkgdefault=
      shift
      ;;
    bwcalq)
      bwcal="yes"

      pkgdefault=
      shift
      ;;
    bwcalclient)
      bwcalclient="yes"

      wfmodules="yes"
      bwcliutil="yes"
      pkgdefault=
      shift
      ;;
    wfmodules)
      wfmodules="yes"

      cmdutil="yes"
#     deployConf="yes"
#     dotWellKnown="yes"
#     deployWebcache="yes"
      access="yes"
      bwcal="yes"
      bwcalclient="yes"
      bwcalcommon="yes"
      bwcaleng="yes"
      bwcalsockets="yes"
      bwcli="yes"
      bwcliutil="yes"
      bwlogs="yes"
      bwnotifier="yes"
      bwutil="yes"
      bwutilconf="yes"
      bwutildeploy="yes"
      bwutilhib="yes"
      bwutilindex="yes"
      bwutillog="yes"
      bwutilnetwork="yes"
      bwutilsecurity="yes"
      bwutiltz="yes"
      bwutil2="yes"
      bwxml="yes"
      caldav="yes"
      caldavTest="yes"
      carddav="yes"
      catsvr="yes"
#     client="yes"
      eventreg="yes"
#     exchgGateway="yes"
      jsforj="yes"
#     naming="yes"
      selfreg="yes"
      synch="yes"
#     testsuite="yes"
      tzsvr="yes"
      webdav="yes"
      xsl="yes"
      pkgdefault=
      shift
      ;;

    bwcalcommon)
      bwcalcommon="yes"

      access="yes"
      jsforj="yes"
      bwxml="yes"
      bwutil="yes"
      bwutilconf="yes"
      bwutilindex="yes"
      bwutillog="yes"
      bwutilsecurity="yes"
      bwutiltz="yes"
      bwutil2="yes"
      jsforj="yes"

      pkgdefault=
      shift
      ;;
    bwcaleng)
      bwcaleng="yes"

      access="yes"
      jsforj="yes"
      bwxml="yes"
      caldav="yes"
      bwcliutil="yes"
      bwutil="yes"
      bwutilconf="yes"
      bwutilhib="yes"
      bwutilindex="yes"
      bwutillog="yes"
      bwutilnetwork="yes"
      bwutilsecurity="yes"
      bwutiltz="yes"
      bwutil2="yes"
      jsforj="yes"
      webdav="yes"

      pkgdefault=
      shift
      ;;
    bwlogs)
      bwlogs="yes"
      bwutil="yes"
      bwutillog="yes"

      pkgdefault=
      shift
      ;;
    bwcli)
      bwcli="yes"

      bwcliutil="yes"
      bwutil="yes"
      bwutilconf="yes"
      bwutillog="yes"
      bwutilnetwork="yes"

      pkgdefault=
      shift
      ;;
    bwcliutil)
      bwcliutil="yes"

      bwutil="yes"
      bwutilconf="yes"
      bwutillog="yes"

      pkgdefault=
      shift
      ;;
    notifier)
      bwnotifier="yes"
      #earName="$earNameNotifier"

      access="yes"
      bwxml="yes"
      bwutil="yes"
      bwutilconf="yes"
      bwutildeploy="yes"
      bwutillog="yes"
      bwutilhib="yes"
      bwutilnetwork="yes"
      bwutilsecurity="yes"
      bwutiltz="yes"

      pkgdefault=
      shift
      ;;
    bwcalsockets)
      bwcalsockets="yes"
      #warNames="$warnamescalsockets"

      access="yes"
      bwxml="yes"
      bwutil="yes"
      bwutilconf="yes"
      bwutildeploy="yes"
      bwutillog="yes"
      bwutilnetwork="yes"

      pkgdefault=
      shift
      ;;

    bwxml)
      bwxml="yes"
      #earName="$earNameXml"
      pkgdefault=
      shift
      ;;

    caldav)
      caldav="yes"

      access="yes"
      bwxml="yes"
      bwutil="yes"
      bwutilconf="yes"
      bwutillog="yes"
      bwutilnetwork="yes"
      bwutiltz="yes"
      webdav="yes"
      pkgdefault=
      shift
      ;;

    caldavTest)
      caldavTest="yes"

      access="yes"
      bwxml="yes"
      bwutil="yes"
      bwutillog="yes"
      bwutilnetwork="yes"
      pkgdefault=
      shift
      ;;
    carddav)
      carddav="yes"

      access="yes"
      bwxml="yes"
      bwutil="yes"
      bwutilconf="yes"
      bwutildeploy="yes"
      bwutillog="yes"
      bwutilhib="yes"
      bwutilnetwork="yes"
      bwutiltz="yes"
      bwutil2="yes"
      webdav="yes"
      pkgdefault=
      shift
      ;;
    catsvr)
      catsvr="yes"

      access="yes"
      bwxml="yes"
      bwutil="yes"
      bwutildeploy="yes"
      bwutillog="yes"
      bwutilnetwork="yes"
      webdav="yes"
      pkgdefault=
      shift
      ;;
    client)
      client="yes"
      pkgdefault=
      shift
      ;;
    eventreg)
      eventreg="yes"
      #earName="$earNameEventreg"

      bwxml="yes"
      bwutil="yes"
      bwutilconf="yes"
      bwutildeploy="yes"
      bwutillog="yes"
      bwutilnetwork="yes"
      bwutiltz="yes"
      bwutilhib="yes"
      bwutil2="yes"
      pkgdefault=
      shift
      ;;
    naming)
      naming="yes"
      pkgdefault=
      shift
      ;;
    bwutil)
      bwutil="yes"
      bwutillog="yes"

      pkgdefault=
      shift
      ;;
    module_bwutil)
      module_bwutil="yes"
      bwutil="yes"

      pkgdefault=
      shift
      ;;
    bwutilConf)
      bwutilconf="yes"
      bwutil="yes"
      bwutillog="yes"

      pkgdefault=
      shift
      ;;
    module_bwutilConf)
      module_bwutilconf="yes"
      bwutilconf="yes"

      pkgdefault=
      shift
      ;;
    bwutilNetwork)
      bwutilnetwork="yes"
      bwutil="yes"
      bwutilconf="yes"
      bwutillog="yes"

      pkgdefault=
      shift
      ;;
    module_bwutilNetwork)
      module_bwutilnetwork="yes"
      bwutilnetwork="yes"

      pkgdefault=
      shift
      ;;
    bwutilSecurity)
      bwutilsecurity="yes"
      bwutil="yes"
      bwutilconf="yes"
      bwutillog="yes"

      pkgdefault=
      shift
      ;;
    module_bwutilSecurity)
      module_bwutilsecurity="yes"
      bwutilsecurity="yes"

      pkgdefault=
      shift
      ;;
    bwutilTz)
      bwutiltz="yes"
      bwutil="yes"
      bwutillog="yes"
      bwutilnetwork="yes"

      pkgdefault=
      shift
      ;;
    bwutilIndex)
      bwutilindex="yes"
      bwutil="yes"
      bwutilconf="yes"
      bwutillog="yes"
      bwutiltz="yes"

      pkgdefault=
      shift
      ;;
    bwutilhib)
      bwutilhib="yes"

      bwutil="yes"
      bwutillog="yes"
      pkgdefault=
      shift
      ;;
    bwutildeploy)
      bwutildeploy="yes"

      bwutil="yes"
      bwutillog="yes"
      pkgdefault=
      shift
      ;;
    bwutillog)
      bwutillog="yes"

      pkgdefault=
      shift
      ;;
    module_bwutillog)
      module_bwutillog="yes"
      bwutillog="yes"

      pkgdefault=
      shift
      ;;
    bwutil2)
      bwutil2="yes"

      bwxml="yes"
      pkgdefault=
      shift
      ;;
    exchgGateway)
      exchgGateway="yes"

#      access="yes"
      bwxml="yes"
#      bwutil="yes"
      pkgdefault=
      shift
      ;;
    jsforj)
      jsforj="yes"

      bwutil="yes"
      bwutillog="yes"
      pkgdefault=
      shift
      ;;
    selfreg)
      selfreg="yes"
      #earName="$earNameSelfreg"

      bwutil="yes"
      bwutilconf="yes"
      bwutildeploy="yes"
      bwutillog="yes"
      bwutilnetwork="yes"
      bwutilhib="yes"
      bwutilsecurity="yes"
      pkgdefault=
      shift
      ;;
    synch)
      synch="yes"
      #earName="$earNameSynch"

      access="yes"
      bwxml="yes"
      bwutil="yes"
      bwutilconf="yes"
      bwutildeploy="yes"
      bwutillog="yes"
      bwutilnetwork="yes"
      bwutilsecurity="yes"
      bwutiltz="yes"
      bwutilhib="yes"
      bwutil2="yes"
      pkgdefault=
      shift
      ;;
    module_synch)
      module_synch="yes"
      synch="yes"

      pkgdefault=
      shift
      ;;
    testsuite)
      testsuite="yes"

      pkgdefault="yes"
      shift
      ;;
    tzsvr)
      tzsvr="yes"

      bwxml="yes"
      bwutil="yes"
      bwutilconf="yes"
      bwutildeploy="yes"
      bwutilindex="yes"
      bwutillog="yes"
      bwutilnetwork="yes"
      bwutiltz="yes"
      bwutil2="yes"
      pkgdefault=
      shift
      ;;
    module_tzsvr)
      module_tzsvr="yes"
      tzsvr="yes"

      pkgdefault=
      shift
      ;;
    webdav)
      webdav="yes"

      access="yes"
      bwutil="yes"
      bwutillog="yes"
      bwutilnetwork="yes"
      pkgdefault=
      shift
      ;;
    xsl)
      xsl="yes"

      bwutildeploy="yes"
      pkgdefault=
      shift
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [ "$pkgdefault" = "yes" ] ; then
  bwcalclient="yes"

  access="yes"
  jsforj="yes"
  bwcalcommon="yes"
  bwcaleng="yes"
  bwxml="yes"
  bwcliutil="yes"
  caldav="yes"
  jsforj="yes"
  bwutil="yes"
  bwutilconf="yes"
  bwutildeploy="yes"
  bwutillog="yes"
  bwutilhib="yes"
  bwutilindex="yes"
  bwutilsecurity="yes"
  bwutiltz="yes"
  bwutil2="yes"
  webdav="yes"
fi

export QUICKSTART_HOME

mvncmd="$mvn_quiet $mvnProfile -Dmaven.test.skip=true"

if [ "$clean" = "yes" ] ; then
  mvncmd="$mvncmd clean"
  if [ "$build" = "yes" ] ; then
    mvncmd="$mvncmd install"
  fi
else
  mvncmd="$mvncmd install"
fi

while true
do
  setDirectory

  #echo "!!! postDeploy=$postDeploy postDeployWars=$postDeployWars "
  #echo "!!! warNames=$warNames earName=$earName "

  if [ "$specialTarget" != "" ] ; then
    # echo "Special target - command is $javacmd $specialTarget"
    $javacmd $specialTarget
  else
    if ! mvnExec "$mvncmd" ; then
      echo "Maven build unsuccessful"
      exit 1
    fi
  fi
done

