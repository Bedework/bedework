#! /bin/bash

base=/Volumes/Data2b/hibernate/hibernate-orm-sv/hibernate-core
cd $base/target
cp generated-pom.xml libs/hibernate-core-5.2.5.FinalBwPatched.pom

cd libs

mvn gpg:sign-and-deploy-file \
      -Pbedework-dev \
      -DgroupId="org.bedework" \
      -DartifactId="hibernate-core" \
      -Dversion="5.2.5.FinalBwPatched" \
      -DgeneratePom=false \
      -Dfile="hibernate-core-5.2.5.FinalBwPatched.jar" \
      -Dsources="hibernate-core-5.2.5.FinalBwPatched-sources.jar" \
      -Djavadoc="hibernate-core-5.2.5.FinalBwPatched-javadoc.jar" \
      -DrepositoryId="ossrh" \
      -Durl="https://oss.sonatype.org/service/local/staging/deploy/maven2/"
