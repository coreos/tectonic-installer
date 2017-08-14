#!/bin/env groovy​

folder("grafiti")

job("triggers/grafiti-pr-trigger") {
  description('Grafiti PR Trigger.\nChanges here will be reverted automatically.')

  concurrentBuild()

  logRotator(30, 100)
  label("master")

  properties {
    githubProjectUrl('https://github.com/coreos/grafiti/')
  }

  wrappers {
    colorizeOutput()
    timestamps()
  }

  triggers {
    ghprbTrigger {
      gitHubAuthId("")
      adminlist("")
      orgslist("coreos\ncoreos-inc")
      whitelist("")
      cron("H/5 * * * *")
      triggerPhrase("ok to test")
      onlyTriggerPhrase(false)
      useGitHubHooks(true)
      permitAll(false)
      autoCloseFailedPullRequests(false)
      displayBuildErrorsOnDownstreamBuilds(false)
      commentFilePath("")
      skipBuildPhrase(".*\\[skip\\W+ci\\].*")
      blackListCommitAuthor("")
      allowMembersOfWhitelistedOrgsAsAdmin(true)
      msgSuccess("")
      msgFailure("")
      commitStatusContext("Jenkins-Tectonic-Installer")
      buildDescTemplate("#\$pullId: \$abbrTitle")
      blackListLabels("")
      whiteListLabels("run-smoke-tests")
      includedRegions("")
      excludedRegions("")
    }
  }

  steps {
    downstreamParameterized {
      trigger('grafiti/PR-\${ghprbPullId}')
    }
  }

  publishers {
    wsCleanup()
    slackNotifier {
      authTokenCredentialId('tectonic-slack-token')
      customMessage("Grafiti PR Trigger")
      includeCustomMessage(true)
      notifyBackToNormal(true)
      notifyFailure(true)
      room('#tectonic-installer-ci')
      teamDomain('coreos')
    }
  }
}
