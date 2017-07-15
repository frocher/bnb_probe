FROM frocher/bnb_base

# dependencies
RUN apt-get update -y && apt-get install -y \
  imagemagick \
  ipython \
  ipython-notebook \
  libjpeg-dev \
  python \
  python-dev \
  python-imaging \
  python-numpy \
  python-scipy \
  python-matplotlib \
  python-pandas \
  python-pip \
  python-sympy \
  python-nose \
  wget \
  xz-utils \
  --no-install-recommends --force-yes && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  pip install --upgrade pip && \
  pip install --upgrade setuptools && \
  pip install pyssim

# ffmpeg
RUN wget http://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz && \
  tar xf ffmpeg-release-64bit-static.tar.xz && \
  mv ffmpeg*/ffmpeg /usr/bin/ && \
  mv ffmpeg*/ffprobe /usr/bin/ && \
  rm ffmpeg-release-64bit-static.tar.xz

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

# firefox
RUN \
apt-get update && \
apt-get install -y --no-install-recommends firefox && \
apt-get clean autoclean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# browsertime
RUN \
apt-get update && \
apt-get install -y \
libicu55 \
libcurl3 libcurl3-gnutls libsqlite3-dev \
libcurl4-openssl-dev \
build-essential --no-install-recommends && \
npm install -g browsertime && npm cache clean && \
apt-get clean autoclean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV BROWSERTIME_XVFB true
ENV BROWSERTIME_CONNECTIVITY__ENGINE tc
ENV BROWSERTIME_CHROME__ARGS no-sandbox

# Start script and work dir
ADD ./scripts/ /home/root/scripts
ENTRYPOINT ["/home/root/scripts/start.sh"]

ENV APP_HOME /bnb_probe
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Create app
ADD Gemfile* $APP_HOME/
RUN bundle install --without development test

ADD . $APP_HOME

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-p", "3000", "-b", "0.0.0.0"]
