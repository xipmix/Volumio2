#!/bin/bash

cd /home/volumio
echo "Backing Up current Volumio folder in /volumio-current"
backup=/var/tmp/volumio-current
[ -d "$backup" ] && rm -rf "$backup"
mv /volumio "$backup"
echo "Cloning Volumio Backend repo"
git clone https://github.com/volumio/Volumio2.git /volumio
echo "Copying Modules"
cp -rp "$backup"/node_modules /volumio/node_modules
echo "Copying UI"
cp -rp "$backup"/volumio-current/http/www /volumio/http/www
echo "Getting Network Manager"
wget https://raw.githubusercontent.com/volumio/Build/master/volumio/bin/wireless.js -O /volumio/app/plugins/system_controller/network/wireless.js
echo "Setting Proper permissions"
chown -R volumio:volumio /volumio
chmod a+x /volumio/app/plugins/system_controller/network/wireless.js
