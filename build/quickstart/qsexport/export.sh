#! /bin/sh

# ################################################################
# First we set up some names
# ################################################################

# Version of jboss we use in the quickstart
JBOSS_NAME=jboss-5.1.0.GA

# We rebuild the quickstart. 
# This is the version of java we use.
export JAVA_HOME=/usr/java/jdk1.8.0_111

HDIR=$HOME

export QUICKSTARTDIR_NAME=quickstart-3.10-dev

# #################################################################
# Everything below is based on the above settings
# #################################################################

# Export and quickstart build directory names
EXPORTDIR=$HDIR/exportbw
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

# Update the VERSION.properties file in the quickstart, so that downloaded quickstarts can be
# distinguished.  Gather input from whomever runs this script.

./version.sh

cd $EXPORT_QS

./bw -updateall

echo "##################################################################"
echo "Cleaning all projects"
echo "##################################################################"

./bw clean
./bw -bwmsg clean
./bw -bwxml clean
./bw -tzsvr clean
./bw -selfreg clean
./bw -synch clean
./bw -carddav clean
./bw -eventreg clean

echo "##################################################################"
echo "Building and deploying bwmsg"
echo "##################################################################"

./bw -bwmsg

echo "##################################################################"
echo "Building and deploying bwxml"
echo "##################################################################"

./bw -bwxml

echo "##################################################################"
echo "Building and deploying Bedework"
echo "##################################################################"

./bw deploy

echo "##################################################################"
echo "Building and deploying carddav."
echo "##################################################################"

./bw -carddav

echo "##################################################################"
echo "Deploying Address Book Client"
echo "##################################################################"

./bw -carddav deploy-addrbook

echo "##################################################################"
echo "Building and deploying selfreg"
echo "##################################################################"

./bw -selfreg

echo "##################################################################"
echo "Building and deploying synch engine"
echo "##################################################################"

./bw -synch

echo "##################################################################"
echo "Building and deploying timezone server"
echo "##################################################################"

./bw -tzsvr

echo "##################################################################"
echo "Building and deploying registration module"
echo "##################################################################"

./bw -eventreg

#echo "##################################################################"
#echo "Deploying timezone data"
#echo "##################################################################"

#./bw -tzsvr deploy.zoneinfo

echo "##################################################################"
echo "Building and deploying notification module"
echo "##################################################################"

./bw -notifier

echo "##################################################################"
echo "Deploying log4j configuration"
echo "##################################################################"

./bw deploylog4j

echo "##################################################################"
echo "Deploying activemq configuration"
echo "##################################################################"

./bw deployActivemq

echo "##################################################################"
echo "Deploying run time configuration"
echo "##################################################################"

./bw deployConf

echo "##################################################################"
echo "Building the deployer"
echo "##################################################################"

./bw deployer

echo "##################################################################"
echo "Deploy the .well-known redirector"
echo "##################################################################"

./bw deployDotWellKnown

# Clean it up and copy some files
./bw quickstart-clean
./bw -tzsvr quickstart-clean
./bw -synch quickstart-clean

rm $EXPORT_QS/logs/*
rm -rf $EXPORT_QS/bedework/dist/*

# Zip it up
cd $EXPORTDIR

rm quickstart*.zip
zipFile=$QUICKSTARTDIR_NAME.zip
zip -rq $zipFile $QUICKSTARTDIR_NAME

ls -l $QUICKSTARTDIR_NAME.zip 
