import logging
from concurrent import futures

import grpc

from protos import calculator_pb2, calculator_pb2_grpc


class Calculator(calculator_pb2_grpc.CalculatorServicer):

  def Add(self, req, ctx):
    logging.info(f'request: {req}')
    return calculator_pb2.AddResponse(c=req.a + req.b)


def serve():
  port = 3000
  server_addr = f'0.0.0.0:{port}'

  server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
  calculator_pb2_grpc.add_CalculatorServicer_to_server(Calculator(), server)
  server.add_insecure_port(server_addr)
  server.start()

  logging.info(f'server listening on: {server_addr}')

  server.wait_for_termination()


if __name__ == '__main__':
  logging.basicConfig(level=logging.INFO)
  serve()
