#! /bin/sh

# Script to start jboss with properties defined
# This currently needs to be executed out of the quickstart directory
# (via a source)

if [ "x$JBOSS_PIDFILE" = "x" ]; then
  export JBOSS_PIDFILE=/var/tmp/bedework.jboss.pid
fi

echo "pidfile=$JBOSS_PIDFILE"

BASE_DIR=`pwd`

PRG="$0"

usage() {
  echo "  $PRG [-heap size] [-stack size] [-newsize size] [-permgen size] [-debug]"
  echo "       [-debugexprfilters name] [-oomdump directory-path]"
  echo ""
  echo " Where:"
  echo ""
  echo " -heap sets the heap size and should be n for bytes"
  echo "                                        nK for kilo-bytes (e.g. 2560000K)"
  echo "                                        nM for mega-bytes (e.g. 2560M)"
  echo "                                        nG for giga-bytes (e.g. 1G)"
  echo "  Default: $heap"
  echo ""
  echo " -permsize sets the permgen size and has the same form as -heap"
  echo " -oomdump enables an oom dump into the given directory"
  echo "  The value should probably not be less than 256M"
  echo "  Default: $permsize"
  echo ""
  echo " -debug sets the logging level to DEBUG"
  echo ""
  echo " -debugexprfilters sets the logging level for bedework expression filters to DEBUG"
  echo ""
}

# ===================== Defaults =================================

# Stack can't be smaller until some recursive constructs are
# removed from the xsl - specifically the year day recurrence stuff in
# event creation
stack="600k"
heap="600M"
newsize="200M"
permsize="256M"
testmode=""
profiler=""
oomdump=""

debugGc=false

exprfilters=INFO

# Figure out where java is for version checks
if [ "x$JAVA" = "x" ]; then
    if [ "x$JAVA_HOME" != "x" ]; then
	JAVA="$JAVA_HOME/bin/java"
    else
	JAVA="java"
    fi
fi

# Check our java version
version=$($JAVA -version 2>&1 | sed -E -n 's/.* version "([^.-]*).*/\1/p')
if [[ "$version" -lt "11" ]]; then
  echo "Java 11 or greater is required for bedework"
  exit 1
fi

# =================== End defaults ===============================

LOG_THRESHOLD="-Dorg.bedework.log.level=INFO"
JBOSS_VERSION="wildfly"

while [ "$1" != "" ]
do
  # Process the next arg
  case $1       # Look at $1
  in
    -usage | -help | -? | ?)
      usage
      exit
      ;;
    -heap)         # Heap size bytes or nK, nM, nG
      shift
      heap="$1"
      shift
      ;;
    -stack)
      shift
      stack="$1"
      shift
      ;;
    -newsize)
      shift
      newsize="$1"
      shift
      ;;
    -permsize)
      shift
      permsize="$1"
      shift
      ;;
    -jboss)
      shift
      JBOSS_VERSION="$1"
      shift
      ;;
    -oomdump)
      shift
      oomdump="-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$1/heap-$(date +'%Y-%m-%d_%H:%m:%S').hprof"
      shift
      ;;
    -profile)
      shift
      profiler="-agentlib:yjpagent"
      ;;
    -testmode)
      shift
      testmode="-Dorg.bedework.testmode=true"
      ;;
    -debug)
      shift
      debugGc=true
      LOG_THRESHOLD="-Dorg.bedework.log.level=DEBUG"
      ;;
    -debugexprfilters)
      shift
      exprfilters=DEBUG
      shift
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

JBOSS_CONFIG="standalone"
JBOSS_SERVER_DIR="$BASE_DIR/$JBOSS_VERSION/$JBOSS_CONFIG"
JBOSS_DATA_DIR="$JBOSS_SERVER_DIR/data"

# If this is empty only localhost will be available.
# With this address anybody can access the consoles if they are not locked down.
JBOSS_BIND="-b 0.0.0.0"

LOG_LEVELS="-Dorg.bedework.loglevel.exprfilters=$exprfilters"

BW_DATA_DIR=$JBOSS_DATA_DIR/bedework
BW_DATA_DIR_DEF=-Dorg.bedework.data.dir=$BW_DATA_DIR/

# Define the system properties used to locate the module specific data

#         carddav data dir
BW_CARDDAV_DATAURI=$BW_DATA_DIR/carddavConfig
BW_CARDDAV_DATAURI_DEF=-Dorg.bedework.carddav.datauri=$BW_CARDDAV_DATAURI/
BW_DATA_DIR_DEF="$BW_DATA_DIR_DEF $BW_CARDDAV_DATAURI_DEF"

#         synch data dir
BW_SYNCH_DATAURI=$BW_DATA_DIR/synch
BW_SYNCH_DATAURI_DEF=-Dorg.bedework.synch.datauri=$BW_SYNCH_DATAURI/
BW_DATA_DIR_DEF="$BW_DATA_DIR_DEF $BW_SYNCH_DATAURI_DEF"

# Configurations property file

BW_CONF_DIR="$JBOSS_SERVER_DIR/configuration/bedework"
BW_CONF_FILE_DEF="-Dorg.bedework.config.pfile=$BW_CONF_DIR/config.defs"
BW_CONF_DIR_DEF="-Dorg.bedework.config.dir=$BW_CONF_DIR/"

# Elastic search home

export ES_HOME="$BW_DATA_DIR/elasticsearch"
JAVA_OPTS="$JAVA_OPTS -Des.path.home=$ES_HOME"

JAVA_OPTS="$JAVA_OPTS -Xms$heap -Xmx$heap -Xss$stack"

# Put all the temp stuff inside the jboss temp
JAVA_OPTS="$JAVA_OPTS -Djava.io.tmpdir=$JBOSS_SERVER_DIR/tmp"
JAVA_OPTS="$JAVA_OPTS $oomdump"
JAVA_OPTS="$JAVA_OPTS $profiler"

HAWT_OPTS="-Dhawtio.authenticationEnabled=true -Dhawtio.realm=other -Dhawtio.role=hawtioadmin"

if [ "$debugGc" = "true" ] ; then
  # Java 8 export JAVA_OPTS="$JAVA_OPTS -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -Xloggc:$JBOSS_SERVER_DIR/log/jvm.log -verbose:gc "
  touch $JBOSS_SERVER_DIR/log/loggc.log
  touch $JBOSS_SERVER_DIR/log/jvm.log

  export JAVA_OPTS="$JAVA_OPTS -Xlog:gc*:file=$JBOSS_SERVER_DIR/log/loggc.log -verbose:gc -Xloggc:$JBOSS_SERVER_DIR/log/jvm.log "
fi
 
export JAVA_OPTS="$JAVA_OPTS -XX:MetaspaceSize=$permsize -XX:MaxMetaspaceSize=$permsize"

RUN_CMD="./$JBOSS_VERSION/bin/standalone.sh"
RUN_CMD="$RUN_CMD $JBOSS_BIND"
RUN_CMD="$RUN_CMD $HAWT_OPTS"
RUN_CMD="$RUN_CMD $testmode"
RUN_CMD="$RUN_CMD $LOG_THRESHOLD $LOG_LEVELS"
RUN_CMD="$RUN_CMD $BW_CONF_DIR_DEF $BW_CONF_FILE_DEF $BW_DATA_DIR_DEF"

#wilfdfly disable the bits below until we know they are needed for
#wilfdfly this system.

# Specifying jboss.platform.mbeanserver makes jboss use the standard
# platform mbean server.
#wilfdfly RUN_CMD="$RUN_CMD -Djboss.platform.mbeanserver"

# Set up JMX for bedework
#RUN_CMD="$RUN_CMD -Dorg.bedework.jmx.defaultdomain=jboss"
#wilfdfly RUN_CMD="$RUN_CMD -Dorg.bedework.jmx.isJboss5=true"
#wilfdfly RUN_CMD="$RUN_CMD -Dorg.bedework.jmx.classloader=org.jboss.mx.classloader"

echo $RUN_CMD

$RUN_CMD
