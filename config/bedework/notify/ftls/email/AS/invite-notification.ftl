<#assign invite = notification.invite\-notification>
<#assign org = invite.organizer>
<#assign access = invite.access>
You have been invited to share ${invite.hosturl.href}
by ${org.href} (<#if org.display\-name??>${org.display\-name}</#if>)
with
<#if access.read\-write??>read/write</#if>
<#if access.read??>read only</#if> access

Please respond to ....
