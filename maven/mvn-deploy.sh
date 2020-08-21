#! /bin/sh
#
#   Licensed to the Apache Software Foundation (ASF) under one or more
#   contributor license agreements.  See the NOTICE file distributed with
#   this work for additional information regarding copyright ownership.
#   The ASF licenses this file to You under the Apache License, Version 2.0
#   (the "License"); you may not use this file except in compliance with
#   the License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Shell script to deploy POI artifacts in a maven repository.
#
#  Note, You should configure your settings.xml and add a server with id=apache-releases:
#
#    <server>
#      <id>apache-releases</id>
#      <username>apacheId</username>
#      <password>mySecurePassw0rd</password>
#    </server>
#
#   <profiles>
#      <profile>
#      <id>apache-releases</id>
#      <properties>
#        <gpg.passphrase><!-- Your GPG passphrase --></gpg.passphrase>
#      </properties>
#    </profile>
#  </profiles>
#
#  Usage:
#   1. ant clean
#   2. ant assemble
#   3. cd build/dist/maven
#   4. ../../../maven/mvn-deploy.sh

M2_REPOSITORY=https://artifacts-oss.talend.com/nexus/content/repositories/TalendOpenSourceRelease/

for artifactId in poi poi-scratchpad poi-ooxml poi-examples poi-ooxml-schemas poi-excelant
do
  if [ -n "$1" ]; then
    VERSION=$1
  else
    VERSION=4.1.2-20200821_modified_talend
  fi
  SENDS="-Dfile=$artifactId/$artifactId-$VERSION.jar"
  SENDS="$SENDS -DpomFile=$artifactId/$artifactId-$VERSION.pom"

  if [ -n "$MAVEN_SETTINGS" ]; then
    MAVEN_SETTINGS_ARG="-s ${MAVEN_SETTINGS}"
  fi
  mvn deploy:deploy-file -B ${MAVEN_SETTINGS_ARG} \
    -DrepositoryId=talend_nexus_deployment \
    -Durl=$M2_REPOSITORY \
    $SENDS
done
