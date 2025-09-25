#! /bin/bash

set -x

# Run from the parent directory with params:
# 1 - name of module
# 2 - version to revert from
# 3 - version to revert to
#
# This MUST have the nexus-staging-plugin installed. It will
# NOT work with the maven release plugin.
#

DIRNAME=`dirname "$0"`

moduleName="$1"
fromVersion="$2"
toVersion="$3"

echo "Are all changes ready - parent version, etc?: "

select yn in Yes No
do
  case $yn in
      Yes) break ;;
      No) echo "make appropriate changes and redo"; exit 1 ;;
  esac
done

trap "exit 2" 1 2 3 15

if [ -z "$JAVA_HOME" ] || [ ! -d "$JAVA_HOME" ] ; then
  echo "JAVA_HOME is not defined correctly."
  exit 1
fi

# 11 onwards
javaVersion=$($JAVA_HOME/bin/java -version 2>&1 | sed -E -n 's/.* version "([^.-]*).*/\1/p')
if [[ "javaVersion" -lt "21" ]]; then
  echo "Java 21 or greater is required"
  exit 1
fi

echo "====== Change directory: $moduleName"
cd $moduleName || exit 1

# Delete old tag if it exists
echo "====== Delete the tag: $fromVersion"
git tag -d "$fromVersion"
git push origin :refs/tags/$fromVersion

echo "====== Set the version: $toVersion"
mvn -Pbedework-dev versions:set -DnewVersion="$toVersion"

echo "====== Commit"
# Commit any outstanding changes + commit version
git commit -am "After setting version $toVersion of $moduleName" || exit 1

echo "====== Push"
git push || exit 1

echo "====== Do clean install - this may take some time."
mvn -Pbedework-dev clean install || exit 1

echo "====== Now cd back to $DIRNAME"
cd $DIRNAME
