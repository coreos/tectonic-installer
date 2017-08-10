#!/bin/env groovy​

folder("triggers")

job("triggers/upstream-terraform-trigger") {
  description('Tectonic Installer using Terraform Upstream. Changes here will be reverted automatically.')

  logRotator(10, 10)
  wrappers {
    colorizeOutput()
    timestamps()
  }

  triggers {
    cron('@daily')
  }

  parameters {
    stringParam('builder_image', 'quay.io/coreos/tectonic-builder:v1.36-upstream-terraform', 'tectonic-builder docker image with upstream Terraform')
  }

  steps {
    downstreamParameterized {
      trigger('tectonic-installer/master') {
        parameters {
          currentBuild()
        }
      }
    }
  }

  publishers {
    wsCleanup()
    slackNotifier {
      authTokenCredentialId('tectonic-slack-token')
      customMessage("Tectonic Installer Upstream Terraform Build")
      includeCustomMessage(true)
      notifyBackToNormal(true)
      notifyFailure(true)
      room('#tectonic-installer-ci')
      teamDomain('coreos')
    }
  }
}
