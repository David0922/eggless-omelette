PROTOC := $(shell find $$HOME/.conan2 -name protoc | grep 'build/Release')
GRPC_CC_PLUGIN := $(shell find $$HOME/.conan2 -name grpc_cpp_plugin | grep 'build/Release')

all:
	$(PROTOC) --proto_path=. --cpp_out=. ./*.proto
	$(PROTOC) --proto_path=. --grpc_out=. --plugin=protoc-gen-grpc=$(GRPC_CC_PLUGIN) ./*.proto

clean:
	rm ./*.cc ./*.h
