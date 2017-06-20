import React from 'react';

import { CheckBox, Connect } from './ui';
import { Field, Form } from '../form';

import { EXPERIMENTAL_FEATURES, UPDATER_ENABLED } from '../cluster-config';

const experimentalFeaturesForm = new Form(EXPERIMENTAL_FEATURES, [
  new Field(UPDATER_ENABLED, {
    default: false,
  }),
]);

export const ExperimentalFeatures = () => <div className="row form-group">
  <div className="col-xs-3">
    <label htmlFor={UPDATER_ENABLED}>Self-Hosted</label>
  </div>
  <div className="col-xs-9">
    <Connect field={UPDATER_ENABLED}>
      <CheckBox suffix={
        <label htmlFor={UPDATER_ENABLED}>
          Host etcd on cluster in a "self-hosted" manner (alpha)
        </label>
      } />
    </Connect>
    <p className="text-muted checkbox-helper-text">Only use with non-production clusters.</p>
    <experimentalFeaturesForm.Errors />
  </div>
</div>;
