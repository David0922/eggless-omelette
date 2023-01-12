#!/bin/bash

set -e -x

export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get upgrade -qq

apt-get install -qq \
  ddclient \
  nginx \
  perl \
  python3-pip \
  python3.8 \
  vim

pip install certbot certbot-nginx

ln -s /opt/certbot/bin/certbot /usr/bin/certbot

mv /work-dir/ddclient.conf /etc/ddclient.conf

service ddclient restart

sleep 300

certbot certonly --nginx \
  --agree-tos \
  --domains DOMAIN_NAME \
  --register-unsafely-without-email

echo "0 0,12 * * * root python3 -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew -q" | tee -a /etc/crontab

service nginx stop

rm -rf /etc/nginx/sites-enabled
mv /work-dir/nginx.conf /etc/nginx/conf.d/nginx.conf
