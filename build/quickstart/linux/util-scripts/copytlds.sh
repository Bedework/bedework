#! /bin/bash

# Run from the quickstart directory with params:

source1="bw-calendar-client/bw-calendar-client-struts/src/main/resources/META-INF/bwhtml.tld"

cp $source1 bw-calendar-deploy/bw-webclient-cal/src/main/webapp/tlds/
cp $source1 bw-calendar-deploy/bw-webclient-caladmin/src/main/webapp/tlds/
cp $source1 bw-calendar-deploy/bw-webclient-calauth/src/main/webapp/tlds/
cp $source1 bw-calendar-deploy/bw-webclient-demosoe/src/main/webapp/tlds/
cp $source1 bw-calendar-deploy/bw-webclient-feeder/src/main/webapp/tlds/
cp $source1 bw-calendar-deploy/bw-webclient-submit/src/main/webapp/tlds/
cp $source1 bw-calendar-deploy/bw-webclient-ucal/src/main/webapp/tlds/

source2="bw-calendar-client/bw-calendar-client-taglib/src/main/resources/META-INF/bedework.tld"

cp $source2 bw-calendar-deploy/bw-webclient-cal/src/main/webapp/tlds/
cp $source2 bw-calendar-deploy/bw-webclient-caladmin/src/main/webapp/tlds/
cp $source2 bw-calendar-deploy/bw-webclient-calauth/src/main/webapp/tlds/
cp $source2 bw-calendar-deploy/bw-webclient-demosoe/src/main/webapp/tlds/
cp $source2 bw-calendar-deploy/bw-webclient-feeder/src/main/webapp/tlds/
cp $source2 bw-calendar-deploy/bw-webclient-submit/src/main/webapp/tlds/
cp $source2 bw-calendar-deploy/bw-webclient-ucal/src/main/webapp/tlds/
