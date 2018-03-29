# Bedework project

This project contains configurations and scripts used to build the quickstart and will be used to provide an overall view of changes to the project. At the moment production releases of the calendar engine, client and quickstart are versions 3.x. Other modules are 4.x.

## Bedework modules
The bedework system is comprised of a number of modules, most of which support enterprise calendaring. Some of the 4.x modules are already in use. These are the ones that implement the generic caldav and carddav servers and their dependencies.

These modules are
* Caldav
* Carddav
* Webdav
* access
* util


## Release Notes
### Changes for release 3.11.1:

  * Change the schema and filter to allow searches on x-properties.
  * Backported carddav changes from 3.11.2

### Changes for release 3.11.2:

##### Indexing
  * Add a reindex operation which reindexes all the data in place. Used when ES schema changes.
  * Add an indexstats operation to get counts for a named index
  * Add a setProdAlias operation. Rebuild index no longer automatically makes new index prod. This also allows us to back off the index.
  * Extra operations added to cli to reindex and change indexes
  * Fix update of UpdateInfo in ES index. Was doing a string concat rather than an increment.
  * Index individual location fields so they can be searched
  * Add a fetch single event method to the indexer
  * Synch around event cache accesses

##### Notifications
  * Add a preference to allow suppression of notifications for a user. This shoudl be applied to public-user to avoid a lot of overhead
  * Change logging is now modified. Messages are now logged to audit.org.bedework.chgnote. Requires a change to standalone.xml or the equivalent
  
##### Sync and orgSync:
  * Add orgSync connector to sync engine
  * Fully index location sub-fields - add a set of keys for mapping locations
  * New indexer methods to enable searching for particular location keys
  * Allow specification of a mapping key in subscription and in x-property
  * Updates x-calendar xsd for mapping key as param
  * Changes to admin client to allow specification of orgSync
  * Upgrade to httpClient to handle orgSync certs
  * Add further parameters to OrgSync subscription -updated admin client to support
  * Unsubscribe before deleting content to avoid race.
  * Get persisted event on fetch for update
  * Allow for pw without id in subscription - it's the key in OrgSync
  * Implement setting category on add and update from containing collection.
  * Update was setting datestamps before checking for no changes - was propagated to db entity preventing further updates.
  * Do a better job of setting content-type and encoding for SOAP interactions.
  * Add array of keys to location entity for use by synch process.
  * Fix handling of locations in Synch engine. Add the locKey parameter to the location. It gets propagated to the x-prop for use later.
  * Refresh rate wasn't getting through. Fixed

##### Public events admin
  * Try to mitigate errors caused when a validation error occurs on publish. Indexed and db version did not match.
  * Added missing retry action in event submit.
  * Fixed race condition when selecting a group in admin client
  * Fix the eventsPending page. POST was losing the filter
  * Calsuite specific approvers
  * Avoid ConcurrentModificationException in admin client
  * Changes for eventreg
      * Add some commands to cli
      * Use wildfly modules
      * More HttpUtil methods for use in eventreg and sync
      * Fix web.xml and post-deploy for wildfly
  * Use of deleted flag
      * Index the flag
      * Changes to allow DeleteEventAction to just set the flag
      * Searching can filter on deleted flag
      * Add mark deleted button to form
  * Add tool command to set authuser roles
  * Add tool command to add/remove approver for calsuite

##### Clients
  * Fix errors caused by entry into showEventMore with a new session
  * Switch public client to use href in urls instead of calPath + guid + recurrenceId
  * Last date in header was the same as the first date

##### Other 
  * Removed the principal path elements from the basic config. Changing them is always a bad idea so they may as well be fixed.
  * Use wildfly modules where possible - ensure we get consistent SOAP behavior
  * Further changes for httpclient. Fix to timezones
  * Logging changes to try to reduce output
  * Try to spot ConnectionResetByPeer errors and leave quietly
  * Try to make less noise when a hung session is shut down
  * Avoid tzsvr startup errors - and db should be static
  * Allow setting of session timeout in deploy properties
  * Drop deprecated jboss config
  * Allow setting of soap address in post deploy
  * Try to fix some issues with JMX which surfaced when testing eventreg
  * Add an Events method to calculate instances for recurring event
  * Fix carddav logging
  * Add flag to ifInfo to indicate a dontKill server process. Stops
    autokill killing off some of the long running system jobs.
  * Fixes to get carddav working again. Most of them backported to 3.11.1  
  * Fixes to get vpoll working again. Broke as a result of ical4j upgrade.
  * Add event dumping to the new (incomplete) dump format.
  * Try another approach to stop exceptions when a new user turns up

### Changes for release 3.12.0:
##### Move to github/maven
  * A number of modules have been replaced with their github/maven equivalents from the 4.x branches. Other than changes for the build process these modules are functionally equivalent. This change was initiated to make some module classes available for externally built plugin modules. The 3.x modules and their 4.x replacements are:
    * rpiutil -> bw-util
    * bwaccess -> bw-access
    * webdav -> bw-webdav
    * caldav -> bw-caldav (bwcaldav is the bedework implementation of the interface)
    * bwxml -> bw-xml
    * eventreg -> bw-event-registration
    * selfreg -> bw-self-registration
    * synch -> bw-synch
  * Related changes were to build the runnable post-deploy app in bw-util-bw-deploy and run that. Some configuration properties had to be changed to align.
  
  * Having done the above the master on github for the calendar engineand client is now the current 3.x dev version, there is a 4.x branch for future development and release branches will be created as necessary. 
  
##### Related to maven/github switch
  * The urls for wsdls is changed. e.g. /wsdls/synch/wssvc.wsdl becomes /xmlspecs/wsdls/synchws/wssvc.wsdl. This necessitates changes to configurations:
    * synch/../orgSyncV2.xml
    * synch/../localBedework.xml
    * bwengine/synch.xml
    * bwengine/system.xml
    * eventreg.xml
  * Yet more refactoring was needed. Turns out we had an unbuildable set of modules with bw-xml depending on bw-util for the deployment. Broke out the 2 modules with a dependency on bw-xml as bw-util2
  * Moved all teh xsl into it's own module - bw-calendar-xsl. Thi salso needs changes to configs - all xsl url paths are now prefixed with /approots - the context at which the xsl is deployed. Look for elements appRoots and browserResourceRoots in the configs

##### Scheduling
  * Fixes to scheduling code to try to ensure pending inbox events get deleted
  * Updates to iSchedule client for later version of httplient. Moved some code out of caldav tester into common utils
   
##### Notifications
  * Fix the listeners so they close down without exceptions

##### Websockets
  * Add code to support websockets for a new experimental streaming protocol (a CalConnect initiative)
  * Many changes to build process - wewbsockets applications cannot be inside an ear file. Now possible to deploy as a standalone war. Websockets endpoint is now a separate module.
  * Websockets moduleacts as a proxy to caldav.
  
##### Other 
  * Delay getting a change table entry when realiasing. Was intefering with a test in update.
  * Getting deadlocks when deleting tombstoned events. Change the colpath so they disapppear but need a purge process to finally remove them. 
  * Tasks collections were not getting created with correct type - nor were they returning a supportd component type.
  * Some fixes to the selfreg feature and additions to the cli to drive it.
   
