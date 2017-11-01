#!/usr/bin/env groovy

/* Tips
1. Keep stages focused on producing one artifact or achieving one goal. This makes stages easier to parallelize or re-structure later.
1. Stages should simply invoke a make target or a self-contained script. Do not write testing logic in this Jenkinsfile.
3. CoreOS does not ship with `make`, so Docker builds still have to use small scripts.
*/

creds = [
  file(credentialsId: 'tectonic-license', variable: 'TF_VAR_tectonic_license_path'),
  file(credentialsId: 'tectonic-pull', variable: 'TF_VAR_tectonic_pull_secret_path'),
  file(credentialsId: 'GCP-APPLICATION', variable: 'GOOGLE_APPLICATION_CREDENTIALS'),
  [
    $class: 'AmazonWebServicesCredentialsBinding',
    credentialsId: 'tectonic-jenkins-installer'
  ],
  [
    $class: 'AzureCredentialsBinding',
    credentialsId: 'azure-tectonic-test-service-principal',
    subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID',
    clientIdVariable: 'ARM_CLIENT_ID',
    clientSecretVariable: 'ARM_CLIENT_SECRET',
    tenantIdVariable: 'ARM_TENANT_ID'
  ],
  [
    $class: 'StringBinding',
    credentialsId: 'github-coreosbot',
    variable: 'GITHUB_CREDENTIALS'
  ]
]

quay_creds = [
  usernamePassword(
    credentialsId: 'quay-robot',
    passwordVariable: 'QUAY_ROBOT_SECRET',
    usernameVariable: 'QUAY_ROBOT_USERNAME'
  )
]

default_builder_image = 'quay.io/coreos/tectonic-builder:v1.41'
tectonic_smoke_test_env_image = 'quay.io/coreos/tectonic-smoke-test-env:v5.7'

pipeline {
  agent none
  options {
    timeout(time:120, unit:'MINUTES')
    timestamps()
    buildDiscarder(logRotator(numToKeepStr:'100'))
  }
  parameters {
    string(
      name: 'builder_image',
      defaultValue: default_builder_image,
      description: 'tectonic-builder docker image to use for builds'
    )
    string(
      name: 'hyperkube_image',
      defaultValue: '',
      description: 'Hyperkube image. Please define the param like: {hyperkube="<HYPERKUBE_IMAGE>"}'
    )
    booleanParam(
      name: 'RUN_SMOKE_TESTS',
      defaultValue: true,
      description: ''
    )
    booleanParam(
      name: 'RUN_GUI_TESTS',
      defaultValue: true,
      description: ''
    )
    booleanParam(
      name: 'PLATFORM/AWS',
      defaultValue: true,
      description: ''
    )
    booleanParam(
      name: 'PLATFORM/AZURE',
      defaultValue: true,
      description: ''
    )
    booleanParam(
      name: 'PLATFORM/GCP',
      defaultValue: true,
      description: ''
    )
    booleanParam(
      name: 'PLATFORM/BARE_METAL',
      defaultValue: true,
      description: ''
    )
  }

  stages {
    stage('Build & Test') {
      environment {
        GO_PROJECT = '/go/src/github.com/coreos/tectonic-installer'
        MAKEFLAGS = '-j4'
      }
      steps {
        node('worker && ec2') {
          script {
            def err = null
            try {
              forcefullyCleanWorkspace()
              withDockerContainer(params.builder_image) {
                ansiColor('xterm') {
                  checkout scm
                  sh """#!/bin/bash -ex
                  mkdir -p \$(dirname $GO_PROJECT) && ln -sf $WORKSPACE $GO_PROJECT

                  cd $GO_PROJECT/
                  make structure-check
                  make bin/smoke

                  cd $GO_PROJECT/installer
                  make clean
                  make tools
                  make build

                  make dirtycheck
                  make lint
                  make test
                  rm -fr frontend/tests_output
                  """
                  stash name: 'installer-binary', includes: 'installer/bin/linux/installer'
                  stash name: 'node-modules', includes: 'installer/frontend/node_modules/**'
                  stash name: 'smoke-test-binary', includes: 'bin/smoke'
                }
              }
              withDockerContainer(tectonic_smoke_test_env_image) {
                sh"""#!/bin/bash -ex
                  cd tests/rspec
                  bundler exec rubocop --cache false spec lib
                """
              }
            } catch (error) {
              err = error
              throw error
            } finally {
              reportStatusToGithub((err == null) ? 'success' : 'failure', 'basic-tests')
              cleanWs notFailBuild: true
            }
          }
        }
      }
    }

    stage('GUI Tests') {
      when {
        expression {
          return params.RUN_GUI_TESTS
        }
      }
      environment {
        TECTONIC_INSTALLER_ROLE = 'tectonic-installer'
        GRAFITI_DELETER_ROLE = 'grafiti-deleter'
        TF_VAR_tectonic_container_images = "${params.hyperkube_image}"
      }
      steps {
        script {
          def err = null
          try {
            parallel (
              "IntegrationTest AWS Installer Gui": {
                node('worker && ec2') {
                  forcefullyCleanWorkspace()
                  withCredentials(creds) {
                    withDockerContainer(params.builder_image) {
                      ansiColor('xterm') {
                        checkout scm
                        unstash 'installer-binary'
                        unstash 'node-modules'
                        sh """#!/bin/bash -ex
                        cd installer
                        make launch-aws-installer-guitests
                        make gui-aws-tests-cleanup
                        """
                        cleanWs notFailBuild: true
                      }
                    }
                  }
                }
              },
              "IntegrationTest Baremetal Installer Gui": {
                node('worker && ec2') {
                  forcefullyCleanWorkspace()
                  withCredentials(creds) {
                    withDockerContainer(image: params.builder_image, args: '-u root') {
                      ansiColor('xterm') {
                        checkout scm
                        unstash 'installer-binary'
                        unstash 'node-modules'
                        script {
                          try {
                            sh """#!/bin/bash -ex
                            cd installer
                            make launch-baremetal-installer-guitests
                            """
                          }
                          catch (error) {
                            throw error
                          }
                          finally {
                            sh """#!/bin/bash -x
                            cd installer
                            make gui-baremetal-tests-cleanup
                            make clean
                            """
                            cleanWs notFailBuild: true
                          }
                        }
                      }
                    }
                  }
                }
              }
            )
          } catch (error) {
            err = error
            throw error
          } finally {
            node('worker && ec2') {
              checkout scm
              reportStatusToGithub((err == null) ? 'success' : 'failure', 'gui-tests')
            }
          }
        }
      }
    }

    stage("Smoke Tests") {
      when {
        expression {
          return params.RUN_SMOKE_TESTS
        }
      }
      environment {
        TECTONIC_INSTALLER_ROLE = 'tectonic-installer'
        GRAFITI_DELETER_ROLE = 'grafiti-deleter'
        TF_VAR_tectonic_container_images = "${params.hyperkube_image}"
        GOOGLE_PROJECT = "tectonic-installer"
      }
      steps {
        script {
          def builds = [:]
          def aws = [
            [file: 'basic_spec.rb', args: ''],
            [file: 'vpc_internal_spec.rb', args: '--device=/dev/net/tun --cap-add=NET_ADMIN -u root'],
            [file: 'network_canal_spec.rb', args: ''],
            [file: 'exp_spec.rb', args: ''],
            [file: 'ca_spec.rb', args: '']
          ]
          def azure = [
            [file: 'basic_spec.rb', args: ''],
            [file: 'private_external_spec.rb', args: '--device=/dev/net/tun --cap-add=NET_ADMIN -u root'],
            /*
            * Test temporarily disabled
            [file: 'spec/azure_dns_spec.rb', args: ''],
            */
            [file: 'external_spec.rb', args: ''],
            [file: 'example_spec.rb', args: ''],
            [file: 'self_hosted_etcd_spec.rb', args: ''],
            [file: 'external_self_hosted_etcd_spec.rb', args: '']
          ]

          if (params."PLATFORM/AWS") {
            aws.each { build ->
              filepath = 'spec/aws/' + build.file
              builds['aws/' + build.file] = runRSpecTest(filepath, build.args)
            }
          }

          if (params."PLATFORM/AZURE") {
            azure.each { build ->
              filepath = 'spec/azure/' + build.file
              builds['azure/' + build.file] = runRSpecTest(filepath, build.args)
            }
          }

          if (params."PLATFORM/GCP") {
            builds['gcp'] = runRSpecTest('spec/gcp/basic_spec.rb', '')
          }

          if (params."PLATFORM/BARE_METAL") {
            builds['bare_metal'] = {
              node('worker && bare-metal') {
                def err = null
                def specFile = 'spec/metal/basic_spec.rb'
                try {
                  ansiColor('xterm') {
                    checkout scm
                    unstash 'smoke-test-binary'
                    withCredentials(creds) {
                      sh """#!/bin/bash -ex
                      cd tests/rspec
                      export RBENV_ROOT=/usr/local/rbenv
                      export PATH="/usr/local/rbenv/bin:$PATH"
                      eval \"\$(rbenv init -)\"
                      rbenv install -s
                      gem install bundler
                      bundler install
                      bundler exec rspec $specFile
                      """
                    }
                  }
                } catch (error) {
                  err = error
                  throw error
                } finally {
                  reportStatusToGithub((err == null) ? 'success' : 'failure', specFile)
                  cleanWs notFailBuild: true
                }
              }
            }
          }
          parallel builds
        }
      }
    }

    stage('Build docker image')  {
      when {
        branch 'master'
      }
      steps {
        node('worker && ec2') {
          forcefullyCleanWorkspace()
          withCredentials(quay_creds) {
            ansiColor('xterm') {
              checkout scm
              sh """
                docker build -t quay.io/coreos/tectonic-installer:master -f images/tectonic-installer/Dockerfile .
                docker login -u="$QUAY_ROBOT_USERNAME" -p="$QUAY_ROBOT_SECRET" quay.io
                docker push quay.io/coreos/tectonic-installer:master
                docker logout quay.io
              """
              cleanWs notFailBuild: true
            }
          }
        }
      }
    }
  }
}

def forcefullyCleanWorkspace() {
  return withDockerContainer(
    image: tectonic_smoke_test_env_image,
    args: '-u root'
  ) {
    ansiColor('xterm') {
      sh """#!/bin/bash -ex
        if [ -d "\$WORKSPACE" ]
        then
          rm -rfv \$WORKSPACE/*
        fi
      """
    }
  }
}

def runRSpecTest(testFilePath, dockerArgs) {
  return {
    node('worker && ec2') {
      def err = null
      try {
        forcefullyCleanWorkspace()
        ansiColor('xterm') {
          withCredentials(creds) {
              withDockerContainer(
                image: tectonic_smoke_test_env_image,
                args: dockerArgs
              ) {
                checkout scm
                unstash 'smoke-test-binary'
                sh """#!/bin/bash -ex
                  cd tests/rspec
                  bundler exec rspec ${testFilePath}
                """
              }
          }
        }
      } catch (error) {
        err = error
        throw error
      } finally {
        reportStatusToGithub((err == null) ? 'success' : 'failure', testFilePath)
        cleanWs notFailBuild: true
      }

    }
  }
}


def reportStatusToGithub(status, context) {
  withCredentials(creds) {
    sh """#!/bin/bash -ex
      ./tests/jenkins-jobs/scripts/report-status-to-github.sh ${status} ${context}
    """
  }
}
