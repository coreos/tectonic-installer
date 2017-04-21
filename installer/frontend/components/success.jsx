import _ from 'lodash';
import React from 'react';
import { connect } from 'react-redux';
import { AWS_HOSTED_ZONE_ID, CLUSTER_SUBDOMAIN } from '../cluster-config';
import { TectonicGA } from '../tectonic-ga';

const handleAllDone = () => {
  TectonicGA.sendEvent('Installer Button', 'click', 'User clicks over to the console');
  fetch('/cluster/done', {method: 'POST', credentials: 'same-origin'})
  .catch(() => {}); // We don't really care if this completes - we're done here!
};

const stateToProps = ({cluster, clusterConfig}) => {
  let tectonicConsole = _.get(cluster, ['status', 'tectonicConsole', 'instance']);
  if (!tectonicConsole) {
    // TODO: (kans) add this to the terraform status response
    const hostedZoneID = clusterConfig[AWS_HOSTED_ZONE_ID];
    const domain = _.get(clusterConfig, ['extra', AWS_HOSTED_ZONE_ID, 'zoneToName', hostedZoneID]);
    tectonicConsole = clusterConfig[CLUSTER_SUBDOMAIN] + (clusterConfig[CLUSTER_SUBDOMAIN].endsWith('.') ? '' : '.') + domain;
  }
  return {tectonicConsole};
};

export const Success = connect(stateToProps)(
({navigatePrevious, tectonicConsole}) => <div>
  <div className="row">
    <div className="col-xs-12">
      <p>
        All set! Now you can access your Tectonic Console, configure kubectl, and deploy your first application to your cluster.
      </p>
    </div>
  </div>

  <div className="row">
    <div className="col-xs-12">
      <a href={`https://${tectonicConsole}`} target="_blank">
        <button className="btn btn-primary wiz-giant-button"
                style={{marginTop: 20}}
                onClick={handleAllDone}>Go to my Tectonic Console&nbsp;&nbsp;<i className="fa fa-external-link"></i></button>
      </a>
    </div>
  </div>
  <hr className="spacer" />

  <div className="row">
    <div className="col-xs-12">
      <h4>Install kubectl</h4>
      <p>
        You can interact with nodes and deploy your Kubernetes-aware applications with kubectl. See the <a href="https://kubernetes.io/docs/user-guide/prereqs/" target="_blank">upstream kubectl documentation</a> for more details.
      </p>
      <a href="https://kubernetes.io/docs/user-guide/prereqs/" target="_blank"><button className="btn btn-default" style={{marginTop: 20}}>Configure kubectl&nbsp;&nbsp;<i className="fa fa-external-link"></i></button></a>
    </div>
  </div>
  <hr className="spacer" />

  <div className="row">
    <div className="col-xs-12">
      <h4>Deploy Your First Application</h4>
      <p>
        Once you have kubectl set up, learn how to deploy your first app!
      </p>
      <a href="https://coreos.com/tectonic/docs/latest/usage/first-app.html" target="_blank"><button className="btn btn-default" style={{marginTop: 20}}>Deploy Application&nbsp;&nbsp;<i className="fa fa-external-link"></i></button></a>
    </div>
  </div>
  <hr className="spacer" />

  <button onClick={navigatePrevious} className="btn btn-link">Back</button> <button onClick={window.reset} className="btn btn-link pull-right">Start Over</button>
</div>);

Success.canNavigateForward = ({allDone}) => {
  return allDone;
};
