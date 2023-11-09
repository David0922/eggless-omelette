import os
import sys

from flask import Flask, make_response, request
from flask_cors import CORS
from requests.compat import urljoin

img_dir = None
img_urls = None

app = Flask(__name__, static_url_path='/img')
CORS(app)


def make_img_url(filename):
  return urljoin(request.host_url, app.static_url_path + '/' + filename)


def is_img(path):
  return path.split('.')[-1].lower() in ['gif', 'jpeg', 'jpg', 'png', 'webp']


def load_img_urls():
  global img_urls
  img_urls = []

  for root, _, files in os.walk(img_dir):
    for filename in files:
      if is_img(filename):
        img_urls.append(make_img_url(os.path.relpath(root + '/' + filename, img_dir)))

  img_urls.sort()


@app.route('/', methods=['GET'])
def imgs():
  if not img_urls:
    load_img_urls()

  style = 'display: block; margin: 0 auto; max-width: 100%;'
  html = '\n'.join(f'<img src="{url}" style="{style}" />' for url in img_urls)

  return make_response(html, 200)


if __name__ == '__main__':
  if len(sys.argv) != 2:
    print(f'usage: {sys.argv[0]} [/path/to/imgs]')
    exit(1)

  img_dir = sys.argv[1]

  if not os.path.exists(img_dir):
    os.makedirs(img_dir)

  app.static_folder = img_dir

  app.run(host='0.0.0.0', port=8080)
