var page = require('webpage').create();
var system = require('system');

if (system.args.length === 1) {
  console.log('Usage: check.js <some URL>');
  phantom.exit(1);
} else {
  var t = Date.now();
  var address = system.args[1];

  page.onError = function (msg, trace) {
    //console.error(msg);
    trace.forEach(function(item) {
      //console.error('  ', item.file, ':', item.line);
    });
  };

  page.open(address, function (status) {
    var result = new Object();
    if (status !== 'success') {
      result.error = 'FAIL to load the address';
    } else {
      result.success = 'success';
    }
    console.log(JSON.stringify(result));
    phantom.exit();
  });
}
