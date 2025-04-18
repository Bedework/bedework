# Setting up databases
The quickstart is configured to use h2 for demonstration only. For production you will need to switch to something like postgresql or mysql. 

## postgresql
We'll describe the process for the main calendar engine. The others are very similar.

All bedework and wildfly configuration files are in standalone/configuration/ - we'll just refer to the relative path. 

  * Name: caldb (you can change that if you wish)
  * Configuration: bedework/bwcore/dbconfig.xml
  * datasource: CalendarDS

#### Configure postgresql
You'll probably need to configure postgres to allow your chosen role access to the server and databases.

Depending on how you're running the system you may need to modify postgresql.conf and pg_haba.conf - both located by default in the daat directory.

If you're running postgres on a separate system you may need to change the listen_addresses value and port:

```
listen_addresses = 'localhost'     # what IP address(es) to listen on;
                                   # comma-separated list of addresses;
                                   # defaults to 'localhost'; use '*' for all
                                   # (change requires restart)
port = 5432                        # (change requires restart)            
```

Change "localhost" to "*" or a list of addresses.

5432 is the default port.

To allow your account access you will need to add a line or lines to pg_hba.conf near the end something like:

```
host    all             bedework        10.0.0.1/32        md5
```
This can be made more restrictive by naming the db.


Create a database with a known id/password. Ensure it is accessible from the host you are running bedework on.

The psql commands are something like:

```
create role bedework with login password 'xxxxxxxxx';
create database caldb owner bedework;
```

Set the hibernate dialect in the config file:
```
    <ormProperty>hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect</ormProperty>
```

In standalone.xml replace the datasource definition with something like:

```
    <datasource jta="true" jndi-name="java:/CalendarDS" pool-name="CalendarDS" enabled="true" use-ccm="false">
       <connection-url>jdbc:postgresql://localhost:5432/caldb</connection-url>
       <driver>postgresql</driver>
       <pool>
         <min-pool-size>1</min-pool-size>
         <max-pool-size>50</max-pool-size>
         <prefill>true</prefill>
      </pool>
       <security>
         <user-name>xxxxx</user-name>
         <password>xxxxx</password>
       </security>
       <timeout>
        <idle-timeout-minutes>15</idle-timeout-minutes>
       </timeout>
        <validation>
          <validate-on-match>true</validate-on-match>
          <valid-connection-checker class-name="org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker"></valid-connection-checker>

          <exception-sorter class-name="org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter"></exception-sorter>
       </validation>
       <statement>
         <share-prepared-statements>false</share-prepared-statements>
       </statement>
     </datasource>
```

Ensure you also have the driver loaded - for example the drivers section which usually follows the datasources shoudllook somethign like:

You need to install the postgres driver - you're either missing the driver declaration - something like:

```
<drivers>
    ...
    <driver name="postgresql" module="org.postgresql"/>
    ...
</drivers>
```

Ensure the jdbc driver is installed in the modules directory - something like:

```
wildfly-10.1.0.Final/modules/org/postgresql/main/module.xml
wildfly-10.1.0.Final/modules/org/postgresql/main/postgresql-8.4-701.jdbc4.jar
```

Module.xml for this example contains

```
<?xml version='1.0' encoding='UTF-8'?>

<module xmlns="urn:jboss:module:1.1" name="org.postgresql">
    <resources>
        <resource-root path="postgresql-8.4-701.jdbc4.jar"/>
    </resources>

    <dependencies>
        <module name="javax.api"/>
        <module name="javax.transaction.api"/>
    </dependencies>
</module>
```

Modify it appropriately for different versions.

Start wildfly and allow it to fully deploy. There will be many errors relating to the calendar database.

Delete the file ***wildfly-10.1.0.Final/standalone/data/bedework/dumprestore/schema.sql***

### Use the cli to install the schema.

To run the cli you need the id and password you created when configuring wildfly. This id and password can also be used to access the hawtio console.

```
cd bw-cli/target/client/bin
./client -id admin-id -pw admin-pw
calschema export
```

This should install the schema. It will also create a file which can be manually installed if need be - use the psql client application

```
psql caldb < wildfly-10.1.0.Final/standalone/data/bedework/dumprestore/schema.sql
```

Next you need to add some basic data. For this you need the full path to the initial data in wildfly-10.1.0.Final/standalone/data/bedework/dumprestore/initbedework.xml

In the cli enter the command

```
restoreCal "/full/path/to/initbedework.xml"
```
The quotes are required. Some activity should ensue.

Finally reindex the data - again use the cli

```
rebuildidx
```

wait for it to terminate - then enter

```
listidx
```
The alias ***bwuser*** should be pointing at the index before the last one just created.

In the cli

```
makeidxprod index-name
```
replacing ***index-name*** with that last name - no quotes.

## MySQL

TBD

Set the hibernate dialect in the config file:
```
    <ormProperty>hibernate.dialect=org.hibernate.dialect.MySQL5InnoDBDialect</ormProperty>
```
