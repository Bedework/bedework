#! /bin/bash

base=/Volumes/Data2b/hibernate/hibernate-orm-sv/hibernate-core/target
#cd $base/target
#cp generated-pom.xml libs/hibernate-core-5.2.5.1FinalBwPatched.pom

cd $base/libs

mvn gpg:sign-and-deploy-file \
      -Pbedework-local \
      -DgroupId="org.bedework" \
      -DartifactId="hibernate-core" \
      -Dversion="5.2.5.1FinalBwPatched" \
      -DgeneratePom=false \
      -Dfile="hibernate-core-5.2.5.1FinalBwPatched.jar" \
      -Dsources="hibernate-core-5.2.5.1FinalBwPatched-sources.jar" \
      -Djavadoc="hibernate-core-5.2.5.1FinalBwPatched-javadoc.jar" \
      -DpomFile="hibernate-core-5.2.5.1FinalBwPatched.pom" \
      -DrepositoryId="ossrh" \
      -Durl="https://oss.sonatype.org/service/local/staging/deploy/maven2/"
