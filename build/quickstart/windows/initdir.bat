::  This file is included by the quickstart script file "initdir" so that
::  we may keep this script under version control in the svn repository.

@ECHO off
SETLOCAL

  ECHO.
  ECHO.
  ECHO   Bedework Calendar System
  ECHO   ------------------------
  ECHO.

  SET PRG=%0
  SET saveddir=%CD%
  SET QUICKSTART_HOME=%saveddir%
  SET ANT_HOME=%QUICKSTART_HOME%\apache-ant-1.7.0

  IF NOT "%JAVA_HOME%empty" == "empty" GOTO javaOk
  ECHO    *******************************************************
  ECHO    Error: JAVA_HOME is not defined correctly for Bedework.
  ECHO    *******************************************************
  GOTO usage

:javaOk
  SET CLASSPATH=%ANT_HOME%\lib\ant-launcher.jar
  SET ant_home_def="-Dant.home=%ANT%"
  SET ant_class_def="org.apache.tools.ant.launch.Launcher"

  "%JAVA_HOME%\bin\java" -classpath "%CLASSPATH%" %ant_home_def% %ant_class_def% initDir
  GOTO:EOF

:usage
  ECHO.
  ECHO    Usage:
  ECHO.
  ECHO    %PRG%
  ECHO.
  ECHO    Invokes ant to build the Bedework tools then uses that tool to
  ECHO    initialise the directory.
  ECHO.
  ECHO.
