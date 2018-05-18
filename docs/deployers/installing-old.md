# Installing the quickstart (versions previous to 3.12.x)

These quickstarts are complete and packaged up as downloadable zip files available from [the dev.bedework.org download site](http://dev.bedework.org/downloads).

Navigate to the desired version and download.

Once unzipped it's advisable to ensure it is fully up to date. 

```
cd <into-the-quickstart>
./bw -updateall
./bw deploy
```

will update everything then build the main calendar engine, web clients and caldav.

We have attempted to make the quickstart as close to a production-ready system as possible. To move to deployment, you willneed to move to a production database. You may also choose to use local authentication (against ldap, CAS, Shib, etc), front Bedework with Apache, or make further customizations. In all cases, begin with the Bedework Quickstart.

For more information about deploying a production system, see Deploying Bedework – but read this chapter first!

Packaged with the quickstart

  *  Bedework: Calendar engine, CalDAV, CardDAV, Timzone servers, and web clients
  * Wildfly (or jboss for older versions)
  * Apache DS 1.5 (apacheds-1.5.3-fixed)
  * HSQL or H2 provides the demonstration database
  * Vert.x/web page caching application

