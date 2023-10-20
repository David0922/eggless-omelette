from flask import Flask, make_response

from py_lib.my_str import MyStr

app = Flask(__name__)


@app.route('/', methods=['GET'])
def goodbye_world():
  return make_response('goodbye world\n', 200)


if __name__ == '__main__':
  print(MyStr('goodbye world').s)
  app.run(host='0.0.0.0', port=3000)
