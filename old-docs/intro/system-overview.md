# System Overview 
Bedework System Architecture

Bedework has a central server architecture and is modular and extensible.  It consists of the following components:

  * Bedework core calendar engine
  * Public events web client, called a “Calendar Suite”, for display of public events 
  * Public events cached feeds and widget builder, supporting ical, json, and XML and for producing embeddable JavaScript widgets for use on other websites.
  * Public events administration web client for entering public events, moderating pending events from the submissions client, and configuring calendar suites
  * Public events submission web client for authenticated members of your community to suggest public events – these become pending events in the admin client
  * Personal and group calendaring web client with a subscription model to Bedework  public calendars, user calendars, and external calendar feeds
  * CalDAV server for integration with CalDAV capable desktop (and web) clients such as Apple's iCal or Mozilla Lightning
  * CardDAV server that supports contacts for scheduling in the personal client.
  * A JavaScript-only CardDAV address book web client is available for use with the CardDAV server. The address book comes with the Bedework personal web client, and is suitable for use with other web applications (e.g. webmail).
  * TimeZone server for support of timezone information.
  * Dump/Restore command-line utilities for database backup, initialization, and upgrades.  

## Calendar Architecture

The Bedework system is divided into two main spaces: the public events space, and the personal and group calendaring space which are kept separate by design. Public events are stored below a public calendar root folder and personal calendars are below a user calendar root folder.

![Basic Architecture]({{ site.baseurl }}/resources/bw-basic-arch.png)

Personal calendar users (and other clients) can subscribe to public events, but users may only add public events using the Administrative and Community Submissions web clients. For more information about Bedework's public and personal event calendaring models, see Public Events Calendaring and Personal & Group Calendaring.