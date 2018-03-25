#Synch Engine
The synch engine handles the synchronization of external subscriptions with a bedework calendar - for example a Google web calendar or an ical feed from a department.

Currently such a synchronization must be carried out to a single calendar collection which only contains data from the external resource. Also only one way synchronization is supported - inbound to bedework.

These subscriptions are available to personal calendar users and to public events administrators. For personal calendar users the options are limited as it is intended only to mirror the external resource.
Initializing the database

If running with mysql the built in hibernate schema export doesn't work - mysql jdbc does not support it.

The schema is simple however - it can be generated via the JMX mbeans or use the examples below - to install it manually, create a database - ensure UTF-8 is enabled


```
CREATE DATABASE `synchdb` DEFAULT CHARACTER SET utf8;
grant all on synchDb.* to '<id>'@'%' identified by '<pw>'; 

```
and then create the single table:


```
CREATE TABLE `bwsynch_subs` (
  `bwsyn_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `bwsyn_seq` int(11) NOT NULL,
  `bwsyn_subid` varchar(250) NOT NULL,
  `bwsyn_owner` varchar(500) NOT NULL,
  `bwsyn_lrefresh` varchar(20) DEFAULT NULL,
  `bwsyn_errorct` int(11) DEFAULT NULL,
  `bwsyn_missing` char(1) NOT NULL,
  `bwsyn_connectorid_a` varchar(100) DEFAULT NULL,
  `bwsyn_conn_props_a` varchar(3000) DEFAULT NULL,
  `bwsyn_connectorid_b` varchar(100) DEFAULT NULL,
  `bwsyn_conn_props_b` varchar(3000) DEFAULT NULL,
  `bwsyn_props` varchar(3000) DEFAULT NULL,
  `bwsyn_dir` varchar(25) NOT NULL,
  `bwsyn_mstr` varchar(25) NOT NULL,
  PRIMARY KEY (`bwsyn_id`),
  UNIQUE KEY `UK_qptomm2syatpqumsl1udwk7be` (`bwsyn_subid`),
  KEY `bwsynidx_subid` (`bwsyn_subid`),
  KEY `bwsynidx_subowner` (`bwsyn_owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

```

(Re)build bwxml

The synch engine uses an extension of CalWS to communicate with bedework. It requires that the wsdl file contain the location of bedework. This is configured into the deploy.properties file - only one change for the synch engine should be necessary. Set the location of (one of) your application servers in the following.


```
# ------------------------------------------------------------------------
#       wsdls; ear bw-xml
# These go together - first name the wsdl directories and files...
org.bedework.app.bw-xml.bwwsdls.wsdl.synch=wssvc.wsdl

# then provide the global properties
org.bedework.global.synch.service.location=http://localhost:8080/synchws/ 


```
If you are running everything on one server then the quickstart setting above will do. Note that at the moment the synch engine can only work against a single bedework server. It can accept requests from any member of the cluster however.
Keys

Generate a set of keys using the cli.


```
cd bwcli/dist/temp/shellscr/bwcli/ (or wherever your binary is)
./bwcli.sh 
/usr/lib/jvm/java-8-oracle/bin/java -cp .:./classes:./resources:lib/bw-access-3.11.0.jar:lib/bw-annotations-3.11.0.jar:lib/bw-calfacade-3.11.0.jar:lib/bwcli-3.11.0.jar:lib/bw-ical4j-vcard-1.0.5.jar:lib/commons-collections4-4.0.jar:lib/commons-lang-2.3.jar:lib/commons-lang3-3.3.2.jar:lib/commons-logging.jar:lib/httpclient-osgi-4.3.3.jar:lib/ical4j-2.0.6.jar:lib/jackson-annotations-2.1.1.jar:lib/jackson-core-2.1.1.jar:lib/jackson-databind-2.1.1.jar:lib/jolokia-client-java-1.3.1.jar:lib/json-simple-1.1.1.jar:lib/log4j-1.2.8.jar:lib/rpiutil-3.11.0.jar org.bedework.bwcli.BwCli
JMX id:<your id>
Password:<your password>
cmd:genkeys gen
test with---->A variable of array type holds a reference to an object. 
encrypts to-->BaUPfgTjzZxxbbW+lJACxmdo56tldkgfnr7LERkRTVyLQJh0kVt+GJZgJA1k9Wm+ojvpJCYFl34ybTy0vX2PM8Tu0+UsMKeV3HDi24NW6cH+C+QQ6XATLtskiBPhUQufpHBIKCke08PNh24xCoIk9+hllLgQQNCgVB1JQnQA0ak=
decrypts to-->A variable of array type holds a reference to an object. 

Validity check succeeded

```

If you are using multiple servers copy the resulting key file from <quickstart>/wildfly-10.1.0.Final/standalone/data/bedework/ on to each server.
Ensure calendar server(s) can locate the synch engine.

The bwengine/synch settings are configured to use a jvm system property to locate the synch engine. In file <quickstart>/wildfly-10.1.0.Final/standalone/confgiuration/bedework/bwengine/synch.xml you should see:


```
<?xml version="1.0" encoding="UTF-8" ?>

<synch xmlns="http://bedework.org/ns/" type="org.bedework.calsvc.jmx.SynchConfigImpl">
  <connectorId>localBedework</connectorId>
  <managerUri>http://localhost:8080/synch/manager</managerUri>
  <wsdlUri>http://localhost:8080/wsdls/synch/wssvc.wsdl</wsdlUri>
</synch>

```
If you are using multiple servers change the host in <managerUri> to refer to your sync server.
Validating locations.
When an event arrives at the receiving end with an "X-BEDEWORK-LOCATION" property if the String value of the x-property is ...