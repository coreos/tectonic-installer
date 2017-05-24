/* Tips
1. Keep stages focused on producing one artifact or achieving one goal. This makes stages easier to parallelize or re-structure later.
1. Stages should simply invoke a make target or a self-contained script. Do not write testing logic in this Jenkinsfile.
3. CoreOS does not ship with `make`, so Docker builds still have to use small scripts.
*/
pipeline {
  agent {
    docker {
      image 'quay.io/coreos/tectonic-builder:v1.8'
      label 'worker'
    }
  }

  options {
    timeout(time:35, unit:'MINUTES')
    buildDiscarder(logRotator(numToKeepStr:'20'))
  }

  stages {
    stage('TerraForm: Syntax Check') {
      steps {
        sh """#!/bin/bash -ex
        make structure-check
        """
      }
    }

    stage('Generate docs') {
      steps {
        sh """#!/bin/bash -ex

        # Prevent "fatal: You don't exist. Go away!" git error
        git config --global user.name "jenkins tectonic installer"
        git config --global user.email "jenkins-tectonic-installer@coreos.com"
        go get github.com/segmentio/terraform-docs

        make docs
        git diff --exit-code
        """
      }
    }

    stage('Generate examples') {
      steps {
        sh """#!/bin/bash -ex

        # Prevent "fatal: You don't exist. Go away!" git error
        git config --global user.name "jenkins tectonic installer"
        git config --global user.email "jenkins-tectonic-installer@coreos.com"
        go get github.com/s-urbaniak/terraform-examples

        make examples
        git diff --exit-code
        """
      }
    }

    stage('Installer: Build & Test') {
      environment {
        GO_PROJECT = '/go/src/github.com/coreos/tectonic-installer'
      }
      steps {
        checkout scm
        sh "mkdir -p \$(dirname $GO_PROJECT) && ln -sf $WORKSPACE $GO_PROJECT"
        sh "go get github.com/golang/lint/golint"
        sh """#!/bin/bash -ex
        go version
        cd $GO_PROJECT/installer

        make tools
        make build
        make test
        """
        stash name: 'installer', includes: 'installer/bin/linux/installer'
        stash name: 'sanity', includes: 'installer/bin/sanity'
        }
      }
      stage("Smoke Tests") {
      steps {
        parallel (
          "TerraForm: AWS": {
            withCredentials([file(credentialsId: 'tectonic-pull', variable: 'TF_VAR_tectonic_pull_secret_path'),
                             file(credentialsId: 'tectonic-license', variable: 'TF_VAR_tectonic_license_path'),
                             [
                               $class: 'UsernamePasswordMultiBinding',
                               credentialsId: 'tectonic-aws',
                               usernameVariable: 'AWS_ACCESS_KEY_ID',
                               passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                             ]
                             ]) {
            unstash 'installer'
            unstash 'sanity'
            sh '''#!/bin/bash -ex
            set -o pipefail
            shopt -s expand_aliases

            # Set required configuration
            export PLATFORM=aws
            export CLUSTER="tf-${PLATFORM}-${BRANCH_NAME}-${BUILD_ID}"

            # s3 buckets require lowercase names
            export TF_VAR_tectonic_cluster_name=$(echo ${CLUSTER} | awk '{print tolower($0)}')

            # randomly select region
            REGIONS=(us-east-1 us-east-2 us-west-1 us-west-2 ap-southeast-1)
            export CHANGE_ID=${CHANGE_ID:-${BUILD_ID}}
            i=$(( ${CHANGE_ID} % ${#REGIONS[@]} ))
            export TF_VAR_tectonic_aws_region="${REGIONS[$i]}"
            export AWS_REGION="${REGIONS[$i]}"
            echo "selected region: ${TF_VAR_tectonic_aws_region}"
            # make core utils accessible to make
            export PATH=/bin:${PATH}

            # Create local config
            make localconfig

            # Use smoke test configuration for deployment
            ln -sf ${WORKSPACE}/test/aws.tfvars ${WORKSPACE}/build/${CLUSTER}/terraform.tfvars

            alias filter=${WORKSPACE}/installer/scripts/filter.sh

            make plan | filter
            make apply | filter

            # TODO: replace in Go
            CONFIG=${WORKSPACE}/build/${CLUSTER}/terraform.tfvars
            MASTER_COUNT=$(grep tectonic_master_count ${CONFIG} | awk -F "=" '{gsub(/"/, "", $2); print $2}')
            WORKER_COUNT=$(grep tectonic_worker_count ${CONFIG} | awk -F "=" '{gsub(/"/, "", $2); print $2}')

            export NODE_COUNT=$(( ${MASTER_COUNT} + ${WORKER_COUNT} ))

            export TEST_KUBECONFIG=${WORKSPACE}/build/${CLUSTER}/generated/auth/kubeconfig
            installer/bin/sanity -test.v -test.parallel=1
            '''
            }
          }
        )
      }
    }
  }
  post {
    always {
      checkout scm

      withCredentials([file(credentialsId: 'tectonic-license', variable: 'TF_VAR_tectonic_pull_secret_path'),
                       file(credentialsId: 'tectonic-pull', variable: 'TF_VAR_tectonic_license_path'),
                       [
                         $class: 'UsernamePasswordMultiBinding',
                         credentialsId: 'tectonic-aws',
                         usernameVariable: 'AWS_ACCESS_KEY_ID',
                         passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                       ]
                       ]) {
        /* Destroy all clusters within workspace
         * Try 3 times before failing because tf destroy is flaky.
         * "||" is bash for "do the next thing only if the first thing failed"
         */
        unstash 'installer'
        sh '''#!/bin/bash -ex
          set -o pipefail
          shopt -s expand_aliases

          # Set required configuration
          export PLATFORM=aws
          export CLUSTER="tf-${PLATFORM}-${BRANCH_NAME}-${BUILD_ID}"

          # s3 buckets require lowercase names
          export TF_VAR_tectonic_cluster_name=$(echo ${CLUSTER} | awk '{print tolower($0)}')

          # randomly select region
          REGIONS=(us-east-1 us-east-2 us-west-1 us-west-2 ap-southeast-1)
          export CHANGE_ID=${CHANGE_ID:-${BUILD_ID}}
          i=$(( ${CHANGE_ID} % ${#REGIONS[@]} ))
          export TF_VAR_tectonic_aws_region="${REGIONS[$i]}"
          export AWS_REGION="${REGIONS[$i]}"
          echo "selected region: ${TF_VAR_tectonic_aws_region}"

          echo "Destroying ${CLUSTER}..."
          make destroy || make destroy || make destroy
        '''
      }
      // Cleanup workspace
      deleteDir()
    }
  }
}
