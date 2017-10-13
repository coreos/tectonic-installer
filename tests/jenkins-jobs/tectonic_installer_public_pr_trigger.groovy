#!/bin/env groovy​

folder("triggers")

job("triggers/tectonic-installer-pr-trigger") {
  description('Tectonic Installer PR Trigger. Changes here will be reverted automatically.')

  concurrentBuild()

  logRotator(30, 100)
  label("worker && ec2")

  properties {
    githubProjectUrl('https://github.com/coreos/tectonic-installer')
  }

  wrappers {
    colorizeOutput()
    timestamps()
    buildInDocker {
      image('quay.io/coreos/tectonic-smoke-test-env:v5.6')
    }
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
      whiteListLabels("")
      includedRegions("")
      excludedRegions("")
    }
  }

  steps {
    shell """#!/bin/bash -ex
      curl "https://api.github.com/repos/coreos/tectonic-installer/labels" > repoLabels
      repoLabels=\$(jq ".[] | .name" repoLabels)
      repoLabels=\$(echo \$repoLabels | tr -d "\\"" | tr [a-z] [A-Z] | tr - _)
      for label in \$repoLabels
      do
        echo \$label=false >> env_vars
      done


      curl "https://api.github.com/repos/coreos/tectonic-installer/issues/\${ghprbPullId}" > pr
      labels=\$(jq ".labels | .[] | .name" pr)
      labels=\$(echo \$labels | tr -d "\\"" | tr [a-z] [A-Z] | tr - _)
      for label in \$labels
      do
        echo \$label=true >> env_vars
      done
    """

    downstreamParameterized {
      trigger('tectonic-installer/PR-\${ghprbPullId}') {
        parameters {
          propertiesFile("env_vars", true)
        }
      }
    }
    shell "sleep 5"
  }

  publishers {
    wsCleanup()
    slackNotifier {
      authTokenCredentialId('tectonic-slack-token')
      customMessage("Tectonic Installer PR Trigger")
      includeCustomMessage(true)
      notifyBackToNormal(true)
      notifyFailure(true)
      notifyRepeatedFailure(true)
      room('#tectonic-installer-ci')
      teamDomain('coreos')
    }
    publishers {
        groovyPostBuild("""
import jenkins.model.Jenkins
import hudson.model.ParametersAction
import hudson.model.BooleanParameterValue
import hudson.model.Result
import hudson.model.Run
import org.jenkinsci.plugins.workflow.job.WorkflowRun
import org.jenkinsci.plugins.workflow.support.steps.StageStepExecution
import org.jenkinsci.plugins.workflow.job.WorkflowJob

//Get the PR Number
def thr = Thread.currentThread()
def build = thr?.executable
def resolver = build.buildVariableResolver
def PRNum = resolver.resolve("ghprbPullId")

// Get the channel to later connect to the salve to get the file
if(manager.build.workspace.isRemote()){
  channel = manager.build.workspace.channel
}

// Connect to the salve to copy the file
manager.listener.logger.println("Copying the file from the remote slave...");
String fp = manager.build.workspace.getRemote().toString() + "/env_vars";
remoteFile = new hudson.FilePath(channel, fp);

projectWorkspaceOnMaster = new hudson.FilePath(new File(manager.build.getProject().getRootDir(), "workspace"));
projectWorkspaceOnMaster.mkdirs();
File localFile = File.createTempFile("jenkins","parameter");
remoteFile.copyTo(new hudson.FilePath(localFile));
String vars = localFile.getText('UTF-8');
manager.listener.logger.println("Done copying");

// sleep a bit to wait jenkins refresh the jobs
sleep(3000);

def params = [ ];

// Get the PR Job
def job = Jenkins.instance.getItemByFullName("tectonic-installer/PR-" + PRNum)

// If job is in the queue wait for that
manager.listener.logger.println(job.isInQueue());
while(job.isInQueue()) {
  manager.listener.logger.println("Job in the queue, waiting....");
  sleep(1000);
}

for (prBuild in job.builds) {
  if (prBuild.getNumber().toInteger() == 1 && prBuild.isBuilding()) {
    manager.listener.logger.println("Build 1 is running, will try to kill...");
    WorkflowRun run = (WorkflowRun) prBuild;
    //hard kill
    run.doKill();

    while(prBuild.isBuilding()) {
        manager.listener.logger.println("Trying to kill the job....");
        run.doKill();
        sleep(1000);
     }

    manager.listener.logger.println("Job Killed");
    //release pipeline concurrency locks
    StageStepExecution.exit(run);

    sleep(1000);
    // Load the File and set the job trigger
    Properties properties = new Properties();
    localFile.withInputStream {
        properties.load(it);
    }
    properties.each { prop, val ->
      temp = new BooleanParameterValue(prop,val.toBoolean());
      params.add(temp);
    }
    sleep(5000);
    manager.listener.logger.println("Will trigger new build...");
    job.scheduleBuild2(5, null, new ParametersAction(params));
    manager.listener.logger.println("New job triggered");
    break;
  }
}
manager.listener.logger.println("Done");
"""
    ,Behavior.MarkFailed)
    }
  }
}
