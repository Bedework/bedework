# Installing the quickstart (3.12.x onwards)

Instructions for older releases are [here.](installing-old.md)

The current quickstart is installed by executing a script which will create the quickstart directory and then download, clone and build. In the event of a failure part way through, the script may be restarted with the **restart** parameter.

The script may be downloaded from github [here](https://github.com/Bedework/bedework/raw/master/build/quickstart/linux/installQS.sh). Alternatively clone the [bedework](https://github.com/Bedework/bedework.git) repo and use the script at **bedework/build/quickstart/linux/installQS.sh**

### Which version
The script will ask you if you want the development or latest version.

### Apacheds
The script will install apacheds. This will install a directory with some initial ids in place for testing. Ultimately you'll want to use your own directory service.

### Maven
This is a maven project and as usual you need to set up your maven profile in ~/.m2/settings.xml. The script will display a possible settings.xml file with the paths filled in.

If you want to merge in the profile to an existing settings.xml ensure you also merge in the **pluginGroups** section.

The profile does not need to be active by default if you have other profiles. The build process will specify the bedework-3 profile.

Below is the contents of that settings.xml file. This must be in place before allowing the script to continue on to the builds otherwise they will fail during deployment.

```
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                         http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <pluginGroups>
    <pluginGroup>org.bedework</pluginGroup>
  </pluginGroups>

  <profiles>
    <profile>
      <id>bedework-3</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <properties>
        <org.bedework.deployment.basedir>$qs</org.bedework.deployment.basedir>
      </properties>
    </profile>
  </profiles>
</settings>

```
 
### Building
In many cases it is possible to simply cd in to the appropriate directory and do a mvn install with the bedework-3 profile. However there is a **bw** script which - while taking longer - does build all projects a module depends upon. This avoids the need to work out the dependency orderings of the independent projects. Thus

```./bw deploy```

will build a lot of projects eventually building the client project which deploys an ear file.

### Deploying
As part of the bedework project there is a maven plugin which handles post-build deployment issues. 

The deployment process may involve inserting filters for CAS, adding property values to web.xml files, cloning entire wars for calendar suites etc.

When developing your own service the first thing to do is create a repository with your files.

