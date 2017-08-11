const chromeLauncher = require('chrome-launcher');
const chc = require('chrome-har-capturer');
const program = require('commander');

function launchChrome(headless=true) {
  return chromeLauncher.launch({
    chromeFlags: [
      '--disable-gpu',
      headless ? '--headless' : ''
    ]
  });
}

program
  .version('0.1.0')
  .option('-o, --output <file>', 'write to file instead of stdout')
  .parse(process.argv);

if (program.args.length === 0) {
    program.outputHelp();
    process.exit(1);
}

launchChrome().then(chrome => {
  console.log(`Chrome debuggable on port: ${chrome.port}`);

  let opts = {port: chrome.port};
  let urls = program.args;

  chc.run(urls, opts)
    .on('load', (url) => {
      process.stdout.write(url);
    })
    .on('done', (url) => {
      process.stdout.write('✓\n');
      chrome.kill();
    })
    .on('fail', (url, err) => {
      process.stdout.write(`✗\n  ${err.message}\n`);
      chrome.kill();
    })
    .on('har', (har) => {
      const fs = require('fs');
      const json = JSON.stringify(har, null, 4);
      const output = program.output
          ? fs.createWriteStream(program.output)
          : process.stdout;
      output.write(json);
      output.write('\n');
    });

});
