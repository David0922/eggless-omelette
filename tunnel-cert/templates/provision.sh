#!/bin/bash

set -e -x

export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get upgrade -qq

apt-get install -qq \
  nginx \
  python3-pip \
  python3.12
  # ddclient \
  # libaugeas0 \
  # perl \
  # vim

pip install --break-system-packages certbot certbot-nginx

# squarespace doesn't support dynamic DNS
#
# mv /work-dir/ddclient.conf /etc/ddclient.conf
# service ddclient restart
# sleep 300

# CERTBOT_CMD
# certbot certonly --nginx \
#   --agree-tos \
#   --register-unsafely-without-email \
#   -d DOMAIN_name
{CERTBOT_CMD}

echo "0 0,12 * * * root python3 -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew --deploy-hook 'service nginx reload' --no-self-upgrade" | tee -a /etc/crontab

service nginx stop

rm -rf /etc/nginx/sites-enabled

# http(s) only
# mv /work-dir/nginx.conf /etc/nginx/conf.d/nginx.conf

# tcp
mv /work-dir/nginx.conf /etc/nginx/nginx.conf

nginx -t
