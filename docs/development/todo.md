# Todo list

This is a (moderately) sorted list of features/changes etc for bedework. Could bea set of tickets but this is easier to read.

## Imminent changes
Intend to get round to these ones Any Time Now(tm)
  * Filter x-properties in public clients/feeds - list of x-props to retain.

## Future changes
These are longer term. Will pick away at these as time allows.
  
### Api changes
Change the api to use response objects throughout. No exceptions. Allows for a better networked api.

### Notifications
Need to be indexed in ES so that finding a notification for an entity is efficient (need to merge multiple notifications for same entity)
Change notifications for public events is probably not working correctly. We should be using the creator - or the owner of the alias - all public events have the same owner (public-user) and change notifications seem to be ending up in that bucket.

### Limit interactions with db for updates.
For this we would do all interactions with ES and connect to and update db only as needed. Use sequence numbers to ensure db and index correctness. Benefits are shorter db interactions - only at point we update. Less complexity in web clients - no need to have conversations stretching across multiple requests. This can build on the work of the previous item. The web client code is already structured ro assume that it will do an explicit update of entities which should facilitate the change.

### Move business logic out of webapps into core
Move as much as possible out of the current webapps module into the core APi implementation - this potentially allows a more RESTful style of client - possibly using the new jmap style interface being developed.

### Categories
Use a larger category scheme as the basis for categories. Use SKOS based representation so that they are RDF friendly. Will allow for sub-categorization by event submitters.

### Locations
Allow for use of external location sources such as geonames. Will allow good locations on external events.

### Searching improvements
Search for events near a geo-location (requires locations to have geo)

### Caching
Implement caching of feeder data as a built in feature of the quickstart.

### Deployment of ears
Finish off the deployment process - it's THAT close (is there an emoticon for 2 fingers very close together?) to allowing deployers to just replace the ears from prebuilt ears on the site. No builds required - server can detect an update is available.

### Deployment of wildfly modules
If all - or many - required dependencies are deployed as wildfly modules it should reduce the size of the deployment and allow for even quicker startup.

### Networked client api
Subset of svci but can be used for web client interactions.

### Groups
Directory interface to directly interact with grouper for user and admin groups. Allow consumer only approach for external management of groups. Use extra ldap attributes to allow admin groups to be maintained in ldap.

### Index logs in ES
Use kibana to get metrics etc

### Timezones
Update UI to provide a search - possibly based on map. Use tzdist geo feature (being developed)

### General work needed
  * Upgrade ES to latest - changes the query structure
  * Upgrade all libraries to latest
  * Preprocess the xsl to build the deployable language specific versions.


