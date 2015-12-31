## The WatchBots Probe

### Dependencies

* Node.js
* Ruby 2.2
* libcurl
* Browsertime (http://tobli.github.io/browsertime/)
* Google Chrome
* Google Chrome Driver

### Quicklaunch for Development

docker run -P -t twb_probe bundle exec rails s -p 3000 -b '0.0.0.0'

```sh
bundle install
```

To start the probe server :
```sh
rails s -b 0.0.0.0
```

### The Docker way

TODO...

### Configuration

TODO...

### Advanced installation

Chrome dependencies:

```sh
apt-get update
apt-get install -y wget unzip
apt-get install -y ca-certificates libgl1-mesa-dri xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic xvfb --no-install-recommends
apt-get clean autoclean
```

Chrome:

```sh
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update
sudo apt-get install google-chrome-stable
```

Chrome Driver :

```sh
wget -N http://chromedriver.storage.googleapis.com/2.20/chromedriver_linux64.zip
unzip chromedriver_linux64.zip &&
rm chromedriver_linux64.zip
chmod +x chromedriver &&
mv -f chromedriver /usr/bin/chromedriver
```

Xvfb configuration :

```sh
export DISPLAY=:10
Xvfb :10 -screen 0 1366x768x24 -ac &
```
