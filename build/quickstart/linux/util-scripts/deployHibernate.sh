#! /bin/bash

cd /Users/mike/.m2/repository/org/bedework/hibernate-core/5.2.5.FinalBwPatched/

gpg2 --output hibernate-core-5.2.5.FinalBwPatched.jar.asc --detach-sig hibernate-core-5.2.5.FinalBwPatched.jar

gpg2 --output hibernate-core-5.2.5.FinalBwPatched-sources.jar.asc --detach-sig hibernate-core-5.2.5.FinalBwPatched-sources.jar

gpg2 --output hibernate-core-5.2.5.FinalBwPatched.pom.asc --detach-sig hibernate-core-5.2.5.FinalBwPatched.pom

mvn deploy:deploy-file \
      -Pbedework-dev \
      -DpomFile="/Users/mike/bedework/quickstart-dev/bedework/tmp/.m2/repository/org/bedework/hibernate-core/5.2.5.FinalBwPatched/hibernate-core-5.2.5.FinalBwPatched.pom" \
      -Dfile="/Users/mike/bedework/quickstart-dev/bedework/tmp/.m2/repository/org/bedework/hibernate-core/5.2.5.FinalBwPatched/hibernate-core-5.2.5.FinalBwPatched.jar" \
      -DrepositoryId="ossrh" \
      -Durl="https://oss.sonatype.org/service/local/staging/deploy/maven2/"

mvn deploy:deploy-file \
      -Pbedework-dev \
      -DgroupId="org.bedework" \
      -DartifactId="hibernate-core" \
      -Dversion="5.2.5.FinalBwPatched" \
      -Dpackaging=java-source \
      -DgeneratePom=false \
      -Dfile="/Users/mike/bedework/quickstart-dev/bedework/tmp/.m2/repository/org/bedework/hibernate-core/5.2.5.FinalBwPatched/hibernate-core-5.2.5.FinalBwPatched-sources.jar" \
      -DrepositoryId="ossrh" \
      -Durl="https://oss.sonatype.org/service/local/staging/deploy/maven2/"


mvn deploy:deploy-file \
      -Pbedework-dev \
      -DgroupId="org.bedework" \
      -DartifactId="hibernate-core" \
      -Dversion="5.2.5.FinalBwPatched" \
      -DgeneratePom=false \
      -Dfile="hibernate-core-5.2.5.FinalBwPatched-sources.jar.asc" \
      -DrepositoryId="ossrh" \
      -Durl="https://oss.sonatype.org/service/local/staging/deploy/maven2/"


