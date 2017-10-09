const express = require('express');
const router = express.Router();
const chromeLauncher = require('chrome-launcher');
const lighthouse = require('lighthouse');
const Printer = require('lighthouse/lighthouse-cli/printer.js');

function launchChromeAndRunLighthouse(url, flags = {}, config = null) {
  return chromeLauncher.launch({chromeFlags: ['--disable-gpu', '--headless']}).then(chrome => {
    flags.port = chrome.port;
    return lighthouse(url, flags, config).then(results =>
      chrome.kill().then(() => {
        if (flags.output !== Printer.OutputMode.json) {
          return Printer.createOutput(results, flags.output)
        }
        return results;
      }));
  });
}

router.get('/', function (req, res, next) {
  const flags = {};

  let type = req.query.type || 'json';
  if (type === 'html') {
    flags.output = Printer.OutputMode.html;
  }
  else {
    flags.output = Printer.OutputMode.json;
  }

  launchChromeAndRunLighthouse(req.query.url, flags)
    .then(results => {
      res.send(results);
    })
    .catch(e => {
      console.error(e);
      res.status(500).send({error: 'Could not execute lighthouse'});
    });
});

module.exports = router;
