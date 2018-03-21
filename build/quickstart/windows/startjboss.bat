@ECHO off
SETLOCAL
:: Script to start jboss with properties defined
:: This currently needs to be executed out of the quickstart directory
:: (via a source)

SET BASE_DIR=%CD%
SET PRG=%0

:: Set defaults
SET heap=600M
SET newsize=200M
SET permsize=256M
SET testmode=
SET profiler=

SET startH2=true
SET activemquri=vm://bedework

SET portoffset=0
SET LOG_THRESHOLD=-Djboss.server.log.threshold=INFO

:: Figure out where java is for version checks
IF "%JAVA_HOME%" == "" GOTO nojavahome
SET JAVA=%JAVA_HOME%\bin\java
GOTO javaset

:nojavahome
SET JAVA="java"


:javaset
set java8plus=true

for /f tokens^=2-5^ delims^=.-_^" %%j in ('%JAVA% -fullversion 2^>^&1') do set "version=%%k"
if %version% gtr 7 set java8plus = true

:javaset
GOTO branch

:debug
  SHIFT
  SET LOG_THRESHOLD=-Djboss.server.log.threshold=DEBUG
  GOTO branch

:heap
  SHIFT
  SET heap=%1
  SHIFT
  GOTO branch

:newsize
  SHIFT
  SET newsize=%1
  SHIFT
  GOTO branch

:permsize
  SHIFT
  SET permsize=%1
  SHIFT
  GOTO branch

:noh2
  SHIFT
  startH2=false
  GOTO branch

:h2
  SHIFT
  startH2=true
  GOTO branch

:portoffset
  SHIFT
  SET portoffset=%1
  SHIFT
  GOTO branch

:profile
  SHIFT
  SET profiler=-agentlib:yjpagent
  GOTO branch

 :testmode
  SHIFT
  SET testmode=-Dorg.bedework.testmode=true
  GOTO branch

:activemquri
  SHIFT
  SET activemquri=%1
  SHIFT
  GOTO branch

:doneWithArgs

SET JBOSS_VERSION=jboss-5.1.0.GA
SET JBOSS_CONFIG=default
SET JBOSS_SERVER_DIR=%BASE_DIR%\%JBOSS_VERSION%\server\%JBOSS_CONFIG%
SET JBOSS_SERVER_DIR_FORWARD_SLASHES=%JBOSS_SERVER_DIR:\=/%
SET JBOSS_DATA_DIR=%JBOSS_SERVER_DIR%\data

:: If this is empty only localhost will be available.
:: With this address anybody can access the consoles if they are not locked down.
SET JBOSS_BIND=-b 0.0.0.0

::
:: Port shifting
::

:: standard ports
SET JBOSS_PORTS=-Dorg.bedework.system.ports.offset=%portoffset%

:: standard ports + defined value
::JBOSS_PORTS=-Dorg.bedework.system.ports.offset=505 -Djboss.service.binding.set=ports-syspar

SET ACTIVEMQ_DIRPREFIX=-Dorg.apache.activemq.default.directory.prefix=%JBOSS_DATA_DIR%\
SET ACTIVEMQ_URI=-Dorg.bedework.activemq.uri=%activemquri%

SET LOG_THRESHOLD=-Djboss.server.log.threshold=DEBUG

SET BW_DATA_DIR=%JBOSS_DATA_DIR%\bedework
SET BW_DATA_DIR_DEF=-Dorg.bedework.data.dir=%BW_DATA_DIR%\

:: Define the system properties used to locate the module specific data

::         carddav data dir
SET BW_CARDDAV_DATAURI=%BW_DATA_DIR%\carddavConfig
SET BW_CARDDAV_DATAURI_DEF=-Dorg.bedework.carddav.datauri=%BW_CARDDAV_DATAURI%/
SET BW_DATA_DIR_DEF=%BW_DATA_DIR_DEF% %BW_CARDDAV_DATAURI_DEF%

::         synch data dir
SET BW_SYNCH_DATAURI=%BW_DATA_DIR%\synch
SET BW_SYNCH_DATAURI_DEF=-Dorg.bedework.synch.datauri=%BW_SYNCH_DATAURI%\
SET BW_DATA_DIR_DEF=%BW_DATA_DIR_DEF% %BW_SYNCH_DATAURI_DEF%

:: Configurations property file

SET BW_CONF_DIR=%JBOSS_SERVER_DIR_FORWARD_SLASHES%/conf/bedework
SET BW_CONF_FILE_DEF=-Dorg.bedework.config.pfile=%BW_CONF_DIR%/config.defs
SET BW_CONF_DIR_DEF=-Dorg.bedework.config.dir=/%BW_CONF_DIR%/

set tempstring=
set string=%string: =_%
echo %string%

:: Elastic search home

SET ES_HOME=%BW_DATA_DIR%\elasticsearch
SET JAVA_OPTS=%JAVA_OPTS% -Des.path.home=%ES_HOME%

SET JAVA_OPTS=%JAVA_OPTS% -Xms%heap% -Xmx%heap%

IF %java8plus% == "false" goto NOTJAVA8
  SET JAVA_OPTS=%JAVA_OPTS% -XX:MetaspaceSize=%permsize% -XX:MaxMetaspaceSize=%permsize%
GOTO DONEJAVA8
:NOTJAVA8
  SET JAVA_OPTS=%JAVA_OPTS% -XX:PermSize=%permsize% -XX:MaxPermSize=%permsize%
:DONEJAVA8
SET JAVA_OPTS=%JAVA_OPTS% -XX:PermSize=%permsize% -XX:MaxPermSize=%permsize%

:: Put all the temp stuff inside the jboss temp
SET JAVA_OPTS=%JAVA_OPTS% -Djava.io.tmpdir=%JBOSS_SERVER_DIR%\tmp
SET JAVA_OPTS=%JAVA_OPTS% %profiler%

SET RUN_CMD=.\%JBOSS_VERSION%\bin\run.bat
SET RUN_CMD=%RUN_CMD% -c %JBOSS_CONFIG%

SET RUN_CMD=%RUN_CMD% %JBOSS_BIND% %JBOSS_PORTS%
SET RUN_CMD=%RUN_CMD% %LOG_THRESHOLD%
SET RUN_CMD=%RUN_CMD% %ACTIVEMQ_DIRPREFIX% %ACTIVEMQ_URI%
SET RUN_CMD=%RUN_CMD% %BW_CONF_DIR_DEF% %BW_CONF_FILE_DEF% %BW_DATA_DIR_DEF%

:: Specifying jboss.platform.mbeanserver makes jboss use the standard
:: platform mbean server.
SET RUN_CMD=%RUN_CMD% -Djboss.platform.mbeanserver

:: Set up JMX for bedework
:: RUN_CMD="$RUN_CMD -Dorg.bedework.jmx.defaultdomain=jboss"
SET RUN_CMD=%RUN_CMD% -Dorg.bedework.jmx.isJboss5=true
SET RUN_CMD=%RUN_CMD% -Dorg.bedework.jmx.classloader=org.jboss.mx.classloader
IF "%startH2%" == "false" GOTO NORUNH2

:: Set up h2 database
ECHO Starting h2 database in %JBOSS_DATA_DIR%\h2
start /b %JAVA% -cp %JBOSS_SERVER_DIR%\lib\h2-1.4.190.jar org.h2.tools.Server -tcp -web -baseDir %JBOSS_DATA_DIR%\h2

:NORUNH2
ECHO.
ECHO Starting Bedework JBoss:
ECHO %RUN_CMD%
ECHO.
ECHO.

%RUN_CMD%
GOTO:EOF


:: Iterate over the command line arguments;
:: DOS Batch labels can't contain hyphens, so convert them
:: (otherwise, we could just "GOTO %1")
:branch
IF "%1" == "-usage" GOTO usage
IF "%1" == "-debug" GOTO debug
IF "%1" == "-heap" GOTO heap
IF "%1" == "-newsize" GOTO newsize
IF "%1" == "-permsize" GOTO permsize
IF "%1" == "-portoffset" GOTO portoffset
IF "%1" == "-noh2" GOTO noh2
IF "%1" == "-h2" GOTO h2
IF "%1" == "-profile" GOTO profile
IF "%1" == "-testmode" GOTO testmode
IF "%1" == "-activemquri" GOTO activemquri
GOTO doneWithArgs

:usage
ECHO.
ECHO.
ECHO.
ECHO startjboss.bat [-heap size] [-newsize size] [-permsize size]
ECHO                [-portoffset n] [-activemquri uri]
ECHO.
ECHO Where:
ECHO.
ECHO -heap sets the heap size and should be n for bytes
ECHO                                        nK for kilo-bytes (e.g. 2560000K)
ECHO                                        nM for mega-bytes (e.g. 256oM)
ECHO                                        nG for giga-bytes (e.g. 1G)
ECHO. Default: %heap%
ECHO.
ECHO -permsize sets the permgen size and has the same form as -heap
ECHO   The value should probably not be less than 256M
ECHO. Default: %permsize%
ECHO.
ECHO. -activemquri sets the uri used by the activemq broker for bedework
ECHO.  Some possibilities: vm://localhost tcp://localhost:61616
ECHO.  Default: %activemquriDefault%
ECHO.
ECHO. -portoffset sets the offset for the standard jboss ports allowing
ECHO.  multiple instances to be run on the same machine. The activemquri
ECHO.  value may need to be set explicitly if it uses a port.
ECHO.  Default: %portoffset%
ECHO.
