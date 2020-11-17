#! /bin/sh

# Used to manually setup wildfly for testing
# Execute for quickstart dir

from_wf="wildfly-17.0.1.Final"
to_wf="wildfly-21.0.0.Final"

# ./galleon-4.2.5.Final/bin/galleon.sh install wildfly:21.0#21.0.0.Final --dir=wildfly-21.0.0.Final --layers=datasources-web-server,jms-activemq

cp $to_wf/standalone/configuration/standalone.xml $to_wf/standalone/configuration/standalone-dist.xml

cp -r $from_wf/standalone/deployments/bw-cal-* $to_wf/standalone/deployments

cp -r $from_wf/standalone/deployments/bw-xml-* $to_wf/standalone/deployments

cp -r $from_wf/standalone/deployments/bw-calendar-xsl-* $to_wf/standalone/deployments

cp -r $from_wf/standalone/deployments/hawtio.war* $to_wf/standalone/deployments

mkdir $to_wf/standalone/log

cp -r $from_wf/modules/com $to_wf/modules

cp -r $from_wf/standalone/configuration/bedework $to_wf/standalone/configuration

cp -r $from_wf/standalone/data/bedework $to_wf/standalone/data

cp -r $from_wf/bedework-content $to_wf/

# rm wildfly
#ln -s wildfly-21.0.0.Final wildfly



