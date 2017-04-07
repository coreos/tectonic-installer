pipeline {
  agent {
    docker {
      image 'quay.io/coreos/tectonic-terraform'
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
  }
}
