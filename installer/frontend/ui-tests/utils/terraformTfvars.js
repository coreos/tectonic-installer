const _ = require('lodash');
const deep = require('deep-diff').diff;
const fs = require('fs');
const JSZip = require('jszip');
const path = require('path');
const request = require('request');
const yaml = require('js-yaml');

const diffTfvars = (client, assetsZip, expected, ignoredKeys = []) => {
  return JSZip.loadAsync(assetsZip).then(zip => {
    zip.file(/tectonic-cluster-config.yaml$/)[0].async('string').then(yamlStr => {
      const actual = yaml.safeLoad(yamlStr);
      ignoredKeys.forEach(keyPath => {
        _.unset(actual, keyPath);
        _.unset(expected, keyPath);
      });
      const diff = deep(actual, expected);
      if (diff !== undefined) {
        client.assert.fail(
          'The following cluster config attributes differ from their expected value: ' +
          diff.map(d => `\n  ${d.path.join('.')} (expected: ${d.rhs}, got: ${d.lhs})`)
        );
      }
    });
  });
};

const testManualBoot = (client, expectedOutputFilePath, ignoredKeys) => {
  const page = client.page.submitPage();

  // It should be safe to refresh the page and have all field values preserved
  client.refresh();
  page.expect.element('@manualBoot').to.be.visible.before(60000);

  page
    .click('@manualBoot')
    .expect.element('a[href="/terraform/assets"]').to.be.visible.before(120000);

  client.getCookie('tectonic-installer', ({value}) => {
    const options = {
      url: `${client.launch_url}/terraform/assets`,
      method: 'GET',
      encoding: null,
      headers: {'Cookie': `tectonic-installer=${value}`},
    };
    request(options, (err, res, assetsZip) => {
      if (err) {
        return client.assert.fail(err);
      }
      if (res.statusCode !== 200 || res.headers['content-type'] !== 'application/zip') {
        return client.assert.fail('Terraform get assets API call failed');
      }

      // eslint-disable-next-line no-sync
      const expected = yaml.safeLoad(fs.readFileSync(path.join(__dirname, expectedOutputFilePath), 'utf8'));

      diffTfvars(client, assetsZip, expected, ignoredKeys)
        .then(() => client.click('.btn-link .fa-refresh'));
    });
  });

  page.expect.element('select#platformType').to.be.visible.before(60000);
};

const jsonDir = path.join(__dirname, '..', '..', '__tests__', 'examples');
// eslint-disable-next-line no-sync
const loadJson = filename => JSON.parse(fs.readFileSync(path.join(jsonDir, filename), 'utf8'));

module.exports = {
  loadJson,
  testManualBoot,
};
