PROTOC := $(shell find $$HOME/.conan2 -name protoc | grep 'build/Release')
GRPC_CC_PLUGIN := $(shell find $$HOME/.conan2 -name grpc_cpp_plugin | grep 'build/Release')

all: gen_cc gen_go

.PHONY: gen_cc
gen_cc:
	$(PROTOC) --proto_path=. \
		--cpp_out=gen_cc \
		--grpc_out=gen_cc --plugin=protoc-gen-grpc=$(GRPC_CC_PLUGIN) \
		./*.proto

.PHONY: gen_go
gen_go:
	$(PROTOC) --proto_path=. \
		--go_out=gen_go --go_opt=paths=source_relative \
		--go-grpc_out=gen_go --go-grpc_opt=paths=source_relative \
		--connect-go_out=gen_go --connect-go_opt=paths=source_relative --connect-go_opt=package_suffix=_connect \
		./*.proto

.PHONY: clean
clean:
	find gen_* -type f \( -name '*.cc' -o -name '*.h' -o -iname '*.go' \) -delete
