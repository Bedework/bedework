#Bedework project

This file will be used to provide an overall view of changes to the project. At the moment production releases are still in teh subversion repository as versions 3.x. In the near future we intend to switch to a 4.0 version and changes will be outlined below.

##Bedework modules
The bedework system is comprised of a number of modules, most of which support enterprise calendaring. Some of the 4.x modules are already in use. These are the ones that implement the generic caldav and carddav servers and their dependencies.

These modules are
* Caldav
* Carddav
* Webdav
* access
* util


## Release Notes
There may be a number of releases as we move to a usable 4.x release. The major differences between 4.x and 3.x are as follows

* Schema - schema has changed. A dump and restore is required.
* Data - some changes to the data, for example, all collection hrefs end with "/"
* Wildfly - the only supported application server
 
