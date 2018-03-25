#! /bin/sh

# ################################################################
# Run this from the quickstart directory.
# ################################################################

#Version of jboss we use in the quickstart
JBOSS_NAME=wildfly-10.1.0.Final

# We rebuild the quickstart. 
# This is the version of java we use.

if [ -z "$JAVA_HOME" -o ! -d "$JAVA_HOME" ] ; then
  echo "JAVA_HOME is not defined correctly for export."
  echo ""
  exit 1
fi

#export JAVA_HOME=/usr/java/jdk1.8.0_111

QUICKSTARTDIR_NAME=${PWD##*/}

cd ..

HDIR=`pwd`

#configArgs="-wildfly"

# #################################################################
# Everything below is based on the above settings
# #################################################################

# Export and quickstart build directory names
EXPORTDIR=$HDIR

EXPORT_QS=$EXPORTDIR/$QUICKSTARTDIR_NAME
EXPORT_JBOSS=$EXPORT_QS/$JBOSS_NAME

if [ ! -d $EXPORT_QS ]
then
   echo "#################################################################"
   echo "#################################################################"
   echo "Quickstart directory $EXPORT_QS does not exist"
   echo "#################################################################"
   echo "#################################################################"
   exit 1
fi

cd $EXPORT_QS

./bw -updateall

# Remove all bw stuff from the deploy directory
rm -r $JBOSS_NAME/standalone/deployments/bw*

echo "##################################################################"
echo "Cleaning all projects"
echo "##################################################################"

./bw $configArgs clean
./bw $configArgs -bwxml clean
./bw $configArgs -tzsvr clean
./bw $configArgs -selfreg clean
./bw $configArgs -synch clean
./bw $configArgs -carddav clean
./bw $configArgs -eventreg clean

echo "##################################################################"
echo "Building and deploying rpiutil for deployments"
echo "##################################################################"

./bw $configArgs -rpiutil

echo "##################################################################"
echo "Building and deploying bwxml"
echo "##################################################################"

./bw $configArgs -bwxml

echo "##################################################################"
echo "Building and deploying Bedework"
echo "##################################################################"

./bw $configArgs deploy

echo "##################################################################"
echo "Deploying system configuration"
echo "##################################################################"

./bw $configArgs deployConf

echo "##################################################################"
 echo "Building and deploying carddav."
echo "##################################################################"

./bw $configArgs -carddav

echo "##################################################################"
echo "Deploying Address Book Client"
echo "##################################################################"

./bw $configArgs -carddav deploy-addrbook

echo "##################################################################"
echo "Building and deploying selfreg"
echo "##################################################################"

./bw $configArgs -selfreg

echo "##################################################################"
echo "Building and deploying synch engine"
echo "##################################################################"

./bw $configArgs -synch

echo "##################################################################"
echo "Building and deploying timezone server"
echo "##################################################################"

./bw $configArgs -tzsvr

echo "##################################################################"
echo "Building and deploying registration module"
echo "##################################################################"

./bw $configArgs -eventreg

echo "##################################################################"
echo "Building and deploying notification engine"
echo "##################################################################"

./bw $configArgs -notifier

echo "##################################################################"
echo "Deploying wildfly configuration"
echo "##################################################################"

./bw $configArgs deploywf

echo "##################################################################"
echo "Deploying .well-known redirector"
echo "##################################################################"

./bw $configArgs deployDotWellKnown

# Clean it up and copy some files
cd $EXPORT_QS
./bw quickstart-clean

rm $EXPORT_QS/logs/*
# Clean up jboss?
#  remove logs

rm -r $JBOSS_NAME/standalone/tmp

cp bedework/config/wildfly/quickstart/standalone.xml $JBOSS_NAME/standalone/configuration/

rm $EXPORT_QS/logs/*
rm -rf $EXPORT_QS/bedework/dist/*

cd $EXPORT_QS 
svn cleanup  access
svn cleanup  bedework
svn cleanup  bwannotations
svn cleanup  bwcalcore
svn cleanup  bwcaldav
svn cleanup  bwcalFacade
svn cleanup  bwdeployutil
svn cleanup  bwical
svn cleanup  bwinterfaces
svn cleanup  bwsysevents
svn cleanup  bwtools
svn cleanup  bwtzsvr
svn cleanup  bwwebapps
svn cleanup  bwxml
svn cleanup  cachedfeeder
svn cleanup  caldav
svn cleanup  caldavTest
svn cleanup  bedework-carddav
svn cleanup  clientapp
svn cleanup  dumprestore
svn cleanup  eventreg
svn cleanup  indexer
svn cleanup  monitor
svn cleanup  naming
svn cleanup  rpiutil
svn cleanup  synch
svn cleanup  selfreg
svn cleanup  testsuite
svn cleanup  webdav

./bw $configArgs clean
./bw $configArgs -tzsvr clean
./bw $configArgs -selfreg clean
./bw $configArgs -synch clean
./bw $configArgs -carddav clean
./bw $configArgs -eventreg clean

cd $EXPORT_QS/bw-notifier
mvn clean

# Zip it up

cd $EXPORTDIR

rm quickstart*.zip
zipFile=$QUICKSTARTDIR_NAME.zip
zip -rq $zipFile $QUICKSTARTDIR_NAME

ls -l $QUICKSTARTDIR_NAME.zip 

#destDir="/data/downloads/nightly/`date +%Y-%m-%d`"
#echo "##################################################################"
#echo "\nMoving zip file to ${destDir}."
#echo "##################################################################"
#mkdir -p $destDir
#mv $zipFile $destDir
#ls -l $destDir

