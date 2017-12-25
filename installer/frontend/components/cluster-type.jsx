import _ from 'lodash';
import React from 'react';
import { connect } from 'react-redux';

import { validate } from '../validate';
import { Connect, Select } from './ui';
import { Field, Form } from '../form';
import { PLATFORM_TYPE, PLATFORM_FORM } from '../cluster-config';
import { TectonicGA } from '../tectonic-ga';
import {
  AWS_TF,
  BARE_METAL_TF,
  DOCS,
  PLATFORM_NAMES,
  isEnabled,
  isSupported,
  optGroups,
} from '../platforms';

const ErrorComponent = connect(({clusterConfig}) => ({platform: clusterConfig[PLATFORM_TYPE]}))(
  ({error, platform}) => {
    const platformName = PLATFORM_NAMES[platform];
    const icon = <i className="fa fa-external-link" />;
    if (error) {
      return <p>
        Use the documentation and the Terraform CLI to install a cluster with specific infrastructure use-cases.
        This method is designed for automation and doesn't use the graphical installer.
        <br />
        {/* eslint-disable react/jsx-no-target-blank */}
        <a href={DOCS[platform]} rel="noopener" target="_blank">
          <button className="btn btn-primary" style={{marginTop: 8}}>{platformName && platformName.split('(Alpha)')[0]} Docs&nbsp;&nbsp;{icon}</button>
        </a>
        {/* eslint-enable react/jsx-no-target-blank */}
      </p>;
    }
    /* eslint-disable react/jsx-no-target-blank */
    return <p className="text-muted">
      Use the graphical installer to input cluster details, this is best for demos and your first Tectonic cluster.
      &nbsp;&nbsp;{platform === BARE_METAL_TF
        ? <span><br />{platformName} <a href="https://coreos.com/tectonic/docs/latest/install/bare-metal/requirements.html" rel="noopener" target="_blank">requirements&nbsp;&nbsp;{icon}</a> and <a href={DOCS[platform]} rel="noopener" target="_blank">install guide&nbsp;&nbsp;{icon}</a>.</span>
        : <a href={DOCS[platform]} rel="noopener" target="_blank">{platformName} documentation&nbsp;&nbsp;{icon}</a>}
    </p>;
    /* eslint-enable react/jsx-no-target-blank */
  });

const platformForm = new Form(PLATFORM_FORM, [
  new Field(PLATFORM_TYPE, {
    default: _.find([AWS_TF, BARE_METAL_TF], isEnabled) || AWS_TF,
    validator: validate.nonEmpty,
  }),
], {
  validator: (data, cc) => {
    const platform = cc[PLATFORM_TYPE];
    if (!isSupported(platform)) {
      return `${PLATFORM_NAMES[platform]} not supported for GUI`;
    }
  },
});

const platformOptions = [];
_.each(optGroups, optgroup => {
  const [name, ...group] = optgroup;
  const platforms = _.filter(group, p => isEnabled(p));
  if (platforms.length) {
    platformOptions.push(<optgroup label={name} key={name}>{
      platforms.map(p => <option value={p} key={p}>{PLATFORM_NAMES[p]}</option>)
    }
    </optgroup>);
  }
});

export const ClusterType = () => <div>
  <div className="row form-group">
    <div className="col-xs-12">
      Select an installation path from the options below.
    </div>
  </div>

  <div className="row form-group">
    <div className="col-xs-3">
      <label htmlFor={PLATFORM_TYPE}>
        Platform
      </label>
    </div>
    <div className="col-xs-9">
      <Connect field={PLATFORM_TYPE}>
        <Select onValue={(value) => TectonicGA.sendEvent('Platform Changed', 'user input', value, value)}>
          {platformOptions}
        </Select>
      </Connect>
      <platformForm.Errors ErrorComponent={ErrorComponent} />
    </div>
  </div>
</div>;

ClusterType.canNavigateForward = platformForm.canNavigateForward;
