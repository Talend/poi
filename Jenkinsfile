def GIT_URL = 'https://github.com/Talend/poi.git'
def DEFAULT_VERSION = 'patch/4.1.2'

pipeline {

    agent {
        kubernetes {
            label 'poi'
            yaml """
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: ant
                    image: alpine:3.9.4
                    tty: true
                    command:
                    - cat
                    volumeMounts:
                    - name: docker
                      mountPath: /var/run/docker.sock
                  volumes:
                  - name: docker
                    hostPath:
                      path: /var/run/docker.sock
            """
        }
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        disableConcurrentBuilds()
        timeout(time: 15, unit: 'MINUTES')
    }

    parameters {
        string(name: 'BRANCH', defaultValue: DEFAULT_VERSION, description: 'Branch to build')
    }

    stages {

        stage('Prepare build environment') {
            steps {
                container('ant') {
                    git url: GIT_URL, branch: params.BRANCH, credentialsId: 'github-credentials'
                    script {
                        sh """
                        apk add apache-ant=1.10.5-r0
                        apk add openjdk8
                        java -version
                        apk add --no-cache so:libnss3.so
                        apk --update add fontconfig ttf-dejavu
                        apk add maven
                        export PATH=${PATH}:/usr/share/java/apache-ant/bin
                        export ANT_HOME=/usr/share/java/apache-ant
                        """
                    }
                }
            }
        }

        stage("Build distribution packages") {
            steps {
                container('ant') {
                    script {
                        configFileProvider([configFile(fileId: 'maven-settings-nexus-zl', variable: 'MAVEN_SETTINGS')]) {
                            sh """
                            TIMESTAMP=\$(date '+%Y%m%d%H%M%S')
                            VERSION=4.1.2-\${TIMESTAMP}_modified_talend
                            echo VERSION=\${VERSION}
                            ant assemble -Dversion.id=\${VERSION}
                            cd build/dist/maven
                            ../../../maven/mvn-deploy.sh \${VERSION}
                            """
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            junit testResults: 'build/*-test-results/*.xml', allowEmptyResults: true
        }
    }
}
