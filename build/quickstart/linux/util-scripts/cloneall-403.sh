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
bwAccessVersion="5.0.0"

bwBedeworkVersion="4.0.0"
bwBedeworkParentVersion="4.0.0"

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
bwUtilVersion="5.0.1"
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

    cloneRepoBranch $bwBedeworkVersion bedework
    cloneRepoBranch $bwBedeworkParentVersion bedework-parent
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


