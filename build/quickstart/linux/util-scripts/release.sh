#! /bin/bash

set -x

# Run from the parent directory with params:
# 1 - name of module
# 2 - release version
# 3 - next snapshot version
#
# This MUST have the nexus-staging-plugin installed. It will
# NOT work with the maven release plugin.
#

DIRNAME=`dirname "$0"`

moduleName="$1"
releaseVersion="$2"
nextSnapshotVersion="$3"

echo "====== Change directory: $moduleName"
cd $moduleName || exit 1

git status

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
version=$($JAVA_HOME/bin/java -version 2>&1 | sed -E -n 's/.* version "([^.-]*).*/\1/p')
if [[ "$version" -lt "17" ]]; then
  echo "Java 17 or greater is required"
  exit 1
fi

echo "====== Set the release version: $releaseVersion"
mvn -Pbedework-rel versions:set -DnewVersion="$releaseVersion"

echo "====== Commit before release"
# Commit any outstanding changes + commit version
git commit -am "Release version $releaseVersion of $moduleName" || exit 1

echo "====== Push before release"
git push || exit 1

echo "====== Set the tag: $releaseVersion"
git tag -a "$releaseVersion" -m 'Release version $releaseVersion' || exit 1
git push --follow-tags

echo "====== Do clean deploy - this may take some time."
mvn -Pbedework-rel,bedework-local,release clean deploy || exit 1

echo "====== Set up next snapshot $nextSnapshotVersion:"
mvn -Pbedework-rel versions:set -DnewVersion=$nextSnapshotVersion || exit 1

echo "====== Commit the new version"
git commit -am "Update with version $nextSnapshotVersion of $moduleName" || exit 1

echo "====== Push the new version"
git push || exit 1


echo "====== Now rebuild"
mvn -Pbedework-dev,bedework-local,release clean deploy || exit 1

echo "====== Now cd back to $DIRNAME"
cd $DIRNAME || exit 1

echo "================================================================="
echo "================================================================="
echo "+++++++++ Successfully released version $releaseVersion of $moduleName"
echo "================================================================="
echo "================================================================="
