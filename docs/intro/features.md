# Features of Bedework
  * Java: Written completely in Java, Bedework is system independent.  This version compiles and runs in Java 11.

  * Standards based and interoperable: Interoperability with other calendar systems and clients by way of standards compliance is a fundamental design goal of the Bedework system. The following standards are supported:
    * iCalendar support (rfc5545)
    * iTIP (rfc2446)
    * CalDAV (rfc4791)CalDAV scheduling (draft)
    * CardDAV v.4
    * VPoll (draft)

  * CalDAV server : a full CalDAV server is a core feature of Bedework. It can be used with any CalDAV capable client and has been shown to work with Mozilla Lightning, Apple's iCal, Evolution, and others.

  * CardDAV server : Bedework provides a CardDAV server providing personal and public contact stores for use in the personal client. A stand-alone JavaScript address book application is included with the personal web client suitable for deployment in other web applications such as email web clients.

  * Web clients :The Bedework web clients provide access to public events in guest mode and to public and personal events in authenticated mode. All web clients are easily skinned allowing a high degree of customization.
    * Public calendar suites: Public events are displayed using "calendar suites" allowing multiple organizations to maintain their own public views of events with whatever degree of visibility is appropriate.  A Bedework public calendaring installation may have one or many calendar suites.   A calendar suite provides a customized view of events, custom theming, and control over how events are tagged by event administrators.
    * Public calendar feeds and embeddable JavaScript widgets, supporting ical, jcal, xcal, json, and XML.
    * Personal calendars: Bedework provides a web client for personal and group calendaring including scheduling.  Using CalDAV desktop clients, users can see a fully synchronized view of their personal and subscribed events between their desktop client and the web client.
    * Administrative client for public events: Public event entry and maintenance is carried out through the administrative web client.  The system supports three roles: Super Users control global system settings including user and calendar maintenance and the setup of  calendar suites.  Calendar Suite Owners can modify the settings of their calendar suite, and Event Administrators can add and edit events for the administrative groups to which they belong.
    * Public event community submission: Bedework provides a web client for submitting events to a public queue allowing members of your community who are not event administrators to suggest public events.
    * Public events registration: Bedework supports registration for public events with waitlisting, registrant caps, and notifications.  Custom registration fields can be built and reused for any registerable event.
    * Account Self-registration: This client allows users to register for a Bedework calendar account to register for events or other features.
    * Highly customizable look and feel and standards based: The web clients are themed using CSS and a theme settings file, or by deeper manipulation of XSLT. Designers can theme Bedework for multiple clients and uses, without involving your programming staff. Bedework comes with skins for producing the web clients, data feeds, and displays suitable for handheld devices. Bedework provides a widget builder that makes it easy to embed dynamic event listings on static web sites.

  * Database independence - Hibernate : The core of the calendar uses Hibernate for all database transactions giving support of many database systems and enterprise level performance and reliability. A number of caching schemes are implemented for Hibernate including clustered systems giving further options for improving availability.

  * Sharing : Full CalDAV access control is available allowing the sharing of calendars and calendar entities based on authentication status and identity.

  * Scheduling :  Bedework supports scheduling of meetings including invitations and their responses. Caldav scheduling (still in draft) is supported. Freebusy is supported and the busy time is displayed as attendee lists are built.  Access control allows users to determine who may attempt to schedule meetings with them.

  * Import and export : Events can be imported and exported in iCalendar (RFC2445) format. This provides an option for populating the calendar from external sources.  A dump/restore utility provides a means to backup and restore xml data files.

  * Calendar subscriptions : Users may subscribe to calendars to which they have access, including public and personal calendars. iCalendar data feeds are available from the public web client.

  * Multiple calendars : The core system supports multiple calendars for users and for public events.

  * Tagging & Filtering :  Events and folders can be tagged by any number of categories and event views, feeds, and widgets can be filtered by these.

  * Internationalization : Bedework supports full internationalization, including multilingual content (though multilingual content creation is not yet exposed in the web UI).

  * Data feeds: Bedework produces RSS, Javascript (e.g. json), iCalendar, and XML feeds.  Custom feeds can be developed by writing an XSL skin. Feeds can be filtered by category or creator, and a feed and widget builder is available to help end users and developers design public feeds and embeddable event widgets.

  * Portal support : Bedework has been shown to work as a JSR168 portlet in Jetspeed, uPortal and Liferay using the portal-struts bridge.

  * Timezone support : Full timezone support is implemented. There is a set of system defined timezones based upon externally available sets of timezone definitions. In addition users are able to store their own timezone definitions.

  * Recurring events : Extensive recurring event support is available via CalDAV and the web clients.

  * Event references : Users may add public event references to their personal calendars. Event references can be annotated by the user.

  * Pluggable group support : Bedework uses a pluggable class implementation to determine group membership for authenticated users allowing organizations to implement a class which uses an external directory. The default class uses internal tables to maintain group membership. Different implementations can be used for administrative and personal use allowing the separation of any given users roles.

  * Container authentication :  There is no authentication code in Bedework.  Rather, Bedework behaves as a standard servlet, and all authentication is carried out through external mechanisms. Standard container authentication (via Tomcat or Jboss) and filter based Yale CAS authentication are used in production.  The quickstart comes packaged with the Apache DS server against which the quickstart deployment of Bedework authenticates.  This server can be used in production, though many deployers opt to authenticate against their organization's existing directory.

  * Support for other calendar systems and clients : It is possible to access an entire calendar with a single url. This can be used to subscribe to a Bedework calendar from Google or Outlook. Bedework can also take advantage of the richness of CalDAV capable desktop clients such as Apple's iCal and Mozilla Lightning.
  