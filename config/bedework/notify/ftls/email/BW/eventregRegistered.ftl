<#setting date_format="iso">
<#setting time_format="iso m">
<#setting datetime_format="iso m">
<#assign msg = ASnotification.BWeventregRegistered>
<#assign nvs = BWnotifyValues>
<#assign event = nvs.event>
You have been registered to the event http://localhost:8080/pubcaldav/${msg.href}

Start: ${nvs.dtstart?date}
Title: ${nvs.summary}

You requested ${msg.BWeventregNumTicketsRequested} tickets
and have been assigned ${msg.BWeventregNumTickets} tickets
