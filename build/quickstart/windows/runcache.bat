::  This file is included by the quickstart script file "..\..\runcache.bat" so that
::  we may keep this script under version control in the svn repository.

@ECHO off
SETLOCAL

SET PRG=%0
For %%A in ("%PRG%") do (
    set commandName=%%~nxA
)

cd vert.x

:: ===================== Defaults =================================

set instances="2"
set mdl="org.bedework~bw-cache-proxy-vertx~3.10-SNAPSHOT"
set conf="conf\cache.conf"


::  =================== End defaults ===============================

:: check for command-line arguments and branch on them

:processargs

if "%1noargs" == "noargs" goto runit

if "%1" == "-usage" GOTO usage
if "%1" == "-?" GOTO usage
IF "%1" == "-instances" GOTO instances
IF "%1" == "-conf" GOTO conf
IF "%1" == "-modules" GOTO modules

:instances
shift 
if "%1noargs" == "noargs" goto usage
set instances=%1%
shift
goto processargs

:conf
shift 
if "%1noargs" == "noargs" goto usage
set conf=%1%
shift
goto processargs

:modules
shift 
if "%1noargs" == "noargs" goto usage
set modules=%1%
shift
goto processargs

:runit
set runcmd=bin\vertx runmod %mdl% -instances %instances% -conf %conf%
echo %runcmd%
%runcmd%

:usage 
echo.
echo  %commandName% [-instances n] [-conf path] [-module mdl] [-usage]
echo.
echo   Where:
echo.
echo     -instances tells vert.x how many copies to start up
echo      typically this would be 1 per CPU core you 
echo      have on the server running it.
echo.

:end
  