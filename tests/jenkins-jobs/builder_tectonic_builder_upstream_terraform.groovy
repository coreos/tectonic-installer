#!groovy

folder("builders")

job("builders/builder-tectonic-builder-upstream-terraform") {
  logRotator(-1, 10)
  description('Build a custom docker image of the tectonic builder using the upstream terraform. Changes here will be reverted automaticaly')

  label 'worker&&ec2'

  parameters {
    stringParam('TERRAFORM_UPSTREAM_URL', '', 'upstream terraform download url')
    stringParam('TECTONIC_BUILDER_VERSION', '', 'TECTONIC BUILDER Docker version')
    booleanParam('DRY_RUN', true, 'Just build the docker image')
  }

  wrappers {
    colorizeOutput()
    timestamps()
    credentialsBinding {
      usernamePassword("QUAY_USERNAME", "QUAY_PASSWD", "quay-robot")
    }
  }

  scm {
    git {
      remote {
        url('https://github.com/coreos/tectonic-installer')
      }
      branch('origin/master')
    }
  }


  steps {
    def cmd = """
    #!/bin/bash -e

    if [ -z "\${TERRAFORM_UPSTREAM_URL}" ]
    then
      export TECTONIC_BUILDER_NAME=quay.io/coreos/tectonic-builder:\${TECTONIC_BUILDER_VERSION}
      docker build -t \${TECTONIC_BUILDER_NAME} -f images/tectonic-builder/Dockerfile .
    else
      export TECTONIC_BUILDER_NAME=quay.io/coreos/tectonic-builder:\${TECTONIC_BUILDER_VERSION}-upstream-terraform
      docker build -t \${TECTONIC_BUILDER_NAME} --build-arg TERRAFORM_URL=\${TERRAFORM_UPSTREAM_URL} -f images/tectonic-builder/Dockerfile .
    fi

    if [ !\${DRY_RUN} = true  ] ; then
      docker login quay.io -u \${QUAY_USERNAME} -p \${QUAY_PASSWD}
      docker push \${TECTONIC_BUILDER_NAME}
    fi
  """.stripIndent()
    shell(cmd)
  }

  publishers {
    wsCleanup()
    slackNotifier {
      authTokenCredentialId('tectonic-slack-token')
      customMessage("Jenkins Builder: tectonic-builder")
      includeCustomMessage(true)
      notifyBackToNormal(true)
      notifyFailure(true)
      room('#tectonic-installer-ci')
      teamDomain('coreos')
    }
  }
}
