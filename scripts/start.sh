#!/bin/bash
set -e
date

# print versions
google-chrome-stable --version
firefox --version

sudo rm -f /var/lib/dbus/machine-id
sudo mkdir -p /var/run/dbus
sudo service dbus restart > /dev/null
service dbus status > /dev/null
export $(dbus-launch)
export NSS_USE_SHARED_DB=ENABLED

rm -f tmp/pids/server.pid

exec "$@"
