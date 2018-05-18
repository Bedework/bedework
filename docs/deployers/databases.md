# Setting up databases
The quickstart is configured to use h2 for demonstration only. For production you will need to switch to something like postgresql or mysql. 

## postgresql
We'll describe the process for the main calendar engine. The others are very similar.

All configuration files are in standalone/configuration/ - we'll just refer to the relative path. 

  * Name: caldb (you can change that if you wish)
  * Configuration: bedework/bwcore/dbconfig.xml
  * datasource: CalendarDS

Create a database with a known id/password. Ensure it is accessible from the host you are running bedework on.

Set the hibernate dialect in the config file:
```
    <hibernateProperty>hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect</hibernateProperty>
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
    <hibernateProperty>hibernate.dialect=org.hibernate.dialect.MySQL5InnoDBDialect</hibernateProperty>
```
