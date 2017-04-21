import _ from 'lodash';
import React from 'react';
import { connect } from 'react-redux';

import { dispatch as dispatch_ } from './store';
import { configActions, registerForm } from './actions';
import { toError, toIgnore, toAsyncError, toExtraData, toInFly, toExtraDataInFly, toExtraDataError } from './utils';
import { ErrorComponent } from './components/ui';
import { TectonicGA } from './tectonic-ga';

const { setIn, batchSetIn, append, removeAt } = configActions;
const nop = () => undefined;

// TODO: (kans) make a sideffectful field instead of putting all side effects in async validate

class Node {
  constructor (id, opts) {
    if (!id) {
      throw new Error("I need a id");
    }
    this.id = id;
    this.name = opts.name || id;
    this.validator = opts.validator || nop;
    this.dependencies = opts.dependencies || [];
    this.ignoreWhen_ = opts.ignoreWhen;
    this.asyncValidator_ = opts.asyncValidator;
    this.getExtraStuff_ = opts.getExtraStuff;
    this.clock_ = 0;
  }

  getExtraStuff (dispatch, clusterConfig, FIELDS, isNow) {
    if (!this.getExtraStuff_) {
      return Promise.resolve();
    }
    const path = toExtraDataInFly(this.id);

    const unsatisfiedDeps = this.dependencies
      .map(d => FIELDS[d])
      .filter(d => !d.isValid(clusterConfig));

    if (unsatisfiedDeps.length) {
      return setIn(toExtraData(this.id), undefined, dispatch);
    }

    setIn(path, true, dispatch);
    return this.getExtraStuff_(dispatch, isNow).then(data => {
      if (!isNow()) {
        return;
      }
      batchSetIn(dispatch, [
        [path, undefined],
        [toExtraData(this.id), data],
        [toExtraDataError(this.id), undefined],
      ]);
    }, e => {
      if (!isNow()) {
        return;
      }
      batchSetIn(dispatch, [
        [path, undefined],
        [toExtraData(this.id), undefined],
        [toExtraDataError(this.id), e.message || e.toString()],
      ]);
    });
  }

  async validate (dispatch, getState, oldCC, isNow) {
    const id = this.id;
    const clusterConfig = getState().clusterConfig;
    const value = this.getData(clusterConfig);
    const extraData = _.get(clusterConfig, toExtraData(id));

    const syncErrorPath = toError(id);
    const inFlyPath = toInFly(id);

    const oldValue = this.getData(oldCC);

    const batches = [];

    if (_.get(clusterConfig, inFlyPath)) {
      batches.push([inFlyPath, false]);
    }

    const syncError = this.validator(value, clusterConfig, oldValue, extraData);
    if (syncError) {
      console.info("sync error", this.name, syncError);
      batches.push([syncErrorPath, syncError]);
      batchSetIn(dispatch, batches);
      return false;
    }

    const oldError = _.get(oldCC, syncErrorPath);
    if (oldError) {
      batches.push([syncErrorPath, undefined]);
      batchSetIn(dispatch, batches);
    }

    if (!this.isValid(getState().clusterConfig, true)) {
      batchSetIn(dispatch, batches);
      return false;
    }

    if (!this.asyncValidator_) {
      batchSetIn(dispatch, batches);
      return true;
    }

    batches.push([inFlyPath, true]);
    batchSetIn(dispatch, batches);

    let asyncError;

    try {
      asyncError = await this.asyncValidator_(dispatch, getState, value, oldValue, isNow, extraData);
    } catch (e) {
      asyncError = e.message || e.toString();
    }
    if (!isNow()) {
      console.log(`${this.name} is stale`);
      return false;
    }

    batches.push([inFlyPath, false]);

    const asyncErrorPath = toAsyncError(id);

    if (asyncError) {
      if (!_.isString(asyncError)) {
        console.warn(`asyncError is not a string!?:\n${JSON.stringify(asyncError)}`);
        if (asyncError.type && asyncError.payload) {
          console.warn(`Did you accidentally return a dispatch?`);
          asyncError = null;
        } else {
          asyncError = asyncError.toString ? asyncError.toString() : JSON.stringify(asyncError);
        }
      }
      batches.push([asyncErrorPath, asyncError]);
      batchSetIn(dispatch, batches);
      return false;
    }

    const oldAsyncError = _.get(getState().clusterConfig, asyncErrorPath);
    if (oldAsyncError) {
      batches.push([asyncErrorPath, undefined]);
    }

    batchSetIn(dispatch, batches);
    return true;
  }

  ignoreWhen (dispatch, clusterConfig) {
    if (!this.ignoreWhen_) {
      return false;
    }
    const value = !!this.ignoreWhen_(clusterConfig);
    console.debug('ignoring', this.id, value);
    setIn(toIgnore(this.id), value, dispatch);
    return value;
  }

  isIgnored (clusterConfig) {
    return _.get(clusterConfig, toIgnore(this.id));
  }
}

export class Field extends Node {
  constructor(id, opts={}) {
    super(id, opts);
    if (!_.has(opts, 'default')) {
      throw new Error(`${id} needs a default`);
    }
    this.default = opts.default;
  }

  getExtraData (clusterConfig) {
    return _.get(clusterConfig, toExtraData(this.id));
  }

  getData (clusterConfig) {
    return clusterConfig[this.id];
  }

  async update (dispatch, value, getState, deps, FIELDS, split) {
    const oldCC = getState().clusterConfig;

    ++ this.clock_;
    const now = this.clock_;
    const isNow = () => now === this.clock_;

    let id = this.id;
    if (split && split.length) {
      id = `${id}.${split.join('.')}`;
    }
    // TODO: (kans) - We need to lock the entire validation chain, not just validate proper
    setIn(id, value, dispatch);

    console.info("validating", this.name);
    const isValid = await this.validate(dispatch, getState, oldCC, isNow);

    if (!isValid) {
      const dirty = getState().dirty;
      if (dirty[this.name]) {
        TectonicGA.sendEvent('Validation Error', 'user input', this.name);
      }

      console.debug(`${this.name} is invalid`);
      return;
    }

    for (let dep of deps) {
      const { clusterConfig } = getState();
      dep.ignoreWhen(dispatch, clusterConfig);
      await dep.getExtraStuff(dispatch, clusterConfig, FIELDS, isNow);
      await dep.validate(dispatch, getState, oldCC, isNow);
    }

    console.info("finish validating", this.name);
  }

  validationData_ (clusterConfig, syncOnly) {
    const id = this.id;
    const value = _.get(clusterConfig, id);
    const ignore = _.get(clusterConfig, toIgnore(id));
    let error = _.get(clusterConfig, toError(id));
    if (!error && !syncOnly) {
      error = _.get(clusterConfig, toAsyncError(id));
    }

    return {value, ignore, error};
  }

  isValid_ ({ignore, error, value}) {
    return ignore || value !== '' && value !== undefined && _.isEmpty(error);
  }

  isValid (clusterConfig, syncOnly) {
    return this.isValid_(this.validationData_(clusterConfig, syncOnly));
  }

  inFly (clusterConfig) {
    return _.get(clusterConfig, toInFly(this.id)) || _.get(clusterConfig, toExtraDataInFly(this.id));
  }
}

export class Form extends Node {
  constructor(id, fields, opts={}) {
    super(id, opts);
    this.isForm = true;
    this.fields = fields;
    this.fieldIDs = fields.map(f => f.id);

    this.dependencies = [...this.fieldIDs].concat(this.dependencies);

    this.errorComponent = connect(
      ({clusterConfig}) => ({
        error: _.get(clusterConfig, toError(id)) || _.get(clusterConfig, toAsyncError(id)),
      })
    )(ErrorComponent);
    registerForm(this, fields);
  }

  isValid (clusterConfig, syncOnly) {
    const ignore = _.get(clusterConfig, toIgnore(this.id));
    if (ignore) {
      return true;
    }

    let error = _.get(clusterConfig, toError(this.id));
    if (!syncOnly && !error) {
      error = _.get(clusterConfig, toAsyncError(this.id));
    }

    if (error) {
      return false;
    }

    const invalidFields = this.fields.filter(field => !field.isValid(clusterConfig));
    return invalidFields.length === 0;
  }

  getExtraData (clusterConfig) {
    return this.fields.filter(f => !f.isIgnored(clusterConfig)).reduce((acc, f) => {
      acc[f.name] = f.getExtraData(clusterConfig);
      return acc;
    }, {});
  }

  getData (clusterConfig) {
    return this.fields.filter(f => !f.isIgnored(clusterConfig)).reduce((acc, f) => {
      acc[f.name] = f.getData(clusterConfig);
      return acc;
    }, {});
  }

  inFly (clusterConfig) {
    return _.get(clusterConfig, toInFly(this.id)) || _.some(this.fields, f => f.inFly(clusterConfig));
  }

  get canNavigateForward () {
    return ({clusterConfig}) => !this.inFly(clusterConfig) && this.isValid(clusterConfig);
  }

  get Errors () {
    return this.errorComponent;
  }
}

const toValidator = (fields, listValidator) => (value, clusterConfig, oldValue, extraData) => {
  const errs = listValidator ? listValidator(value, clusterConfig, oldValue, extraData) : [];
  if (errs && !_.isArray(errs)) {
    throw new Error(`FieldLists validator must return an Array, not:\n${errs}`);
  }
  _.each(value, (child, i) => {
    errs[i] = errs[i] || {};
    _.each(child, (childValue, name) => {
      // TODO: check that the name is in the field...
      const validator = _.get(fields, [name, 'validator']);
      if (!validator) {
        return;
      }
      const err = validator(childValue, clusterConfig, _.get(oldValue, [i, name]), _.get(extraData, [i, name]));
      if (!err) {
        return;
      }
      errs[i][name] = err;
    });
  });

  return _.every(errs, err => _.isEmpty(err)) ? [] : errs;
};

const toDefaultOpts = opts => {
  const default_ = {};

  _.each(opts.fields, (v, k) => {
    default_[k] = v.default;
  });

  return Object.assign({}, opts, {default: [default_], validator: toValidator(opts.fields, opts.validator)});
};

export class FieldList extends Field {
  constructor(id, opts={}) {
    super(id, toDefaultOpts(opts));
    this.fields = opts.fields;
  }

  get Map () {
    const id = this.id;
    const fields = this.fields;

    return function OuterListComponent (props) {

      function InnerFieldList ({value, removeField}) {
        const onlyChild = React.Children.only(props.children);
        const children = _.map(value, (unused, i) => {
          const row = {};
          _.keys(fields).forEach(k => row[k] = `${id}.${i}.${k}`);
          const childProps = { row, i, key: i, remove: () => removeField(i) };
          return React.cloneElement(onlyChild, childProps);
        });
        return React.createElement('div', {}, children);
      }

      const ConnectedFieldList = connect(
        ({clusterConfig}) => ({value: clusterConfig[id]}),
        (dispatch) => ({removeField: i => dispatch(configActions.removeField(id, i))})
      )(InnerFieldList);

      return React.createElement(ConnectedFieldList);
    };
  }

  get addOnClick () {
    return () => dispatch_(configActions.appendField(this.id));
  }

  append (dispatch, getState) {
    const child = {};
    _.each(this.fields, (f, name) => {
      child[name] = _.cloneDeep(f.default);
    });
    append(this.id, child, dispatch);
    this.validate(dispatch, getState, getState().clusterConfig, () => true);
  }

  remove (dispatch, i, getState) {
    removeAt(this.id, i, dispatch);
    this.validate(dispatch, getState, getState().clusterConfig, () => true);
  }
}
