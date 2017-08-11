#!/bin/env groovy​

folder("releases")

pipelineJob('releases/tectonic-release') {
  description("This Job execute the release process for tectonic-installer.\nThis job is manage by tectonic-installer.\nChanges here will be reverted automatically.")
  logRotator(-1, 100)
  parameters {
      stringParam('releaseTag', '', 'The release tag number.')
      stringParam('preRelease', '', 'A preRelease tag number.')
  }

  definition {
    cps {
      sandbox(true)
      script(readFileFromWorkspace("tests/jenkins-jobs/releases/pipelines/tectonic_release_pipeline.groovy"))
    }
  }
}