#include <grpcpp/grpcpp.h>

#include <iostream>
#include <memory>
#include <string>

#include "absl/strings/str_format.h"
#include "protos/calculator.grpc.pb.h"

class CalculatorServiceImpl final : public Calculator::Service {
  grpc::Status Add(grpc::ServerContext*, const AddRequest* req,
                   AddResponse* res) override {
    res->set_c(req->a() + req->b());
    return grpc::Status::OK;
  }
};

int main(int argc, char** argv) {
  const int port = 3000;
  std::string server_address = absl::StrFormat("0.0.0.0:%d", port);

  CalculatorServiceImpl service;

  grpc::ServerBuilder builder;

  builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
  builder.RegisterService(&service);

  std::unique_ptr<grpc::Server> server(builder.BuildAndStart());

  std::cout << "server listening on: " << server_address << std::endl;

  server->Wait();

  return 0;
}
