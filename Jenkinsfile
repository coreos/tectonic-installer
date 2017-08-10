#!/usr/bin/env groovy

/* Tips
1. Keep stages focused on producing one artifact or achieving one goal. This makes stages easier to parallelize or re-structure later.
1. Stages should simply invoke a make target or a self-contained script. Do not write testing logic in this Jenkinsfile.
3. CoreOS does not ship with `make`, so Docker builds still have to use small scripts.
*/

def creds = [
  file(credentialsId: 'tectonic-license', variable: 'TF_VAR_tectonic_license_path'),
  file(credentialsId: 'tectonic-pull', variable: 'TF_VAR_tectonic_pull_secret_path'),
  [
    $class: 'UsernamePasswordMultiBinding',
    credentialsId: 'azure-smoke-ssh-key',
    passwordVariable: 'AZURE_SMOKE_SSH_KEY',
    usernameVariable: 'AZURE_SMOKE_SSH_KEY_PUB'
  ],
  [
    $class: 'UsernamePasswordMultiBinding',
    credentialsId: 'tectonic-console-login',
    passwordVariable: 'TF_VAR_tectonic_admin_email',
    usernameVariable: 'TF_VAR_tectonic_admin_password_hash'
  ],
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
  ]
]

def quay_creds = [
  usernamePassword(
    credentialsId: 'quay-robot',
    passwordVariable: 'QUAY_ROBOT_SECRET',
    usernameVariable: 'QUAY_ROBOT_USERNAME'
  )
]

def default_builder_image = 'quay.io/coreos/tectonic-builder:v1.36'
def tectonic_smoke_test_env_image = 'quay.io/coreos/tectonic-smoke-test-env:v3.0'


pipeline {
  agent none
  options {
    timeout(time:70, unit:'MINUTES')
    timestamps()
    buildDiscarder(logRotator(numToKeepStr:'100'))
  }
  parameters {
    string(
      name: 'builder_image',
      defaultValue: default_builder_image,
      description: 'tectonic-builder docker image to use for builds'
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
              checkout changelog: true, poll: false, scm: [$class: 'GitSCM', branches: '${sha1}', doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'PreBuildMerge', options: [fastForwardMode: 'FF', mergeRemote: 'origin', mergeStrategy: 'MergeCommand.Strategy' , mergeTarget: 'master']], [$class: 'CleanCheckout']], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/cpanato/tectonic-installer.git']]]
                sh "git branch -vv"
            }
          }
          withDockerContainer(tectonic_smoke_test_env_image) {
            checkout scm
            sh"""#!/bin/bash -ex
              cd tests/rspec
              bundler exec rubocop --cache false tests/rspec
            """
          }
        }
      }
    }

    stage("Tests") {
      environment {
        TECTONIC_INSTALLER_ROLE = 'tectonic-installer'
        GRAFITI_DELETER_ROLE = 'grafiti-deleter'
      }
      steps {
        parallel (
          "SmokeTest AWS RSpec": {
            node('worker && ec2') {
              withCredentials(creds) {
                checkout changelog: true, poll: false, scm: [$class: 'GitSCM', branches: '${sha1}', doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'PreBuildMerge', options: [fastForwardMode: 'FF', mergeRemote: 'origin', mergeStrategy: 'MergeCommand.Strategy' , mergeTarget: 'master']], [$class: 'CleanCheckout']], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/cpanato/tectonic-installer.git']]]
                sh "git branch -vv"

              }
            }
          }
        )
      }
    }
  }
}
