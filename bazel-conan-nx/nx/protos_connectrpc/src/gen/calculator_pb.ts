// @generated by protoc-gen-es v2.2.5 with parameter "target=ts"
// @generated from file calculator.proto (syntax proto3)
/* eslint-disable */

import type { GenFile, GenMessage, GenService } from "@bufbuild/protobuf/codegenv1";
import { fileDesc, messageDesc, serviceDesc } from "@bufbuild/protobuf/codegenv1";
import type { Message } from "@bufbuild/protobuf";

/**
 * Describes the file calculator.proto.
 */
export const file_calculator: GenFile = /*@__PURE__*/
  fileDesc("ChBjYWxjdWxhdG9yLnByb3RvIiIKCkFkZFJlcXVlc3QSCQoBYRgBIAEoBRIJCgFiGAIgASgFIhgKC0FkZFJlc3BvbnNlEgkKAWMYASABKAUyMAoKQ2FsY3VsYXRvchIiCgNBZGQSCy5BZGRSZXF1ZXN0GgwuQWRkUmVzcG9uc2UiAEIeWhxkdW1teS5tb2Z1LmRldi9wcm90b3MvZ2VuX2dvYgZwcm90bzM");

/**
 * @generated from message AddRequest
 */
export type AddRequest = Message<"AddRequest"> & {
  /**
   * @generated from field: int32 a = 1;
   */
  a: number;

  /**
   * @generated from field: int32 b = 2;
   */
  b: number;
};

/**
 * Describes the message AddRequest.
 * Use `create(AddRequestSchema)` to create a new message.
 */
export const AddRequestSchema: GenMessage<AddRequest> = /*@__PURE__*/
  messageDesc(file_calculator, 0);

/**
 * @generated from message AddResponse
 */
export type AddResponse = Message<"AddResponse"> & {
  /**
   * @generated from field: int32 c = 1;
   */
  c: number;
};

/**
 * Describes the message AddResponse.
 * Use `create(AddResponseSchema)` to create a new message.
 */
export const AddResponseSchema: GenMessage<AddResponse> = /*@__PURE__*/
  messageDesc(file_calculator, 1);

/**
 * @generated from service Calculator
 */
export const Calculator: GenService<{
  /**
   * @generated from rpc Calculator.Add
   */
  add: {
    methodKind: "unary";
    input: typeof AddRequestSchema;
    output: typeof AddResponseSchema;
  },
}> = /*@__PURE__*/
  serviceDesc(file_calculator, 0);

