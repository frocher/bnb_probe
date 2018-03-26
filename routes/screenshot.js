const express = require('express');
const router = express.Router();
const puppeteer = require('puppeteer');


router.get('/', function (req, res, next) {
  puppeteer.launch().then(async browser => {
    const page = await browser.newPage();
    page.setViewport({
      width: req.params.width ? parseInt(req.params.width, 10) : 1024,
      height: req.params.heigh ? parseInt(req.params.height, 10) : 768
    });
    await page.goto(req.query.url, {timeout: 60000});
    const shot = await page.screenshot({});
    await browser.close();
    res.setHeader('Content-Type', 'image/png');
    res.status(200).send(shot);
  }).catch(e => {
    console.error(e);
    res.status(500).send({error: 'Could not take screenshot'});
  });
});

module.exports = router;
