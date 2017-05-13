/* Tips
1. Keep stages focused on producing one artifact or achieving one goal. This makes stages easier to parallelize or re-structure later.
1. Stages should simply invoke a make target or a self-contained script. Do not write testing logic in this Jenkinsfile.
3. CoreOS does not ship with `make`, so Docker builds still have to use small scripts.
*/
pipeline {
  agent none

  options {
    timeout(time:35, unit:'MINUTES')
    buildDiscarder(logRotator(numToKeepStr:'20'))
  }

  stages {
    stage('TerraForm: Syntax Check') {
      agent {
        docker {
          image 'quay.io/coreos/kube-conformance:v1.6.2_coreos.0'
          label 'worker'
        }
      }
      steps {
        sh """#!/bin/bash -ex
        make structure-check
        """
      }
    }

    stage("Conformance") {
      agent {
        docker {
          image 'quay.io/coreos/kube-conformance:v1.6.2_coreos.0'
          label 'worker'
        }
      }

      environment {
        HOME = "/go/src/k8s.io/kubernetes"
        KUBE_OS_DISTRIBUTION = "coreos"
        KUBERNETES_CONFORMANCE_TEST = "Y"
        KUBECONFIG = "${WORKSPACE}/build/tf-aws-${BRANCH_NAME}-${BUILD_ID}/generated/auth/kubeconfig"
      }

      steps {
        sh '''
          go run ${GOPATH}/src/k8s.io/kubernetes/hack/e2e.go -- -v --test --check-version-skew=false --test_args=\"ginkgo.focus='\\[Conformance\\]'\"
        '''
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
        // Destroy all clusters within workspace
        unstash 'installer'
        sh '''
          for c in ${WORKSPACE}/build/*; do
            export CLUSTER=$(basename ${c})
            export TF_VAR_tectonic_cluster_name=$(echo ${CLUSTER} | awk '{print tolower($0)}')

            echo "Destroying ${CLUSTER}..."
            make destroy || true
          done
        '''
      }
      // Cleanup workspace
      deleteDir()
    }
  }
}
