<#setting date_format="iso">
<#setting time_format="iso m">
<#setting datetime_format="iso m">
<#assign msg = ASnotification.BWeventregCancelled>
<#assign nvs = BWnotifyValues>
<#assign event = nvs.event>

The event ${msg.href} has been cancelled

Start: ${nvs.dtstart?date}
Title: ${nvs.summary}