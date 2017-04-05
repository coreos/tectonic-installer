pipeline {
  agent none
  
  options {
    timeout(time:35, unit:'MINUTES')
    buildDiscarder(logRotator(numToKeepStr:'20'))
  }

  stages {
    stage('Syntax Check') {
      agent {
        label 'worker'
      }
      steps {
        sh 'docker run --rm -v$PWD:/terraform quay.io/coreos/tectonic-terraform "make structure-check"'
      }
    }
  }
}
