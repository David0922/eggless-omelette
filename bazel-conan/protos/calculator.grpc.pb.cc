// Generated by the gRPC C++ plugin.
// If you make any local change, they will be lost.
// source: calculator.proto

#include "calculator.pb.h"
#include "calculator.grpc.pb.h"

#include <functional>
#include <grpcpp/support/async_stream.h>
#include <grpcpp/support/async_unary_call.h>
#include <grpcpp/impl/channel_interface.h>
#include <grpcpp/impl/client_unary_call.h>
#include <grpcpp/support/client_callback.h>
#include <grpcpp/support/message_allocator.h>
#include <grpcpp/support/method_handler.h>
#include <grpcpp/impl/rpc_service_method.h>
#include <grpcpp/support/server_callback.h>
#include <grpcpp/impl/server_callback_handlers.h>
#include <grpcpp/server_context.h>
#include <grpcpp/impl/service_type.h>
#include <grpcpp/support/sync_stream.h>

static const char* Calculator_method_names[] = {
  "/Calculator/Add",
};

std::unique_ptr< Calculator::Stub> Calculator::NewStub(const std::shared_ptr< ::grpc::ChannelInterface>& channel, const ::grpc::StubOptions& options) {
  (void)options;
  std::unique_ptr< Calculator::Stub> stub(new Calculator::Stub(channel, options));
  return stub;
}

Calculator::Stub::Stub(const std::shared_ptr< ::grpc::ChannelInterface>& channel, const ::grpc::StubOptions& options)
  : channel_(channel), rpcmethod_Add_(Calculator_method_names[0], options.suffix_for_stats(),::grpc::internal::RpcMethod::NORMAL_RPC, channel)
  {}

::grpc::Status Calculator::Stub::Add(::grpc::ClientContext* context, const ::AddRequest& request, ::AddResponse* response) {
  return ::grpc::internal::BlockingUnaryCall< ::AddRequest, ::AddResponse, ::grpc::protobuf::MessageLite, ::grpc::protobuf::MessageLite>(channel_.get(), rpcmethod_Add_, context, request, response);
}

void Calculator::Stub::async::Add(::grpc::ClientContext* context, const ::AddRequest* request, ::AddResponse* response, std::function<void(::grpc::Status)> f) {
  ::grpc::internal::CallbackUnaryCall< ::AddRequest, ::AddResponse, ::grpc::protobuf::MessageLite, ::grpc::protobuf::MessageLite>(stub_->channel_.get(), stub_->rpcmethod_Add_, context, request, response, std::move(f));
}

void Calculator::Stub::async::Add(::grpc::ClientContext* context, const ::AddRequest* request, ::AddResponse* response, ::grpc::ClientUnaryReactor* reactor) {
  ::grpc::internal::ClientCallbackUnaryFactory::Create< ::grpc::protobuf::MessageLite, ::grpc::protobuf::MessageLite>(stub_->channel_.get(), stub_->rpcmethod_Add_, context, request, response, reactor);
}

::grpc::ClientAsyncResponseReader< ::AddResponse>* Calculator::Stub::PrepareAsyncAddRaw(::grpc::ClientContext* context, const ::AddRequest& request, ::grpc::CompletionQueue* cq) {
  return ::grpc::internal::ClientAsyncResponseReaderHelper::Create< ::AddResponse, ::AddRequest, ::grpc::protobuf::MessageLite, ::grpc::protobuf::MessageLite>(channel_.get(), cq, rpcmethod_Add_, context, request);
}

::grpc::ClientAsyncResponseReader< ::AddResponse>* Calculator::Stub::AsyncAddRaw(::grpc::ClientContext* context, const ::AddRequest& request, ::grpc::CompletionQueue* cq) {
  auto* result =
    this->PrepareAsyncAddRaw(context, request, cq);
  result->StartCall();
  return result;
}

Calculator::Service::Service() {
  AddMethod(new ::grpc::internal::RpcServiceMethod(
      Calculator_method_names[0],
      ::grpc::internal::RpcMethod::NORMAL_RPC,
      new ::grpc::internal::RpcMethodHandler< Calculator::Service, ::AddRequest, ::AddResponse, ::grpc::protobuf::MessageLite, ::grpc::protobuf::MessageLite>(
          [](Calculator::Service* service,
             ::grpc::ServerContext* ctx,
             const ::AddRequest* req,
             ::AddResponse* resp) {
               return service->Add(ctx, req, resp);
             }, this)));
}

Calculator::Service::~Service() {
}

::grpc::Status Calculator::Service::Add(::grpc::ServerContext* context, const ::AddRequest* request, ::AddResponse* response) {
  (void) context;
  (void) request;
  (void) response;
  return ::grpc::Status(::grpc::StatusCode::UNIMPLEMENTED, "");
}

