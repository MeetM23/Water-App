// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complaint_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ComplaintMessage _$ComplaintMessageFromJson(Map<String, dynamic> json) {
  return _ComplaintMessage.fromJson(json);
}

/// @nodoc
mixin _$ComplaintMessage {
  String get id => throw _privateConstructorUsedError;
  String get complaintId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isInternal => throw _privateConstructorUsedError;
  Profile? get senderProfile => throw _privateConstructorUsedError;

  /// Serializes this ComplaintMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ComplaintMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComplaintMessageCopyWith<ComplaintMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComplaintMessageCopyWith<$Res> {
  factory $ComplaintMessageCopyWith(
          ComplaintMessage value, $Res Function(ComplaintMessage) then) =
      _$ComplaintMessageCopyWithImpl<$Res, ComplaintMessage>;
  @useResult
  $Res call(
      {String id,
      String complaintId,
      String senderId,
      String message,
      DateTime createdAt,
      bool isInternal,
      Profile? senderProfile});

  $ProfileCopyWith<$Res>? get senderProfile;
}

/// @nodoc
class _$ComplaintMessageCopyWithImpl<$Res, $Val extends ComplaintMessage>
    implements $ComplaintMessageCopyWith<$Res> {
  _$ComplaintMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ComplaintMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? complaintId = null,
    Object? senderId = null,
    Object? message = null,
    Object? createdAt = null,
    Object? isInternal = null,
    Object? senderProfile = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      complaintId: null == complaintId
          ? _value.complaintId
          : complaintId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isInternal: null == isInternal
          ? _value.isInternal
          : isInternal // ignore: cast_nullable_to_non_nullable
              as bool,
      senderProfile: freezed == senderProfile
          ? _value.senderProfile
          : senderProfile // ignore: cast_nullable_to_non_nullable
              as Profile?,
    ) as $Val);
  }

  /// Create a copy of ComplaintMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileCopyWith<$Res>? get senderProfile {
    if (_value.senderProfile == null) {
      return null;
    }

    return $ProfileCopyWith<$Res>(_value.senderProfile!, (value) {
      return _then(_value.copyWith(senderProfile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ComplaintMessageImplCopyWith<$Res>
    implements $ComplaintMessageCopyWith<$Res> {
  factory _$$ComplaintMessageImplCopyWith(_$ComplaintMessageImpl value,
          $Res Function(_$ComplaintMessageImpl) then) =
      __$$ComplaintMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String complaintId,
      String senderId,
      String message,
      DateTime createdAt,
      bool isInternal,
      Profile? senderProfile});

  @override
  $ProfileCopyWith<$Res>? get senderProfile;
}

/// @nodoc
class __$$ComplaintMessageImplCopyWithImpl<$Res>
    extends _$ComplaintMessageCopyWithImpl<$Res, _$ComplaintMessageImpl>
    implements _$$ComplaintMessageImplCopyWith<$Res> {
  __$$ComplaintMessageImplCopyWithImpl(_$ComplaintMessageImpl _value,
      $Res Function(_$ComplaintMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComplaintMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? complaintId = null,
    Object? senderId = null,
    Object? message = null,
    Object? createdAt = null,
    Object? isInternal = null,
    Object? senderProfile = freezed,
  }) {
    return _then(_$ComplaintMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      complaintId: null == complaintId
          ? _value.complaintId
          : complaintId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isInternal: null == isInternal
          ? _value.isInternal
          : isInternal // ignore: cast_nullable_to_non_nullable
              as bool,
      senderProfile: freezed == senderProfile
          ? _value.senderProfile
          : senderProfile // ignore: cast_nullable_to_non_nullable
              as Profile?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ComplaintMessageImpl extends _ComplaintMessage {
  const _$ComplaintMessageImpl(
      {required this.id,
      required this.complaintId,
      required this.senderId,
      required this.message,
      required this.createdAt,
      this.isInternal = false,
      this.senderProfile})
      : super._();

  factory _$ComplaintMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ComplaintMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String complaintId;
  @override
  final String senderId;
  @override
  final String message;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isInternal;
  @override
  final Profile? senderProfile;

  @override
  String toString() {
    return 'ComplaintMessage(id: $id, complaintId: $complaintId, senderId: $senderId, message: $message, createdAt: $createdAt, isInternal: $isInternal, senderProfile: $senderProfile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComplaintMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.complaintId, complaintId) ||
                other.complaintId == complaintId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isInternal, isInternal) ||
                other.isInternal == isInternal) &&
            (identical(other.senderProfile, senderProfile) ||
                other.senderProfile == senderProfile));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, complaintId, senderId,
      message, createdAt, isInternal, senderProfile);

  /// Create a copy of ComplaintMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComplaintMessageImplCopyWith<_$ComplaintMessageImpl> get copyWith =>
      __$$ComplaintMessageImplCopyWithImpl<_$ComplaintMessageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ComplaintMessageImplToJson(
      this,
    );
  }
}

abstract class _ComplaintMessage extends ComplaintMessage {
  const factory _ComplaintMessage(
      {required final String id,
      required final String complaintId,
      required final String senderId,
      required final String message,
      required final DateTime createdAt,
      final bool isInternal,
      final Profile? senderProfile}) = _$ComplaintMessageImpl;
  const _ComplaintMessage._() : super._();

  factory _ComplaintMessage.fromJson(Map<String, dynamic> json) =
      _$ComplaintMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get complaintId;
  @override
  String get senderId;
  @override
  String get message;
  @override
  DateTime get createdAt;
  @override
  bool get isInternal;
  @override
  Profile? get senderProfile;

  /// Create a copy of ComplaintMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComplaintMessageImplCopyWith<_$ComplaintMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
