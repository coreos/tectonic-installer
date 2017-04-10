pipeline {
  agent {
    docker {
      image 'quay.io/coreos/tectonic-terraform:v0.0.2'
      label 'worker'
    }
  }

  options {
    timeout(time:35, unit:'MINUTES')
    buildDiscarder(logRotator(numToKeepStr:'20'))
  }

  stages {
    stage('Syntax Check') {
      steps {
        sh 'make structure-check'
      }
    }

    stage('Smoke Tests') {
      steps {
        parallel (
          "AWS": {
              withCredentials([file(credentialsId: 'tectonic-license', variable: 'TF_VAR_tectonic_pull_secret_path'),
                               file(credentialsId: 'tectonic-pull', variable: 'TF_VAR_tectonic_license_path')]) {
              sh '''
              # Set required configuration
              export PLATFORM=aws
              export CLUSTER="tf-${PLATFORM}-${BRANCH_NAME}-${BUILD_ID}"
              export TF_VAR_tectonic_cluster_name=${CLUSTER}

              # make core utils accessible to make
              export PATH=/bin:${PATH}

              # Use smoke test configuration for deployment
              ln -sf ${WORKSPACE}/test/aws.tfvars ${WORKSPACE}/platforms/aws/terraform.tfvars

              make plan
              make apply
              make destroy
              '''
            }
          }
        )
      }
    }
  }
}
