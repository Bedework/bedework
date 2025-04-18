#!/usr/bin/env bash


# $1 - name
cloneRepoBranch() {
  tag=$1
  packageName=$2

  echo "---------------------------------------------------------------"
  echo "Clone $packageName"

  echo "git clone https://github.com/Bedework/$packageName.git"
  git clone https://github.com/Bedework/"$packageName".git

  cd $packageName
  git checkout $tag
  cd ..

  # Going too fast seemed to cause github issues
  sleep 5
}

# -------------------Package versions -----------------------------
bwAccessVersion="5.0.3"

bwBedeworkVersion="4.1.1-SNAPSHOT"
bwBedeworkParentVersion="85"

bwCaldavVersion="5.0.8"
bwCalendarClientVersion="4.1.2"
bwCalendarCommonVersion="4.1.3"
bwCalendarDeployVersion="4.1.1"
bwCalendarDumprestoreVersion="4.2.0"
bwCalendarEngineVersion="4.1.4"
bwCalendarXslVersion="4.1.1"
bwCarddavVersion="5.0.3"
bwCategoryVersion="4.0.3"
bwCliVersion="5.0.3"
bwCliutilVersion="5.0.0"

bwEventRegistrationVersion="5.0.5"

bwJsforJVersion="1.1.0"

bwLogsVersion="1.1.1"

bwNotifierVersion="5.0.3"

bwQuickstartVersion="4.0.3"

bwSelfRegistrationVersion="5.0.2"
#bwSometimeVersion="2.0.0"
bwSynchVersion="5.0.11"

bwTimezoneServerVersion="5.0.6"

bwUtilLoggingVersion="5.2.0"
bwUtilVersion="5.0.7"
bwUtilConfVersion="5.0.2"
bwUtilDeployVersion="5.0.6"
bwUtilHibernateVersion="5.0.4"
bwUtilIndexVersion="5.0.2"
bwUtilNetworkVersion="5.1.5"
bwUtilTzVersion="5.0.0"
bwUtilSecurityVersion="5.0.0"
bwUtil2Version="5.0.8"

bwWebdavVersion="5.0.5"
bwWfmodulesVersion="1.0.8"
bwWildflyFeaturePackVersion="4.0.3"

#bwXmlVersion="5.0.1"

    cloneRepoBranch $bwBedeworkVersion bedework
    cloneRepoBranch $bwBedeworkParentVersion bedework-parent
    cloneRepoBranch $bwAccessVersion bw-access
    cloneRepoBranch $bwCaldavVersion bw-caldav
    cloneRepoBranch $bwCalendarClientVersion bw-calendar-client
    cloneRepoBranch $bwCalendarCommonVersion bw-calendar-common
    cloneRepoBranch $bwCalendarDeployVersion bw-calendar-deploy
    cloneRepoBranch $bwCalendarDumprestoreVersion bw-calendar-dumprestore
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

    #cloneRepoBranch $bwXmlVersion bw-xml


