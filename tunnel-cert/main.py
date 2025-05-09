import json
import os
import types

import yaml


def load_object(dct):
  return types.SimpleNamespace(**dct)


def yaml_to_obj(filename):
  with open(filename, 'r') as f:
    d = yaml.safe_load(f)

  return json.loads(json.dumps(d), object_hook=load_object)


def main():
  domains = yaml_to_obj('./config.yml').domains

  template_dir = './templates'
  output_dir = './output'

  if not os.path.exists(output_dir):
    os.mkdir(output_dir)

  os.popen(f'cp {template_dir}/Dockerfile {output_dir}/Dockerfile')

  # squarespace doesn't support dynamic DNS
  #
  # with open(f'{template_dir}/ddclient.conf', 'r') as f:
  #   ddclient = f.read()
  #
  # with open(f'{output_dir}/ddclient.conf', 'w') as f:
  #   f.write('\n'.join(
  #     ddclient.format(SERVER=domain.ddclient.server,
  #                     LOGIN=domain.ddclient.login,
  #                     PASSWORD=domain.ddclient.password,
  #                     DOMAIN_NAME=domain.domain_name) for domain in domains
  #     if hasattr(domain, 'ddclient')))

  with open(f'{template_dir}/nginx.conf', 'r') as f:
    nginx = f.read()

  with open(f'{template_dir}/nginx-tcp.conf', 'r') as f:
    nginx_tcp = f.read()

  with open(f'{template_dir}/nginx-https.conf', 'r') as f:
    nginx_https = f.read()

  with open(f'{output_dir}/nginx.conf', 'w') as f:
    nginx_servers = []
    for domain in domains:
      if domain.tcp_mode:
        nginx_servers.append(
          nginx_tcp.format(DOMAIN_NAME=domain.domain_name,
                           HTTP_PROXY_PASS_PORT=domain.http_proxy_pass_port,
                           HTTPS_PROXY_PASS_PORT=domain.https_proxy_pass_port))
      else:
        nginx_servers.append(
          nginx_https.format(DOMAIN_NAME=domain.domain_name,
                             HTTPS_PROXY_PASS_PORT=domain.https_proxy_pass_port))
    f.write(nginx.format(SERVERS='\n'.join(nginx_servers)))

  with open(f'{template_dir}/provision.sh', 'r') as f:
    provision = f.read()

  with open(f'{output_dir}/provision.sh', 'w') as f:
    certbot_cmd = '\n'.join(
      f'certbot certonly --nginx --agree-tos --register-unsafely-without-email -d {domain.domain_name}'
      for domain in domains if not domain.tcp_mode)
    f.write(provision.format(CERTBOT_CMD=certbot_cmd))


if __name__ == '__main__':
  main()
