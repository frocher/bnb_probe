var express = require('express');
var router = express.Router();
var chromeLauncher = require('chrome-launcher');
var lighthouse = require('lighthouse');

function launchChromeAndRunLighthouse(url, flags = {}, config = null) {
  return chromeLauncher.launch({chromeFlags: ['--disable-gpu','--headless']}).then(chrome => {
    flags.port = chrome.port;
    return lighthouse(url, flags, config).then(results =>
      chrome.kill().then(() => results));
  });
}

router.get('/', function(req, res, next) {
  const flags = {};
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
