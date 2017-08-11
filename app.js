require('dotenv').config()
var express = require('express');
var path = require('path');
var logger = require('morgan');
var compression = require('compression');
var index = require('./routes/index');
var har = require('./routes/har');
var lighthouse = require('./routes/lighthouse');
var uptime = require('./routes/uptime');

var app = express();

app.use(compression())
app.use(logger('dev'));

app.use(function(req, res, next) {
  if (process.env.PROBE_TOKEN && process.env.PROBE_TOKEN !== req.query.token) {
    res.status(403).send({ error: 'Invalid token' });
  }
  else {
    next();
  }
});

app.use('/', index);
app.use('/har', har);
app.use('/lighthouse', lighthouse);
app.use('/uptime', uptime);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  res.status(404).send({ error: 'Not found' });
  next();
});

// error handler
app.use(function(err, req, res, next) {
  res.status(500).send({ error: 'Oops, something went wrong' });
});

module.exports = app;
