var express = require('express');
var router = express.Router();
var http = require('http');
var request = require('superagent');


function checkKeyword(data, keyword, checkType) {
  return checkType === "presence" ? data.indexOf(keyword) !== -1 : data.indexOf(keyword) === -1;
}

function doubleCheck() {
  return new Promise( (resolve, reject) => {
    request.get('https://www.google.com').end(function(err, res) {
      resolve(res.status < 300);
    });
  });
}

router.get('/', function(req, res, next) {
  request.get(req.query.url).end(function(err, result) {

    if (!result || result.status >= 300) {
      doubleCheck().then(isCheck => {
        if (isCheck) {
          if (result) {
            res.send({status: 'failed', errorMessage: `Status code failed : ${result.status}`, content: result.text});
          }
          else {
            res.send({status: 'failed', errorMessage: `Can't check ${req.query.url}. Code: ${err.code}`});
          }
        }
        else {
          res.send({status: "success"});
        }
      });
    }
    else {
      if (!req.query.keyword) {
        res.send({status: "success"});
      }
      else {
        let checkType = req.query.type || "presence";
        if (checkKeyword(result.text, req.query.keyword, checkType)) {
          res.send({status: "success"});
        }
        else {
          res.send({status: 'failed', errorMessage: `Check of ${checkType} of ${req.query.keyword} failed.`, content: result.text});
        }
      }
    }
  });
});

module.exports = router;
