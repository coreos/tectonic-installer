#!/usr/bin/env groovy

/* Tips
1. Keep stages focused on producing one artifact or achieving one goal. This makes stages easier to parallelize or re-structure later.
1. Stages should simply invoke a make target or a self-contained script. Do not write testing logic in this Jenkinsfile.
3. CoreOS does not ship with `make`, so Docker builds still have to use small scripts.
*/

creds = [
  file(credentialsId: 'tectonic-license', variable: 'TF_VAR_tectonic_license_path'),
  file(credentialsId: 'tectonic-pull', variable: 'TF_VAR_tectonic_pull_secret_path'),
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
          withDockerContainer(params.builder_image) {
            ansiColor('xterm') {
              checkout scm
              sh """#!/bin/bash -ex
                echo 'run basic tests'
              """
              stash name: 'repository', useDefaultExcludes: false // include .git
              cleanWs notFailBuild: true
            }
          }
          withDockerContainer(tectonic_smoke_test_env_image) {
            unstash 'repository'
            sh"""#!/bin/bash -ex
              echo 'run rubocop'
            """
            cleanWs notFailBuild: true
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
      }
      steps {
        script {
          def builds = [:]

          if (params."PLATFORM/AWS") {
            builds['aws'] = runRSpecTest('spec/aws_spec.rb', '')
            builds['aws_vpc_internal'] = runRSpecTest(
                'spec/aws_vpc_internal_spec.rb',
                '--device=/dev/net/tun --cap-add=NET_ADMIN -u root'
                )
            builds['aws_network_policy'] = runRSpecTest('spec/aws_network_policy_spec.rb', '')
            builds['aws_exp'] = runRSpecTest('spec/aws_exp_spec.rb', '')
            builds['aws_ca'] = runRSpecTest('spec/aws_ca_spec.rb', '')
          }

          if (params."PLATFORM/AZURE") {
            builds['azure_basic'] = runRSpecTest('spec/azure_basic_spec.rb', '')
            builds['azure_experimental'] = runRSpecTest('spec/azure_experimental_spec.rb', '')
            builds['azure_private_external'] = runRSpecTest('spec/azure_private_external_spec.rb', '--device=/dev/net/tun --cap-add=NET_ADMIN -u root')
            /*
            * Test temporarily disabled
            builds['azure_dns'] = runRSpecTest('spec/azure_dns_spec.rb', '')
            */
            builds['azure_external'] = runRSpecTest('spec/azure_external_spec.rb', '')
            builds['azure_external_experimental'] = runRSpecTest('spec/azure_external_experimental_spec.rb', '')
            builds['azure_example'] = runRSpecTest('spec/azure_example_spec.rb', '')
          }

          if (params."PLATFORM/BARE_METAL") {
            /* Temporarily disabled for consolidation
            * Fails very often due to Packet flakiness
            *
            builds['bare_metal'] = {
              node('worker && bare-metal') {
                ansiColor('xterm') {
                  unstash 'repository'
                  withCredentials(creds) {
                    timeout(35) {
                      sh """#!/bin/bash -ex
                      ${WORKSPACE}/tests/smoke/bare-metal/smoke.sh vars/metal.tfvars
                      """
                    }
                    cleanWs notFailBuild: true
                  }
                }
              }
            }
            */
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
          withCredentials(quay_creds) {
            ansiColor('xterm') {
              unstash 'repository'
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


def runRSpecTest(testFilePath, dockerArgs) {
  return {
    node('worker && ec2') {
      ansiColor('xterm') {
        unstash 'repository'
        withCredentials(creds) {
          def err = null
          try {
            withDockerContainer(
                image: tectonic_smoke_test_env_image,
                args: dockerArgs
            ) {
              sh """#!/bin/bash -ex
                echo 'testing stuff'
              """
            }
            cleanWs notFailBuild: true
          } catch (error) {
            err = error
            throw error
          } finally {
            checkout scm
            setGitHubCommitStatus((err != null) ? 'success' : 'failure', '')
            cleanWs notFailBuild: true
          }
        }
      }
    }
  }
}

def setGitHubCommitStatus(status, name) {
    sh('echo 1234 && echo ${status}')
    sh("./tests/jenkins-jobs/scripts/report-status-to-github.sh ${status}")
}
