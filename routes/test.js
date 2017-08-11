var express = require('express');
var router = express.Router();
var http = require('http');
var request = require('superagent');


function checkKeyword(data, keyword, checkType) {
  return check_type === "presence" ? data.indexOf(keyword) !== -1 : data.indexOf(keyword) === -1;
}

function doubleCheck() {
  return http.get('https://www.google.com', (res) => {
    const { statusCode } = res;
    return statusCode < 400;
  });
}

router.get('/', function(req, res, next) {
  var request = http.get(req.query.url, (result) => {
    const { statusCode } = result;
    let success = true;

    if (statusCode < 300 && !req.query.keyword) {
      res.send({status: "success"});
    }
    else {
      console.log("-1");
      let body = '';
      result.setEncoding('utf8');
      result.on('data', (chunk) => { body += chunk; });
      result.on('end', () => {
        console.log("0");
        if (statusCode >= 300) {
          console.log("1");
          doubleCheck().then(isCheck => {
            console.log("2");
            if (isCheck) {
              res.send({status: 'failed', errorMessage: `Status code failed : ${statusCode}`, content: body});
            }
            else {
              res.send({status: "success"});
            }
          });
        }
        else if (req.query.keyword){
          let checkType = req.query.type || "presence";
          if (checkKeyword(body, req.query.keyword, checkType)) {
            res.send({status: "success"});
          }
          else {
            res.send({status: 'failed', errorMessage: `Check of ${checkType} of ${req.query.keyword} failed.`, content: body});
          }
        }
      });
    }
  });

  request.on('error', function (err) {
    res.send({status: 'failed', errorMessage: `Can't check ${req.query.url}. Code: ${err.code}`});
    console.log(err);
  });
});

module.exports = router;
