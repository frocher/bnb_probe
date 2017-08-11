FROM frocher/bnb_base


# chrome
RUN \
apt-get update && \
apt-get install -y wget sudo && \
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
apt-get update && apt-get install -y \
ca-certificates \
x11vnc \
libgl1-mesa-dri \
xfonts-100dpi \
xfonts-75dpi \
xfonts-scalable \
xfonts-cyrillic \
dbus-x11 \
xvfb --no-install-recommends && \
apt-get purge -y wget && \
apt-get install -y \
google-chrome-stable && \
apt-get clean autoclean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV APP_HOME /bnb_probe
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Create app
ADD package* $APP_HOME/
RUN npm install

ADD . $APP_HOME

EXPOSE 3000
CMD ["npm", "start"]
