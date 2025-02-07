#include <fmt/format.h>
#include <grpcpp/grpcpp.h>

#include <iostream>
#include <memory>
#include <string>

#include "protos/calculator.grpc.pb.h"

int main(int argc, char** argv) {
  const int port = 3000;
  std::string server_address = fmt::format("0.0.0.0:{}", port);

  std::unique_ptr<Calculator::Stub> stub = Calculator::NewStub(
      grpc::CreateChannel(server_address, grpc::InsecureChannelCredentials()));

  AddRequest req;
  AddResponse res;

  int a, b;

  while (std::cin >> a >> b) {
    grpc::ClientContext ctx;

    req.set_a(a);
    req.set_b(b);

    grpc::Status status = stub->Add(&ctx, req, &res);

    if (status.ok()) {
      std::cout << "c: " << res.c() << std::endl;
    } else {
      std::cout << status.error_code() << ": " << status.error_message()
                << std::endl;
    }
  }

  return 0;
}
