// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complaint_attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ComplaintAttachment _$ComplaintAttachmentFromJson(Map<String, dynamic> json) {
  return _ComplaintAttachment.fromJson(json);
}

/// @nodoc
mixin _$ComplaintAttachment {
  String get id => throw _privateConstructorUsedError;
  String get complaintId => throw _privateConstructorUsedError;
  String get storagePath => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int? get fileSize => throw _privateConstructorUsedError;

  /// Serializes this ComplaintAttachment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ComplaintAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComplaintAttachmentCopyWith<ComplaintAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComplaintAttachmentCopyWith<$Res> {
  factory $ComplaintAttachmentCopyWith(
          ComplaintAttachment value, $Res Function(ComplaintAttachment) then) =
      _$ComplaintAttachmentCopyWithImpl<$Res, ComplaintAttachment>;
  @useResult
  $Res call(
      {String id,
      String complaintId,
      String storagePath,
      String fileName,
      DateTime createdAt,
      int? fileSize});
}

/// @nodoc
class _$ComplaintAttachmentCopyWithImpl<$Res, $Val extends ComplaintAttachment>
    implements $ComplaintAttachmentCopyWith<$Res> {
  _$ComplaintAttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ComplaintAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? complaintId = null,
    Object? storagePath = null,
    Object? fileName = null,
    Object? createdAt = null,
    Object? fileSize = freezed,
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
      storagePath: null == storagePath
          ? _value.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ComplaintAttachmentImplCopyWith<$Res>
    implements $ComplaintAttachmentCopyWith<$Res> {
  factory _$$ComplaintAttachmentImplCopyWith(_$ComplaintAttachmentImpl value,
          $Res Function(_$ComplaintAttachmentImpl) then) =
      __$$ComplaintAttachmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String complaintId,
      String storagePath,
      String fileName,
      DateTime createdAt,
      int? fileSize});
}

/// @nodoc
class __$$ComplaintAttachmentImplCopyWithImpl<$Res>
    extends _$ComplaintAttachmentCopyWithImpl<$Res, _$ComplaintAttachmentImpl>
    implements _$$ComplaintAttachmentImplCopyWith<$Res> {
  __$$ComplaintAttachmentImplCopyWithImpl(_$ComplaintAttachmentImpl _value,
      $Res Function(_$ComplaintAttachmentImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComplaintAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? complaintId = null,
    Object? storagePath = null,
    Object? fileName = null,
    Object? createdAt = null,
    Object? fileSize = freezed,
  }) {
    return _then(_$ComplaintAttachmentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      complaintId: null == complaintId
          ? _value.complaintId
          : complaintId // ignore: cast_nullable_to_non_nullable
              as String,
      storagePath: null == storagePath
          ? _value.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ComplaintAttachmentImpl extends _ComplaintAttachment {
  const _$ComplaintAttachmentImpl(
      {required this.id,
      required this.complaintId,
      required this.storagePath,
      required this.fileName,
      required this.createdAt,
      this.fileSize})
      : super._();

  factory _$ComplaintAttachmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ComplaintAttachmentImplFromJson(json);

  @override
  final String id;
  @override
  final String complaintId;
  @override
  final String storagePath;
  @override
  final String fileName;
  @override
  final DateTime createdAt;
  @override
  final int? fileSize;

  @override
  String toString() {
    return 'ComplaintAttachment(id: $id, complaintId: $complaintId, storagePath: $storagePath, fileName: $fileName, createdAt: $createdAt, fileSize: $fileSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComplaintAttachmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.complaintId, complaintId) ||
                other.complaintId == complaintId) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, complaintId, storagePath, fileName, createdAt, fileSize);

  /// Create a copy of ComplaintAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComplaintAttachmentImplCopyWith<_$ComplaintAttachmentImpl> get copyWith =>
      __$$ComplaintAttachmentImplCopyWithImpl<_$ComplaintAttachmentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ComplaintAttachmentImplToJson(
      this,
    );
  }
}

abstract class _ComplaintAttachment extends ComplaintAttachment {
  const factory _ComplaintAttachment(
      {required final String id,
      required final String complaintId,
      required final String storagePath,
      required final String fileName,
      required final DateTime createdAt,
      final int? fileSize}) = _$ComplaintAttachmentImpl;
  const _ComplaintAttachment._() : super._();

  factory _ComplaintAttachment.fromJson(Map<String, dynamic> json) =
      _$ComplaintAttachmentImpl.fromJson;

  @override
  String get id;
  @override
  String get complaintId;
  @override
  String get storagePath;
  @override
  String get fileName;
  @override
  DateTime get createdAt;
  @override
  int? get fileSize;

  /// Create a copy of ComplaintAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComplaintAttachmentImplCopyWith<_$ComplaintAttachmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
