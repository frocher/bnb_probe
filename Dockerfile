FROM ruby:2.3.0-slim

ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN \
apt-get update && \
apt-get install -y wget unzip && \
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
wget -N http://chromedriver.storage.googleapis.com/2.21/chromedriver_linux64.zip && \
unzip chromedriver_linux64.zip && \
rm chromedriver_linux64.zip && \
chmod +x chromedriver && \
mv -f chromedriver /usr/bin/chromedriver && \
apt-get update && apt-get install -y \
ca-certificates \
libgl1-mesa-dri \
xfonts-100dpi \
xfonts-75dpi \
xfonts-scalable \
xfonts-cyrillic \
xvfb --no-install-recommends && \
apt-get purge -y wget unzip && \
apt-get install -y \
google-chrome-stable && \
apt-get clean autoclean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN \
apt-get update && \
apt-get install -y curl && \
curl --silent --location https://deb.nodesource.com/setup_4.x | bash - && \
apt-get install -y \
default-jre-headless \
git \
libicu52 \
nodejs \
libcurl3 libcurl3-gnutls libsqlite3-dev \
libcurl4-openssl-dev \
build-essential --no-install-recommends && \
npm install -g browsertime && npm cache clean && \
apt-get clean autoclean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./scripts/ /home/root/scripts

ENTRYPOINT ["/home/root/scripts/start.sh"]

ENV APP_HOME /twb_probe
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME

EXPOSE 3000
