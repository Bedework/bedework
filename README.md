# Bedework project

This project contains configurations and scripts used to build the quickstart and will be used to provide an overall view of changes to the project. At the moment production releases of the calendar engine, client and quickstart are versions 3.x. Other modules are 4.x.

## Bedework modules
The bedework system is comprised of a number of modules, most of which support enterprise calendaring. The 4.x modules are already in use. These are the ones that implement the generic caldav and carddav servers and their dependencies.

These modules include
* Caldav
* Carddav
* Webdav
* access
* util
* util-logging

## Installing
Please see the [current (but incomplete) documentation](http://bedework.github.io/bedework/#installing-the-quickstart).

## Release Notes
These are in the [github pages documents](http://bedework.github.io/bedework/#release-notes).

## Releasing

Releases of this fork are published to Maven Central via Sonatype.

To create a release, you must have:

1. Permissions to publish to the `org.bedework` groupId.
2. `gpg` installed with a published key (release artifacts are signed).

To perform a new release - first commit and push any changes then:
 
> mvn release:clean release:prepare

When prompted, select the desired version; accept the defaults for scm tag and next development version.
When the build completes, and the changes are committed and pushed successfully, execute:

> mvn release:perform

For full details, see [Sonatype's documentation for using Maven to publish releases](http://central.sonatype.org/pages/apache-maven.html).

## Release Order
Modules need releasing in the order shown below. After each module release, update the dependencies in the remaining modules to refer to the newly released module.

  * bw-xml
  * bw-util-logging
  * bw-util
  * bw-util2
  * bw-util-hibernate
  * bw-access
  * bw-cli (No dependencies to update)
  * bw-timezone-server (No dependencies to update)
  * bw-self-registration (No dependencies to update)
  * bw-synch (No dependencies to update)
  * bw-event-registration (No dependencies to update)
  * bw-webdav
  * bw-carddav (No dependencies to update)
  * bw-caldav
  * bw-notifier (No dependencies to update)
  * bw-calendar-engine
  * bw-calendar-client
