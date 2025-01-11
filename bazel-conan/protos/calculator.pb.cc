// Generated by the protocol buffer compiler.  DO NOT EDIT!
// NO CHECKED-IN PROTOBUF GENCODE
// source: calculator.proto
// Protobuf C++ Version: 5.27.0

#include "calculator.pb.h"

#include <algorithm>
#include <type_traits>
#include "google/protobuf/io/coded_stream.h"
#include "google/protobuf/generated_message_tctable_impl.h"
#include "google/protobuf/extension_set.h"
#include "google/protobuf/wire_format_lite.h"
#include "google/protobuf/descriptor.h"
#include "google/protobuf/generated_message_reflection.h"
#include "google/protobuf/reflection_ops.h"
#include "google/protobuf/wire_format.h"
// @@protoc_insertion_point(includes)

// Must be included last.
#include "google/protobuf/port_def.inc"
PROTOBUF_PRAGMA_INIT_SEG
namespace _pb = ::google::protobuf;
namespace _pbi = ::google::protobuf::internal;
namespace _fl = ::google::protobuf::internal::field_layout;

inline constexpr AddResponse::Impl_::Impl_(
    ::_pbi::ConstantInitialized) noexcept
      : c_{0},
        _cached_size_{0} {}

template <typename>
PROTOBUF_CONSTEXPR AddResponse::AddResponse(::_pbi::ConstantInitialized)
    : _impl_(::_pbi::ConstantInitialized()) {}
struct AddResponseDefaultTypeInternal {
  PROTOBUF_CONSTEXPR AddResponseDefaultTypeInternal() : _instance(::_pbi::ConstantInitialized{}) {}
  ~AddResponseDefaultTypeInternal() {}
  union {
    AddResponse _instance;
  };
};

PROTOBUF_ATTRIBUTE_NO_DESTROY PROTOBUF_CONSTINIT
    PROTOBUF_ATTRIBUTE_INIT_PRIORITY1 AddResponseDefaultTypeInternal _AddResponse_default_instance_;

inline constexpr AddRequest::Impl_::Impl_(
    ::_pbi::ConstantInitialized) noexcept
      : a_{0},
        b_{0},
        _cached_size_{0} {}

template <typename>
PROTOBUF_CONSTEXPR AddRequest::AddRequest(::_pbi::ConstantInitialized)
    : _impl_(::_pbi::ConstantInitialized()) {}
struct AddRequestDefaultTypeInternal {
  PROTOBUF_CONSTEXPR AddRequestDefaultTypeInternal() : _instance(::_pbi::ConstantInitialized{}) {}
  ~AddRequestDefaultTypeInternal() {}
  union {
    AddRequest _instance;
  };
};

PROTOBUF_ATTRIBUTE_NO_DESTROY PROTOBUF_CONSTINIT
    PROTOBUF_ATTRIBUTE_INIT_PRIORITY1 AddRequestDefaultTypeInternal _AddRequest_default_instance_;
static constexpr const ::_pb::EnumDescriptor**
    file_level_enum_descriptors_calculator_2eproto = nullptr;
static constexpr const ::_pb::ServiceDescriptor**
    file_level_service_descriptors_calculator_2eproto = nullptr;
const ::uint32_t
    TableStruct_calculator_2eproto::offsets[] ABSL_ATTRIBUTE_SECTION_VARIABLE(
        protodesc_cold) = {
        ~0u,  // no _has_bits_
        PROTOBUF_FIELD_OFFSET(::AddRequest, _internal_metadata_),
        ~0u,  // no _extensions_
        ~0u,  // no _oneof_case_
        ~0u,  // no _weak_field_map_
        ~0u,  // no _inlined_string_donated_
        ~0u,  // no _split_
        ~0u,  // no sizeof(Split)
        PROTOBUF_FIELD_OFFSET(::AddRequest, _impl_.a_),
        PROTOBUF_FIELD_OFFSET(::AddRequest, _impl_.b_),
        ~0u,  // no _has_bits_
        PROTOBUF_FIELD_OFFSET(::AddResponse, _internal_metadata_),
        ~0u,  // no _extensions_
        ~0u,  // no _oneof_case_
        ~0u,  // no _weak_field_map_
        ~0u,  // no _inlined_string_donated_
        ~0u,  // no _split_
        ~0u,  // no sizeof(Split)
        PROTOBUF_FIELD_OFFSET(::AddResponse, _impl_.c_),
};

static const ::_pbi::MigrationSchema
    schemas[] ABSL_ATTRIBUTE_SECTION_VARIABLE(protodesc_cold) = {
        {0, -1, -1, sizeof(::AddRequest)},
        {10, -1, -1, sizeof(::AddResponse)},
};
static const ::_pb::Message* const file_default_instances[] = {
    &::_AddRequest_default_instance_._instance,
    &::_AddResponse_default_instance_._instance,
};
const char descriptor_table_protodef_calculator_2eproto[] ABSL_ATTRIBUTE_SECTION_VARIABLE(
    protodesc_cold) = {
    "\n\020calculator.proto\"\"\n\nAddRequest\022\t\n\001a\030\001 "
    "\001(\005\022\t\n\001b\030\002 \001(\005\"\030\n\013AddResponse\022\t\n\001c\030\001 \001(\005"
    "20\n\nCalculator\022\"\n\003Add\022\013.AddRequest\032\014.Add"
    "Response\"\000B\027Z\025dummy.mofu.dev/protosb\006pro"
    "to3"
};
static ::absl::once_flag descriptor_table_calculator_2eproto_once;
PROTOBUF_CONSTINIT const ::_pbi::DescriptorTable descriptor_table_calculator_2eproto = {
    false,
    false,
    163,
    descriptor_table_protodef_calculator_2eproto,
    "calculator.proto",
    &descriptor_table_calculator_2eproto_once,
    nullptr,
    0,
    2,
    schemas,
    file_default_instances,
    TableStruct_calculator_2eproto::offsets,
    file_level_enum_descriptors_calculator_2eproto,
    file_level_service_descriptors_calculator_2eproto,
};
// ===================================================================

class AddRequest::_Internal {
 public:
};

AddRequest::AddRequest(::google::protobuf::Arena* arena)
    : ::google::protobuf::Message(arena) {
  SharedCtor(arena);
  // @@protoc_insertion_point(arena_constructor:AddRequest)
}
AddRequest::AddRequest(
    ::google::protobuf::Arena* arena, const AddRequest& from)
    : AddRequest(arena) {
  MergeFrom(from);
}
inline PROTOBUF_NDEBUG_INLINE AddRequest::Impl_::Impl_(
    ::google::protobuf::internal::InternalVisibility visibility,
    ::google::protobuf::Arena* arena)
      : _cached_size_{0} {}

inline void AddRequest::SharedCtor(::_pb::Arena* arena) {
  new (&_impl_) Impl_(internal_visibility(), arena);
  ::memset(reinterpret_cast<char *>(&_impl_) +
               offsetof(Impl_, a_),
           0,
           offsetof(Impl_, b_) -
               offsetof(Impl_, a_) +
               sizeof(Impl_::b_));
}
AddRequest::~AddRequest() {
  // @@protoc_insertion_point(destructor:AddRequest)
  _internal_metadata_.Delete<::google::protobuf::UnknownFieldSet>();
  SharedDtor();
}
inline void AddRequest::SharedDtor() {
  ABSL_DCHECK(GetArena() == nullptr);
  _impl_.~Impl_();
}

const ::google::protobuf::MessageLite::ClassData*
AddRequest::GetClassData() const {
  PROTOBUF_CONSTINIT static const ::google::protobuf::MessageLite::
      ClassDataFull _data_ = {
          {
              &_table_.header,
              nullptr,  // OnDemandRegisterArenaDtor
              nullptr,  // IsInitialized
              PROTOBUF_FIELD_OFFSET(AddRequest, _impl_._cached_size_),
              false,
          },
          &AddRequest::MergeImpl,
          &AddRequest::kDescriptorMethods,
          &descriptor_table_calculator_2eproto,
          nullptr,  // tracker
      };
  ::google::protobuf::internal::PrefetchToLocalCache(&_data_);
  ::google::protobuf::internal::PrefetchToLocalCache(_data_.tc_table);
  return _data_.base();
}
PROTOBUF_CONSTINIT PROTOBUF_ATTRIBUTE_INIT_PRIORITY1
const ::_pbi::TcParseTable<1, 2, 0, 0, 2> AddRequest::_table_ = {
  {
    0,  // no _has_bits_
    0, // no _extensions_
    2, 8,  // max_field_number, fast_idx_mask
    offsetof(decltype(_table_), field_lookup_table),
    4294967292,  // skipmap
    offsetof(decltype(_table_), field_entries),
    2,  // num_field_entries
    0,  // num_aux_entries
    offsetof(decltype(_table_), field_names),  // no aux_entries
    &_AddRequest_default_instance_._instance,
    nullptr,  // post_loop_handler
    ::_pbi::TcParser::GenericFallback,  // fallback
    #ifdef PROTOBUF_PREFETCH_PARSE_TABLE
    ::_pbi::TcParser::GetTable<::AddRequest>(),  // to_prefetch
    #endif  // PROTOBUF_PREFETCH_PARSE_TABLE
  }, {{
    // int32 b = 2;
    {::_pbi::TcParser::SingularVarintNoZag1<::uint32_t, offsetof(AddRequest, _impl_.b_), 63>(),
     {16, 63, 0, PROTOBUF_FIELD_OFFSET(AddRequest, _impl_.b_)}},
    // int32 a = 1;
    {::_pbi::TcParser::SingularVarintNoZag1<::uint32_t, offsetof(AddRequest, _impl_.a_), 63>(),
     {8, 63, 0, PROTOBUF_FIELD_OFFSET(AddRequest, _impl_.a_)}},
  }}, {{
    65535, 65535
  }}, {{
    // int32 a = 1;
    {PROTOBUF_FIELD_OFFSET(AddRequest, _impl_.a_), 0, 0,
    (0 | ::_fl::kFcSingular | ::_fl::kInt32)},
    // int32 b = 2;
    {PROTOBUF_FIELD_OFFSET(AddRequest, _impl_.b_), 0, 0,
    (0 | ::_fl::kFcSingular | ::_fl::kInt32)},
  }},
  // no aux_entries
  {{
  }},
};

PROTOBUF_NOINLINE void AddRequest::Clear() {
// @@protoc_insertion_point(message_clear_start:AddRequest)
  ::google::protobuf::internal::TSanWrite(&_impl_);
  ::uint32_t cached_has_bits = 0;
  // Prevent compiler warnings about cached_has_bits being unused
  (void) cached_has_bits;

  ::memset(&_impl_.a_, 0, static_cast<::size_t>(
      reinterpret_cast<char*>(&_impl_.b_) -
      reinterpret_cast<char*>(&_impl_.a_)) + sizeof(_impl_.b_));
  _internal_metadata_.Clear<::google::protobuf::UnknownFieldSet>();
}

::uint8_t* AddRequest::_InternalSerialize(
    ::uint8_t* target,
    ::google::protobuf::io::EpsCopyOutputStream* stream) const {
  // @@protoc_insertion_point(serialize_to_array_start:AddRequest)
  ::uint32_t cached_has_bits = 0;
  (void)cached_has_bits;

  // int32 a = 1;
  if (this->_internal_a() != 0) {
    target = ::google::protobuf::internal::WireFormatLite::
        WriteInt32ToArrayWithField<1>(
            stream, this->_internal_a(), target);
  }

  // int32 b = 2;
  if (this->_internal_b() != 0) {
    target = ::google::protobuf::internal::WireFormatLite::
        WriteInt32ToArrayWithField<2>(
            stream, this->_internal_b(), target);
  }

  if (PROTOBUF_PREDICT_FALSE(_internal_metadata_.have_unknown_fields())) {
    target =
        ::_pbi::WireFormat::InternalSerializeUnknownFieldsToArray(
            _internal_metadata_.unknown_fields<::google::protobuf::UnknownFieldSet>(::google::protobuf::UnknownFieldSet::default_instance), target, stream);
  }
  // @@protoc_insertion_point(serialize_to_array_end:AddRequest)
  return target;
}

::size_t AddRequest::ByteSizeLong() const {
// @@protoc_insertion_point(message_byte_size_start:AddRequest)
  ::size_t total_size = 0;

  ::uint32_t cached_has_bits = 0;
  // Prevent compiler warnings about cached_has_bits being unused
  (void) cached_has_bits;

  ::_pbi::Prefetch5LinesFrom7Lines(reinterpret_cast<const void*>(this));
  // int32 a = 1;
  if (this->_internal_a() != 0) {
    total_size += ::_pbi::WireFormatLite::Int32SizePlusOne(
        this->_internal_a());
  }

  // int32 b = 2;
  if (this->_internal_b() != 0) {
    total_size += ::_pbi::WireFormatLite::Int32SizePlusOne(
        this->_internal_b());
  }

  return MaybeComputeUnknownFieldsSize(total_size, &_impl_._cached_size_);
}


void AddRequest::MergeImpl(::google::protobuf::MessageLite& to_msg, const ::google::protobuf::MessageLite& from_msg) {
  auto* const _this = static_cast<AddRequest*>(&to_msg);
  auto& from = static_cast<const AddRequest&>(from_msg);
  // @@protoc_insertion_point(class_specific_merge_from_start:AddRequest)
  ABSL_DCHECK_NE(&from, _this);
  ::uint32_t cached_has_bits = 0;
  (void) cached_has_bits;

  if (from._internal_a() != 0) {
    _this->_impl_.a_ = from._impl_.a_;
  }
  if (from._internal_b() != 0) {
    _this->_impl_.b_ = from._impl_.b_;
  }
  _this->_internal_metadata_.MergeFrom<::google::protobuf::UnknownFieldSet>(from._internal_metadata_);
}

void AddRequest::CopyFrom(const AddRequest& from) {
// @@protoc_insertion_point(class_specific_copy_from_start:AddRequest)
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}


void AddRequest::InternalSwap(AddRequest* PROTOBUF_RESTRICT other) {
  using std::swap;
  _internal_metadata_.InternalSwap(&other->_internal_metadata_);
  ::google::protobuf::internal::memswap<
      PROTOBUF_FIELD_OFFSET(AddRequest, _impl_.b_)
      + sizeof(AddRequest::_impl_.b_)
      - PROTOBUF_FIELD_OFFSET(AddRequest, _impl_.a_)>(
          reinterpret_cast<char*>(&_impl_.a_),
          reinterpret_cast<char*>(&other->_impl_.a_));
}

::google::protobuf::Metadata AddRequest::GetMetadata() const {
  return ::google::protobuf::Message::GetMetadataImpl(GetClassData()->full());
}
// ===================================================================

class AddResponse::_Internal {
 public:
};

AddResponse::AddResponse(::google::protobuf::Arena* arena)
    : ::google::protobuf::Message(arena) {
  SharedCtor(arena);
  // @@protoc_insertion_point(arena_constructor:AddResponse)
}
AddResponse::AddResponse(
    ::google::protobuf::Arena* arena, const AddResponse& from)
    : AddResponse(arena) {
  MergeFrom(from);
}
inline PROTOBUF_NDEBUG_INLINE AddResponse::Impl_::Impl_(
    ::google::protobuf::internal::InternalVisibility visibility,
    ::google::protobuf::Arena* arena)
      : _cached_size_{0} {}

inline void AddResponse::SharedCtor(::_pb::Arena* arena) {
  new (&_impl_) Impl_(internal_visibility(), arena);
  _impl_.c_ = {};
}
AddResponse::~AddResponse() {
  // @@protoc_insertion_point(destructor:AddResponse)
  _internal_metadata_.Delete<::google::protobuf::UnknownFieldSet>();
  SharedDtor();
}
inline void AddResponse::SharedDtor() {
  ABSL_DCHECK(GetArena() == nullptr);
  _impl_.~Impl_();
}

const ::google::protobuf::MessageLite::ClassData*
AddResponse::GetClassData() const {
  PROTOBUF_CONSTINIT static const ::google::protobuf::MessageLite::
      ClassDataFull _data_ = {
          {
              &_table_.header,
              nullptr,  // OnDemandRegisterArenaDtor
              nullptr,  // IsInitialized
              PROTOBUF_FIELD_OFFSET(AddResponse, _impl_._cached_size_),
              false,
          },
          &AddResponse::MergeImpl,
          &AddResponse::kDescriptorMethods,
          &descriptor_table_calculator_2eproto,
          nullptr,  // tracker
      };
  ::google::protobuf::internal::PrefetchToLocalCache(&_data_);
  ::google::protobuf::internal::PrefetchToLocalCache(_data_.tc_table);
  return _data_.base();
}
PROTOBUF_CONSTINIT PROTOBUF_ATTRIBUTE_INIT_PRIORITY1
const ::_pbi::TcParseTable<0, 1, 0, 0, 2> AddResponse::_table_ = {
  {
    0,  // no _has_bits_
    0, // no _extensions_
    1, 0,  // max_field_number, fast_idx_mask
    offsetof(decltype(_table_), field_lookup_table),
    4294967294,  // skipmap
    offsetof(decltype(_table_), field_entries),
    1,  // num_field_entries
    0,  // num_aux_entries
    offsetof(decltype(_table_), field_names),  // no aux_entries
    &_AddResponse_default_instance_._instance,
    nullptr,  // post_loop_handler
    ::_pbi::TcParser::GenericFallback,  // fallback
    #ifdef PROTOBUF_PREFETCH_PARSE_TABLE
    ::_pbi::TcParser::GetTable<::AddResponse>(),  // to_prefetch
    #endif  // PROTOBUF_PREFETCH_PARSE_TABLE
  }, {{
    // int32 c = 1;
    {::_pbi::TcParser::SingularVarintNoZag1<::uint32_t, offsetof(AddResponse, _impl_.c_), 63>(),
     {8, 63, 0, PROTOBUF_FIELD_OFFSET(AddResponse, _impl_.c_)}},
  }}, {{
    65535, 65535
  }}, {{
    // int32 c = 1;
    {PROTOBUF_FIELD_OFFSET(AddResponse, _impl_.c_), 0, 0,
    (0 | ::_fl::kFcSingular | ::_fl::kInt32)},
  }},
  // no aux_entries
  {{
  }},
};

PROTOBUF_NOINLINE void AddResponse::Clear() {
// @@protoc_insertion_point(message_clear_start:AddResponse)
  ::google::protobuf::internal::TSanWrite(&_impl_);
  ::uint32_t cached_has_bits = 0;
  // Prevent compiler warnings about cached_has_bits being unused
  (void) cached_has_bits;

  _impl_.c_ = 0;
  _internal_metadata_.Clear<::google::protobuf::UnknownFieldSet>();
}

::uint8_t* AddResponse::_InternalSerialize(
    ::uint8_t* target,
    ::google::protobuf::io::EpsCopyOutputStream* stream) const {
  // @@protoc_insertion_point(serialize_to_array_start:AddResponse)
  ::uint32_t cached_has_bits = 0;
  (void)cached_has_bits;

  // int32 c = 1;
  if (this->_internal_c() != 0) {
    target = ::google::protobuf::internal::WireFormatLite::
        WriteInt32ToArrayWithField<1>(
            stream, this->_internal_c(), target);
  }

  if (PROTOBUF_PREDICT_FALSE(_internal_metadata_.have_unknown_fields())) {
    target =
        ::_pbi::WireFormat::InternalSerializeUnknownFieldsToArray(
            _internal_metadata_.unknown_fields<::google::protobuf::UnknownFieldSet>(::google::protobuf::UnknownFieldSet::default_instance), target, stream);
  }
  // @@protoc_insertion_point(serialize_to_array_end:AddResponse)
  return target;
}

::size_t AddResponse::ByteSizeLong() const {
// @@protoc_insertion_point(message_byte_size_start:AddResponse)
  ::size_t total_size = 0;

  ::uint32_t cached_has_bits = 0;
  // Prevent compiler warnings about cached_has_bits being unused
  (void) cached_has_bits;

  // int32 c = 1;
  if (this->_internal_c() != 0) {
    total_size += ::_pbi::WireFormatLite::Int32SizePlusOne(
        this->_internal_c());
  }

  return MaybeComputeUnknownFieldsSize(total_size, &_impl_._cached_size_);
}


void AddResponse::MergeImpl(::google::protobuf::MessageLite& to_msg, const ::google::protobuf::MessageLite& from_msg) {
  auto* const _this = static_cast<AddResponse*>(&to_msg);
  auto& from = static_cast<const AddResponse&>(from_msg);
  // @@protoc_insertion_point(class_specific_merge_from_start:AddResponse)
  ABSL_DCHECK_NE(&from, _this);
  ::uint32_t cached_has_bits = 0;
  (void) cached_has_bits;

  if (from._internal_c() != 0) {
    _this->_impl_.c_ = from._impl_.c_;
  }
  _this->_internal_metadata_.MergeFrom<::google::protobuf::UnknownFieldSet>(from._internal_metadata_);
}

void AddResponse::CopyFrom(const AddResponse& from) {
// @@protoc_insertion_point(class_specific_copy_from_start:AddResponse)
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}


void AddResponse::InternalSwap(AddResponse* PROTOBUF_RESTRICT other) {
  using std::swap;
  _internal_metadata_.InternalSwap(&other->_internal_metadata_);
        swap(_impl_.c_, other->_impl_.c_);
}

::google::protobuf::Metadata AddResponse::GetMetadata() const {
  return ::google::protobuf::Message::GetMetadataImpl(GetClassData()->full());
}
// @@protoc_insertion_point(namespace_scope)
namespace google {
namespace protobuf {
}  // namespace protobuf
}  // namespace google
// @@protoc_insertion_point(global_scope)
PROTOBUF_ATTRIBUTE_INIT_PRIORITY2 static ::std::false_type
    _static_init2_ PROTOBUF_UNUSED =
        (::_pbi::AddDescriptors(&descriptor_table_calculator_2eproto),
         ::std::false_type{});
#include "google/protobuf/port_undef.inc"
