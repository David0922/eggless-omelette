import logging

import grpc

from protos import calculator_pb2, calculator_pb2_grpc


def main():
  port = 3000
  server_addr = f'0.0.0.0:{port}'

  with grpc.insecure_channel(server_addr) as channel:
    stub = calculator_pb2_grpc.CalculatorStub(channel)

    while 1:
      a, b = int(input('a: ')), int(input('b: '))

      req = calculator_pb2.AddRequest(a=a, b=b)
      res = stub.Add(req)

      logging.info(res)


if __name__ == '__main__':
  logging.basicConfig(level=logging.INFO)
  main()
