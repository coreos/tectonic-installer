/* eslint-env jest, node */

// monkey patch node's console :-/
console.debug = console.debug || console.info;

import _ from 'lodash';
import { __deleteEverything__, configActions, configActionTypes } from '../actions';
import { Field, Form } from '../form';
import { store } from '../store';
import { DEFAULT_CLUSTER_CONFIG } from '../cluster-config';
import { toError, toAsyncError, toIgnore, toInFly } from '../utils';
// TODO: (kans) test these things
// toExtraData, toExtraDataInFly, toExtraDataError

const invalid = 'is invalid';
const fieldName = 'aField';

const expectCC = (path, expected, f) => {
  const value = _.get(store.getState().clusterConfig, f ? f(path) : path);
  expect(value).toEqual(expected);
};

const resetCC = () => store.dispatch({
  type: configActionTypes.SET, payload: DEFAULT_CLUSTER_CONFIG,
});

const updateField = (field, value) => store.dispatch(configActions.updateField(field, value));


beforeEach(() => store.dispatch(__deleteEverything__()));

test('updates a Field', () => {
  expect.assertions(4);

  const name = 'aField';
  const aField = new Field(name, {
    default: 'a',
    validator: (value, cc) => {
      expect(value).toEqual('b');
      expect(cc[name]).toEqual('b');
    },
  });

  new Form('aForm', [aField]);
  resetCC();

  expectCC(name, 'a');
  updateField(name, 'b');
  expectCC(name, 'b');
});

test('field dependency validator is called', done => {
  expect.assertions(1);

  const aName = 'aField';

  const aField = new Field(aName, {default: 'a'});
  const bField = new Field('bField', {
    default: 'c',
    dependencies: [aName],
    validator: (value, cc) => {
      expect(cc[aName]).toEqual('b');
      done();
    },
  });

  new Form('aForm', [aField, bField]);

  resetCC();
  updateField(aName, 'b');
});

test('form validator is called', done => {
  expect.assertions(3);

  new Form('aForm', [new Field(fieldName, {default: 'a'})], {
    validator: (value, cc, oldValue) => {
      expectCC(fieldName, 'b');
      expect(value[fieldName]).toEqual('b');
      expect(oldValue[fieldName]).toEqual('a');
      done();
    },
  });

  resetCC();
  updateField(fieldName, 'b');
});

test('sync invalidation', () => {
  expect.assertions(3);

  const field = new Field(fieldName, {
    default: 'a',
    validator: value => value === 'b' && invalid,
  });

  new Form('aForm', [field]);

  resetCC();
  expectCC(fieldName, undefined, toError);

  updateField(fieldName, 'b');
  expectCC(fieldName, invalid, toError);

  updateField(fieldName, 'a');
  expectCC(fieldName, undefined, toError);
});

test('async invalidation', async done => {
  expect.assertions(5);

  const field = new Field(fieldName, {
    default: 'a',
    asyncValidator: (dispatch, getState, value, oldValue, isNow) => {
      expect(isNow()).toEqual(true);
      return value === 'b' && invalid;
    },
  });

  new Form('aForm', [field]);

  expectCC(fieldName, undefined, toAsyncError);

  await updateField(fieldName, 'b');
  expectCC(fieldName, invalid, toAsyncError);

  await updateField(fieldName, 'a');
  expectCC(fieldName, undefined, toAsyncError);

  done();
});

test('async (promise) invalidation', async done => {
  expect.assertions(3);

  const field = new Field(fieldName, {
    default: 'a',
    asyncValidator: (dispatch, getState, value) => new Promise((resolve, reject) =>
      value === 'b'
        ? process.nextTick(() => reject(invalid))
        : process.nextTick(resolve)
    ),
  });

  new Form('aForm', [field]);

  expectCC(fieldName, undefined, toAsyncError);
  await updateField(fieldName, 'b');

  expectCC(fieldName, invalid, toAsyncError);

  await updateField(fieldName, 'c');
  expectCC(fieldName, undefined, toAsyncError);

  done();
});

test('sync/async invalidation', async done => {
  expect.assertions(5);

  const field = new Field(fieldName, {
    default: 'a',
    validator: value => value === 'b' && invalid,
    asyncValidator: (dispatch, getState, value) => value === 'c' && invalid,
  });

  new Form('aForm', [field]);

  expectCC(fieldName, undefined, toError);

  await updateField(fieldName, 'b');
  expectCC(fieldName, invalid, toError);
  expectCC(fieldName, undefined, toAsyncError);

  await updateField(fieldName, 'c');
  expectCC(fieldName, invalid, toAsyncError);
  expectCC(fieldName, undefined, toError);

  done();
});

test('ignores', async done => {
  expect.assertions(6);

  const field1 = new Field(fieldName, { default: 'a'});

  const fieldName2 = 'bField';
  const field2 = new Field(fieldName2, {
    default: 'a',
    validator: () => invalid,
    dependencies: [fieldName],
    ignoreWhen: cc => cc[fieldName] === 'b',
  });

  const form = new Form('aForm', [field1, field2]);

  await updateField(fieldName2, 'b');
  expectCC(fieldName2, undefined, toIgnore);
  expect(form.isValid(store.getState().clusterConfig)).toEqual(false);
  await updateField(fieldName, 'b');

  expectCC(fieldName2, true, toIgnore);
  expectCC(fieldName2, invalid, toError);

  const cc = store.getState().clusterConfig;
  expect(field2.isValid(cc)).toEqual(true);
  expect(form.isValid(cc)).toEqual(true);

  done();
});

test('inFly', async done => {
  expect.assertions(3);

  const field = new Field(fieldName, {
    default: 'a',
    asyncValidator: () => new Promise(accept => {
      expectCC(fieldName, true, toInFly);
      accept();
      expectCC(fieldName, false, toInFly);
    }),
  });

  new Form('aForm', [field]);

  expectCC(fieldName, undefined, toInFly);
  await updateField(fieldName, 'b');
  done();
});
