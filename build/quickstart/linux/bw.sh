#! /bin/sh

#
# This file is included by the quickstart script file "bw" so that it can live
# within the svn repository.
#

saveddir=`pwd`

trap 'cd $saveddir' 0
trap "exit 2" 1 2 3 15

export QUICKSTART_HOME=$saveddir

bw_loglevel=""
postDeployDebug="";
deployConfig="./bedework/config/wildfly.deploy.properties"

mvn_quiet=   # "-q"
mvnProfile="bedework-3"

#mvn_binary="/usr/share/maven/bin/mvn";
mvn_binary="mvn"

mvnUpdateProjects="bedework"
mvnUpdateProjects="$mvnUpdateProjects  bw-access"
mvnUpdateProjects="$mvnUpdateProjects  bw-cache-proxy"
mvnUpdateProjects="$mvnUpdateProjects  bw-caldav"
mvnUpdateProjects="$mvnUpdateProjects  bw-calendar-client"
mvnUpdateProjects="$mvnUpdateProjects  bw-calendar-engine"
mvnUpdateProjects="$mvnUpdateProjects  bw-calsockets"
mvnUpdateProjects="$mvnUpdateProjects  bw-carddav"
mvnUpdateProjects="$mvnUpdateProjects  bw-cli"
mvnUpdateProjects="$mvnUpdateProjects  bw-dotwell-known"
mvnUpdateProjects="$mvnUpdateProjects  bw-event-registration"
mvnUpdateProjects="$mvnUpdateProjects  bw-notifier"
mvnUpdateProjects="$mvnUpdateProjects  bw-self-registration"
mvnUpdateProjects="$mvnUpdateProjects  bw-synch"
mvnUpdateProjects="$mvnUpdateProjects  bw-timezone-server"
mvnUpdateProjects="$mvnUpdateProjects  bw-util"
mvnUpdateProjects="$mvnUpdateProjects  bw-util-hibernate"
mvnUpdateProjects="$mvnUpdateProjects  bw-util2"
mvnUpdateProjects="$mvnUpdateProjects  bw-webdav"
mvnUpdateProjects="$mvnUpdateProjects  bw-xml"

# Projects we will build - pkgdefault (bedework) is built if nothing specified
pkgdefault=yes
access=
bedework=
bwcalclient=
bwcaleng=
bwcli=
bwnotifier=
bwcalsockets=
bwxml=
caldav=
caldavTest=
carddav=
catsvr=
client=
dotWellKnown=
eventreg=
exchgGateway=
naming=
bwutil=
bwutilhib=
bwutil2=
selfreg=
synch=
testsuite=
tzsvr=
webdav=
xsl=

# Special targets - avoiding dependencies

cmdutil=
deployer=
deploylog4j=
deploywf=
deployConf=
deployData=
deployWebcache=
saveData=

specialTarget=

dobuild=yes

mavenRepoLocal=

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
  echo "  $PRG [-dc CONFIG-SOURCE] [-P PROFILE] [PROJECT] [ -offline ] "
  echo "              [-appserver=<server>]"
  echo "              [LOG_LEVEL] [ target ] "
  echo ""
  echo " where:"
  echo ""
  echo "   ACTION defines an action to take usually in the context of the quickstart."
  echo "    In a deployed system many of these actions are handled directly by a"
  echo "    deployed application. ACTION may be one of"
  echo "      -updateall  Does an svn update of all projects"
  echo ""
  echo "   CONFIG-SOURCE optionally defines the location of the deploy properties"
  echo "   The default is in $deployConfig."
  echo ""
  echo "   PROFILE optionally defines the maven profile to use"
  echo "   The default is $mvnProfile."
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
  echo "      -build-debug  Some bedework build debug output"
  echo ""
  echo "   target       Special target or compile target"
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
  echo "     -bwcalclient  Target is for the bedework client implementation"
  echo "     -bwcaleng     Target is for the bedework cal engine implementation"
  echo "     -bwcalsockets Target is for the bedework calsockets classes"
  echo "     -bwxml        Target is for the Bedework XML schemas build"
  echo "                        (usually built automatically be dependent projects"
  echo "     -caldav       Target is for the generic CalDAV server"
  echo "     -carddav      Target is for the CardDAV build"
  echo "     -carddav deploy-addrbook    To deploy the Javascript Addressbook client."
  echo "     -eventreg     Target is for the event registration service build"
  echo "     -notifier     Target is the Bedework notification service"
  echo "     -bwutil       Target is for the Bedework util classes"
  echo "     -bwutilhib    Target is for the Bedework hibernate util classes"
  echo "     -bwutil2      Target is for the Bedework util2 classes"
  echo "     -selfreg      Target is for the self registration build"
  echo "     -synch        Target is for the synch build"
  echo "     -tzsvr        Target is for the timezones server build"
  echo "     -webdav       Target is for the WebDAV build"
  echo "     -xsl          Target is for the XSL module build"
  echo "   Ancillary projects: not required"
  echo "     -caldavTest   Target is for the CalDAV Test build"
  echo "     -testsuite    Target is for the bedework test suite"
  echo "   Experimental projects: no guarantees"
  echo "     -catsvr       Target is for the Catsvr build"
  echo "     -client       Target is for the bedework client application build"
  echo "     -naming       Target is for the abstract naming api"
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

# ----------------------------------------------------------------------------
# Update the projects
# ----------------------------------------------------------------------------
actionUpdateall() {
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

#     Special targets
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

	if [ "$xsl" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-calendar-xsl
      xsl=
	  return
	fi

	if [ "$bwutil" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-util
      bwutil=
	  return
	fi

	if [ "$bwutilhib" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-util-hibernate
      bwutilhib=
	  return
	fi

	if [ "$bwxml" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-xml
      bwxml=
	  return
	fi

	if [ "$bwutil2" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-util2
      bwutil2=
	  return
	fi

	if [ "$access" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-access
      access=
	  return
	fi

	if [ "$bwnotifier" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-notifier
      bwnotifier=
	  return
	fi

	if [ "$eventreg" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-event-registration
      eventreg=
	  return
	fi

	if [ "$webdav" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-webdav
      webdav=
	  return
	fi

	if [ "$dotWellKnown" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-dotwell-known
      dotWellKnown=
	  return
	fi

	if [ "$caldav" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-caldav
      caldav=
	  return
	fi

	if [ "$caldavTest" != "" ] ; then
	  cd $QUICKSTART_HOME/caldavTest
      caldavTest=
	  return
	fi

	if [ "$carddav" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-carddav
      carddav=
	  return
	fi

	if [ "$bwcaleng" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-calendar-engine
      bwcaleng=
	  return
	fi

	if [ "$bwcalclient" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-calendar-client
      bwcalclient=
	  return
	fi

	if [ "$bwcli" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-cli
      bwcli=
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

	if [ "$bwcalsockets" != "" ] ; then
	  cd $QUICKSTART_HOME/bw-calsockets
    bwcalsockets=
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
	  return
	fi

  if [ "$synch" != "" ] ; then
    cd $QUICKSTART_HOME/bw-synch
      synch=
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

# Default some parameters

BWCONFIGS=
BWJMXCONFIG=
bwc=default
BWCONFIG=
offline=

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
      echo "The dirstart target is no longer supported"
      echo "Use the dirstart script instead."
      exit 1
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
    -bwcalclient)
      bwcalclient="yes"

      access="yes"
      bwcaleng="yes"
      bwxml="yes"
      caldav="yes"
      bwutil="yes"
      bwutilhib="yes"
      bwutil2="yes"
      webdav="yes"
      pkgdefault=
      shift
      ;;
    -bwcaleng)
      bwcaleng="yes"

      access="yes"
      bwxml="yes"
      caldav="yes"
      bwutil="yes"
      bwutilhib="yes"
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
    -notifier)
      bwnotifier="yes"
      #earName="$earNameNotifier"
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

      access="yes"
      bwxml="yes"
      bwutil="yes"
      bwutilhib="yes"
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
    -eventreg)
      eventreg="yes"
      #earName="$earNameEventreg"

      bwxml="yes"
      bwutil="yes"
      bwutilhib="yes"
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
    -bwutilhib)
      bwutilhib="yes"

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
      bwutilhib="yes"
      pkgdefault=
      shift
      ;;
    -synch)
      synch="yes"
      #earName="$earNameSynch"

      access="yes"
      bwxml="yes"
      bwutil="yes"
      bwutilhib="yes"
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
    -xsl)
      xsl="yes"

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
  bwcalclient="yes"

  access="yes"
  bwcaleng="yes"
  bwxml="yes"
  caldav="yes"
  bwutil="yes"
  bwutilhib="yes"
  bwutil2="yes"
  webdav="yes"
fi

export QUICKSTART_HOME

mvncmd=

if [ "$1" = "clean" ] ; then
  mvncmd="$mvn_binary -P $mvnProfile clean"
else
  mvncmd="$mvn_binary $mvn_quiet -P $mvnProfile -Dmaven.test.skip=true install"
fi

echo "mvncmd = $mvncmd"

while true
do
  setDirectory

  #echo "!!! postDeploy=$postDeploy postDeployWars=$postDeployWars "
  #echo "!!! warNames=$warNames earName=$earName "

  if [ "$specialTarget" != "" ] ; then
    # echo "Special target - command is $javacmd $specialTarget"
    $javacmd $specialTarget
  else
    echo "mvncmd = $mvncmd"
    $mvncmd
    if [ "$?" -ne 0 ]; then
      echo "Maven build unsuccessful"
      exit 1
    fi
  fi
done

