# Bedework Public Events Registration System

Bedework supports a public events registration system that allows authenticated users to register for events. Users may view and modify their registrations, such as unregistering or changing the number of tickets they've requested. When registration is full, users may choose to be placed on a waiting list. Users on waiting lists will automatically be moved up in the queue if space becomes available.

![Registered Event](resources/eventRegRegistered.png)

Administrators can specify how many users may register, how many tickets each registrant may request, and set the opening and closing dates of registration.  Administrators can view and modify a registration list and download CSV files of their registrations on-demand.

![Register Event Form](resources/eventRegAdminForm.png)

Data about the event is maintained in x-properties attached to the event and provides the following information:

  * Booking window start and end
  * Number of tickets
  * Max number of tickets per person

