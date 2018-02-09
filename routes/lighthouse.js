const express = require('express');
const router = express.Router();
const chromeLauncher = require('chrome-launcher');
const lighthouse = require('lighthouse');
const Printer = require('lighthouse/lighthouse-cli/printer.js');

function launchChromeAndRunLighthouse(url, flags = {}, config = null) {
  return chromeLauncher.launch({chromeFlags: ['--disable-gpu', '--headless']}).then(chrome => {
    flags.port = chrome.port;
    return lighthouse(url, flags, config).then(results =>
      chrome.kill().then(() => results));
  });
}

router.get('/', function (req, res, next) {
  const flags = {};

  launchChromeAndRunLighthouse(req.query.url, flags)
    .then(results => {
      const pwa = Math.round(results['reportCategories'][0]['score']);
      const performance = Math.round(results['reportCategories'][1]['score']);
      const accessibility = Math.round(results['reportCategories'][2]['score']);
      const bestPractices = Math.round(results['reportCategories'][3]['score']);
      const seo = Math.round(results['reportCategories'][4]['score']);
      res.setHeader('X-Lighthouse-scores', `${pwa};${performance};${accessibility};${bestPractices};${seo}`);

      const audits = results['audits'];
      const ttfb = Math.round(audits['time-to-first-byte']['rawValue']);
      const firstMeaningfulPaint = Math.round(audits['first-meaningful-paint']['rawValue']);
      const firstInteractive = Math.round(audits['first-interactive']['rawValue']);
      const speedIndex = Math.round(audits['speed-index-metric']['rawValue']);
      res.setHeader('X-Lighthouse-metrics', `${ttfb};${firstMeaningfulPaint};${firstInteractive};${speedIndex}`);

      delete results.artifacts;

      let type = req.query.type || 'json';
      if (type === 'html') {
        results = Printer.createOutput(results, Printer.OutputMode.html);
      }

      res.send(results);
    })
    .catch(e => {
      console.error(e);
      res.status(500).send({error: 'Could not execute lighthouse'});
    });
});

module.exports = router;
