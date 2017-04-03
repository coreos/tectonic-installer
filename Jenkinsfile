job('tectonic-installer-syntax-check') {
    concurrentBuild()

    parameters {
        stringParam('sha1')
    }

    scm {
        git {
            remote {
                github('coreos/tectonic-installer')
                refspec('+refs/pull/*:refs/remotes/origin/pr/*')
            }
            branch('${sha1}')
        }
    }

    triggers {
        githubPullRequest {
            useGitHubHooks()
            orgWhitelist(['coreos-inc'])
            extensions {
                commitStatus {
                    context('tectonic-installer-syntax-check')
                    triggeredStatus('Tests triggered')
                    startedStatus('Tests started')
                    completedStatus('SUCCESS', 'Success')
                    completedStatus('FAILURE', 'Failure')
                    completedStatus('PENDING', 'Pending')
                    completedStatus('ERROR', 'Error')
                }
            }
        }
    }

    steps {
        shell('make structure-check')
    }
}
