## Running the caldav tester

The tester started as an Apple developed project to test CalDAV servers. It has since been taken over by CalConnect adn is in the process of being modified to make the tests more universally applicable.

#### Setup
To run some basic tests there is a script bw-caldavTest/src/main/resources/calconnect-tester/testbw/bw-QuickLook-CalDAV.sh 

This script sets up the tester which needs to be cloned from the repository.

Running the tester requires that a number of users be provisioned in a particular state. 

The quickstart data comes with users user01-user04. Each is setup with 

 * cn: 01,test
 * objectclass: inetOrgPerson
 * objectclass: organizationalPerson
 * objectclass: person
 * objectclass: top
 * sn: user
 * givenname: 01
 * mail: user01@mysite.org
 * uid: user01
 * password: bedework
 
(Replace 01 with 02-04 for the rest)


 

