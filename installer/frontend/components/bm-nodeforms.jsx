import _ from 'lodash';
import Baby from 'babyparse';
import classNames from 'classnames';
import React from 'react';

import { connect } from 'react-redux';

import { configActions, dirtyActions } from '../actions';
import { Alert } from './alert';
import { MAX_MASTERS, MAX_WORKERS } from './nodes';
import { validate } from '../validate';
import { readFile } from '../readfile';
import { FieldList, Form } from '../form';
import { BM_MASTERS, BM_WORKERS } from '../cluster-config';
import { Input, Connect, FieldRowList } from './ui';

const BulkUpload = connect(null, dispatch => ({
  updateNodes: (fieldID, payload) => {
    dispatch(configActions.updateField(fieldID, payload));
    _.each(payload, (row, i) => {
      _.each(row, (ignore, key) => {
        dispatch(dirtyActions.add(`${fieldID}.${i}.${key}`));
      });
    });
    dispatch(configActions.updateField(fieldID, payload));
  },
}))(
  class BulkUpload extends React.Component {
    constructor (props) {
      super(props);
      this.state = {
        name: null,
        macCol: 0,
        nameCol: 1,
        csv: null,
      };
    }

    handleUpload (e) {
      const blob = e.target.files.item(0);
      readFile(blob)
        .then(result => {
          const csv = Baby.parse(result, {delimiter: ','});
          this.setState({
            name: blob.name,
            macCol: 0,
            nameCol: 1,
            csv,
          });
        })
        .catch((msg) => {
          console.error(msg);
        });
    }

    handleSelectMACColumn (e) {
      this.setState({
        macCol: parseInt(e.target.value, 10),
      });
    }

    handleSelectNameColumn (e) {
      this.setState({
        nameCol: parseInt(e.target.value, 10),
      });
    }

    cancel () {
      this.props.close();
    }

    handleDone () {
      const {nameCol, macCol, csv} = this.state;
      const rows = csv.data.slice(1).filter(row => {
        // BabyParse will append a single [""] row to a well-formed CSV,
        // the following happens to fix that, and forgive other
        // possible CSV weirdnesses.
        return row.length > Math.max(nameCol, macCol);
      });
      const nodes = rows.map(row => ({
        host: row[nameCol],
        mac: row[macCol],
      }));

      this.props.updateNodes(this.props.fieldID, nodes);
      this.props.close();
    }

    render () {
      const { csv, name, nameCol, macCol } = this.state;

      let body;
      if (!csv) {
        body = <div>
          <div>
            Select a CSV file to populate the node addresses
          </div>
          <div className="wiz-minimodal__body">
            <input type="file" onChange={e => this.handleUpload(e)} />
            <div className="wiz-upload-csv-settings">
              <p>After uploading, you can select which columns correspond to the required data.</p>
            </div>
          </div>
        </div>;
      } else if (csv.errors.length) {
        body = <Alert severity="error">
          Error parsing CSV:
          <ul>
            {csv.errors.map((e, i) => <li key={i}>{e.message} on line {e.row}.</li>)}
          </ul>
        </Alert>;
      } else {
        const options = csv.data[0].map((txt, ix) => {
          return <option value={ix} key={`${ix}:${txt}`}>{txt}</option>;
        });

        body = <div>
          <div className="row">
            <div className="col-xs-3">
              <label>CSV File</label>
            </div>
            <div className="col-xs-6">
              {name}
            </div>
            <div className="col-xs-3">
              <a onClick={() => this.cancel()}>change file</a>
            </div>
          </div>
          <div className="wiz-minimodal__body">
            <div className="wiz-upload-csv-settings">
              <div>Choose the CSV Column that matches each input</div>
              <div className="row wiz-minimodal__controlblock">
                <div className="col-xs-3">
                  <label htmlFor="mac-column">Mac Address</label>
                </div>
                <div className="col-xs-6">
                  <select id="mac-column"
                    onChange={e => this.handleSelectMACColumn(e)}
                    defaultValue={macCol}>
                    {options}
                  </select>
                </div>
              </div>
              <div className="row wiz-minimodal__controlblock">
                <div className="col-xs-3">
                  <label htmlFor="name-column">Node Name</label>
                </div>
                <div className="col-xs-6">
                  <select id="name-column"
                    onChange={e => this.handleSelectNameColumn(e)}
                    defaultValue={nameCol}>
                    {options}
                  </select>
                </div>
              </div>
            </div>
          </div>
        </div>;
      }

      const doneClasses = classNames('btn btn-primary', {disabled: !csv});

      return (
        <div className="wiz-minimodal">
          {body}
          <div className="wiz-minimodal__actions">
            <button type="button" className={doneClasses} onClick={e => this.handleDone(e)}>Done</button>
            <button className="btn btn-link" onClick={() => this.cancel()}>Cancel</button>
          </div>
        </div>
      );
    }
  }
);

const rowFields = {
  mac: {
    default: '',
    validator: validate.MAC,
  },
  host: {
    default: '',
    validator: validate.host,
  },
};

const makeFieldList = (id, name, maxNodes) => new FieldList(id, rowFields, {
  validator: (nodes, cc) => {
    const macs = _.map(nodes, 'mac');
    const masters = id === BM_WORKERS ? cc[BM_MASTERS] : [];
    const errors = {};

    _.each(nodes, (node, i) => {
      const REQUIRED_MSG = 'Both fields are required';
      if (!node.mac) {
        _.set(errors, [i, 'mac'], REQUIRED_MSG);
      }
      if (!node.host) {
        _.set(errors, [i, 'host'], REQUIRED_MSG);
      }

      const validateUnique = (field, haystack, msg) => {
        const matchIndex = _.indexOf(_.map(haystack, field), node[field]);
        if (matchIndex !== -1) {
          _.set(errors, [i, field], msg);
        }
      };

      validateUnique('mac', masters, 'Cannot match a master MAC address');
      validateUnique('host', masters, 'Cannot match a master hostname');

      const otherNodes = nodes.filter(n => n !== node);
      validateUnique('mac', otherNodes, 'MACs must be unique');
      validateUnique('host', otherNodes, 'Hostnames must be unique');
    });

    if (macs.length === 0) {
      errors.global = `At least 1 ${name} is required.`;
    }

    if (macs.length > maxNodes) {
      errors.global = `No more than ${maxNodes} ${name}s are allowed.`;
    }
    return errors;
  },
});

const NodeRow = ({autoFocus, row}) => <div>
  <div className="col-xs-5" style={{paddingRight: 0}}>
    <Connect field={row.mac}>
      <Input autoFocus={autoFocus} placeholder="MAC address" />
    </Connect>
  </div>
  <div className="col-xs-6" style={{paddingRight: 0}}>
    <Connect field={row.host}>
      <Input placeholder="node.domain.com" />
    </Connect>
  </div>
</div>;

class NodeForm extends React.Component {
  render () {
    const {docs, id, name} = this.props;

    if (this.state && this.state.bulkUpload) {
      // TODO (ggreer) make a real modal with real modal classes
      return <BulkUpload close={() => this.setState({bulkUpload: false})} fieldID={id} />;
    }

    return <div>
      <div className="form-group">
        <a onClick={() => this.setState({bulkUpload: true})}>
          <span className="fa fa-upload"></span> Bulk Upload Addresses
        </a>
      </div>
      <div>
        {docs}
        <div className="row">
          <div className="col-xs-5">
            <label className="text-muted cos-thin-label">{name}s</label>
          </div>
          <div className="col-xs-6">
            <label className="text-muted cos-thin-label">Hosts</label>
          </div>
        </div>

        <FieldRowList id={id} Row={NodeRow} rowFields={rowFields} />
      </div>
    </div>;
  }
}

const mastersFields = makeFieldList(BM_MASTERS, 'Master', MAX_MASTERS);
const mastersForm = new Form('MASTERSFORM', [mastersFields]);

export const BM_Controllers = () => <NodeForm
  id={BM_MASTERS}
  name="Master"
  docs={`Master nodes run essential cluster services and don't run end-user apps. Enter
      the MAC addresses of the nodes you'd like to use as masters, and the host names
      you'll use to refer to them.`}
/>;

BM_Controllers.canNavigateForward = mastersForm.canNavigateForward;

const workerFields = makeFieldList(BM_WORKERS, 'Worker', MAX_WORKERS);
const workersForm = new Form('WORKERS_FORM', [workerFields]);

export const BM_Workers = () => <NodeForm
  id={BM_WORKERS}
  name="Worker"
  docs={`Worker nodes run end-user apps. The cluster software automatically shares load
      between these nodes. Enter the MAC addresses of the nodes you'd like to use as
      workers, and the host names you'll use to refer to them.`}
/>;

BM_Workers.canNavigateForward = workersForm.canNavigateForward;
