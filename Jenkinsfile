pipeline {
  agent {
    label 'worker'
  }

  options {
    timeout(time:35, unit:'MINUTES')
    buildDiscarder(logRotator(numToKeepStr:'20'))
  }

  stages {
    stage('Syntax Check') {
      steps {
        sh 'docker run --rm -v$PWD:/terraform quay.io/coreos/tectonic-terraform "make structure-check"'
      }
    }
  }
}
