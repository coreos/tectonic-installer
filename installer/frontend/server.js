import _ from 'lodash';

import { getTectonicDomain, toAWS, toAWS_TF, toBaremetal, toBaremetal_TF, DRY_RUN, PLATFORM_TYPE, RETRY } from './cluster-config';
import { clusterReadyActionTypes, configActions, loadFactsActionTypes, serverActionTypes, FORMS } from './actions';
import { savable } from './reducer';
import {
  AWS,
  AWS_TF,
  BARE_METAL,
  BARE_METAL_TF,
  isTerraform,
} from './platforms';

const { setIn } = configActions;

// Either return parsable JSON, or fail (and assume returned text is an error message)
const fetchJSON = (url, opts, ...args) => {
  opts = opts || {};
  opts.credentials = 'same-origin';
  return fetch(url, opts, ...args).then(response => {
    if (response.ok) {
      return response.json();
    }

    return response.text().then(Promise.reject);
  });
};

// Poll server for cluster status.
// Guaranteed not to reject
const {NOT_READY, STATUS, ERROR} = clusterReadyActionTypes;

export const observeClusterStatus = (dispatch, getState) => {
  const cc = getState().clusterConfig;
  const tectonicDomain = getTectonicDomain(cc);
  const platform = _.get(cc, PLATFORM_TYPE);

  const url = isTerraform(platform) ? '/terraform/status' : '/cluster/status';
  const opts = {
    credentials: 'same-origin',
    body: JSON.stringify({tectonicDomain}),
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  };

  return fetch(url, opts).then(response => {
    if (response.status === 404) {
      dispatch({type: NOT_READY});
      return;
    }
    if (response.ok) {
      return response.json().then(payload => dispatch({type: STATUS, payload}));
    }
    return response.text().then(payload => dispatch({type: ERROR, payload}));
  }, payload => {
    if (payload instanceof TypeError) {
      payload = `${payload.message}. Is the installer running?`;
    }
    return dispatch({type: ERROR, payload});
  })
  .catch(err => console.error(err) || err);
};

const platformToFunc = {
  [AWS]: {
    f: toAWS,
    path: '/cluster/create',
    statusPath: '/cluster/status',
  },
  [AWS_TF]: {
    f: toAWS_TF,
    path: '/terraform/apply',
    statusPath: '/terraform/status',
  },
  [BARE_METAL]: {
    f: toBaremetal,
    path: '/cluster/create',
    statusPath: '/cluster/status',
  },
  [BARE_METAL_TF]: {
    f: toBaremetal_TF,
    path: '/terraform/apply',
    statusPath: '/terraform/status',
  },
};

let observeInterval;

// An action creator that builds a server message, calls fetch on that message, fires the appropriate actions
export const commitToServer = (dryRun=false, retry=false) => (dispatch, getState) => {
  setIn(DRY_RUN, dryRun, dispatch);
  setIn(RETRY, retry, dispatch);

  const {COMMIT_REQUESTED, COMMIT_FAILED, COMMIT_SUCCESSFUL, COMMIT_SENT} = serverActionTypes;

  dispatch({type: COMMIT_REQUESTED});

  const state = getState();
  const request = Object.assign({}, state.clusterConfig, {progress: savable(state)});

  const obj = _.get(platformToFunc, request.platformType);
  if (!_.isFunction(obj.f)) {
    throw Error(`unknown platform type "${request.platformType}"`);
  }

  const body = obj.f(request, FORMS);
  fetch(obj.path, {
    credentials: 'same-origin',
    method: 'POST',
    body: JSON.stringify(body),
  })
  .then(
    response => response.ok ?
      response.blob().then(payload => {
        observeClusterStatus(dispatch, getState);
        if (!observeInterval) {
          observeInterval = setInterval(() => observeClusterStatus(dispatch, getState), 10000);
        }
        return dispatch({payload, type: COMMIT_SUCCESSFUL});
      }) :
      response.text().then(payload => dispatch({payload, type: COMMIT_FAILED}))
  , payload => dispatch({payload, type: COMMIT_FAILED}))
  .catch(err => console.error(err));

  return dispatch({
    type: COMMIT_SENT,
    payload: body,
  });
};

const AMI_URL = 'https://stable.release.core-os.net/amd64-usr/current/coreos_production_ami_all.json';

// One-time fetch of AMIs from server, followed by firing appropriate actions
// Guaranteed not to reject.
const getAMIs = (dispatch) => {
  return fetchJSON(`/proxy?target=${ encodeURIComponent(AMI_URL) }`)
    .then(m => {
      const awsRegions = m.amis.map(({name}) => {
        return {label: name, value: name};
      });
      dispatch({
        type: loadFactsActionTypes.LOADED,
        payload: {awsRegions},
      });
    },
    err => {
      dispatch({
        type: loadFactsActionTypes.ERROR,
        payload: err,
      });
    }).catch(err => console.error(err));
};

// One-time fetch of facts from server. Abstracts getAMIs.
// Guaranteed not to reject.
export const loadFacts = (dispatch) => {
  if (_.includes(window.config.platforms, 'aws')) {
    return getAMIs(dispatch);
  }
  dispatch({type: loadFactsActionTypes.LOADED, payload: {}});
  return Promise.resolve();
};
