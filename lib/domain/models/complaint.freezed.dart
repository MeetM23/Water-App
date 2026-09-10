// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complaint.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Complaint _$ComplaintFromJson(Map<String, dynamic> json) {
  return _Complaint.fromJson(json);
}

/// @nodoc
mixin _$Complaint {
  String get id => throw _privateConstructorUsedError;
  String get ticketNumber => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  ComplaintCategory get category => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  ComplaintPriority get priority => throw _privateConstructorUsedError;
  ComplaintStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get productId => throw _privateConstructorUsedError;
  String? get referenceNumber => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  Profile? get userProfile => throw _privateConstructorUsedError;
  CatalogProduct? get product => throw _privateConstructorUsedError;
  List<ComplaintMessage> get messages => throw _privateConstructorUsedError;
  List<ComplaintAttachment> get attachments =>
      throw _privateConstructorUsedError;

  /// Serializes this Complaint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Complaint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComplaintCopyWith<Complaint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComplaintCopyWith<$Res> {
  factory $ComplaintCopyWith(Complaint value, $Res Function(Complaint) then) =
      _$ComplaintCopyWithImpl<$Res, Complaint>;
  @useResult
  $Res call(
      {String id,
      String ticketNumber,
      String userId,
      String subject,
      ComplaintCategory category,
      String description,
      ComplaintPriority priority,
      ComplaintStatus status,
      DateTime createdAt,
      DateTime updatedAt,
      String? productId,
      String? referenceNumber,
      DateTime? resolvedAt,
      Profile? userProfile,
      CatalogProduct? product,
      List<ComplaintMessage> messages,
      List<ComplaintAttachment> attachments});

  $ProfileCopyWith<$Res>? get userProfile;
  $CatalogProductCopyWith<$Res>? get product;
}

/// @nodoc
class _$ComplaintCopyWithImpl<$Res, $Val extends Complaint>
    implements $ComplaintCopyWith<$Res> {
  _$ComplaintCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Complaint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ticketNumber = null,
    Object? userId = null,
    Object? subject = null,
    Object? category = null,
    Object? description = null,
    Object? priority = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? productId = freezed,
    Object? referenceNumber = freezed,
    Object? resolvedAt = freezed,
    Object? userProfile = freezed,
    Object? product = freezed,
    Object? messages = null,
    Object? attachments = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ticketNumber: null == ticketNumber
          ? _value.ticketNumber
          : ticketNumber // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ComplaintCategory,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as ComplaintPriority,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ComplaintStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceNumber: freezed == referenceNumber
          ? _value.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userProfile: freezed == userProfile
          ? _value.userProfile
          : userProfile // ignore: cast_nullable_to_non_nullable
              as Profile?,
      product: freezed == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as CatalogProduct?,
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ComplaintMessage>,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<ComplaintAttachment>,
    ) as $Val);
  }

  /// Create a copy of Complaint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileCopyWith<$Res>? get userProfile {
    if (_value.userProfile == null) {
      return null;
    }

    return $ProfileCopyWith<$Res>(_value.userProfile!, (value) {
      return _then(_value.copyWith(userProfile: value) as $Val);
    });
  }

  /// Create a copy of Complaint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CatalogProductCopyWith<$Res>? get product {
    if (_value.product == null) {
      return null;
    }

    return $CatalogProductCopyWith<$Res>(_value.product!, (value) {
      return _then(_value.copyWith(product: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ComplaintImplCopyWith<$Res>
    implements $ComplaintCopyWith<$Res> {
  factory _$$ComplaintImplCopyWith(
          _$ComplaintImpl value, $Res Function(_$ComplaintImpl) then) =
      __$$ComplaintImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String ticketNumber,
      String userId,
      String subject,
      ComplaintCategory category,
      String description,
      ComplaintPriority priority,
      ComplaintStatus status,
      DateTime createdAt,
      DateTime updatedAt,
      String? productId,
      String? referenceNumber,
      DateTime? resolvedAt,
      Profile? userProfile,
      CatalogProduct? product,
      List<ComplaintMessage> messages,
      List<ComplaintAttachment> attachments});

  @override
  $ProfileCopyWith<$Res>? get userProfile;
  @override
  $CatalogProductCopyWith<$Res>? get product;
}

/// @nodoc
class __$$ComplaintImplCopyWithImpl<$Res>
    extends _$ComplaintCopyWithImpl<$Res, _$ComplaintImpl>
    implements _$$ComplaintImplCopyWith<$Res> {
  __$$ComplaintImplCopyWithImpl(
      _$ComplaintImpl _value, $Res Function(_$ComplaintImpl) _then)
      : super(_value, _then);

  /// Create a copy of Complaint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ticketNumber = null,
    Object? userId = null,
    Object? subject = null,
    Object? category = null,
    Object? description = null,
    Object? priority = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? productId = freezed,
    Object? referenceNumber = freezed,
    Object? resolvedAt = freezed,
    Object? userProfile = freezed,
    Object? product = freezed,
    Object? messages = null,
    Object? attachments = null,
  }) {
    return _then(_$ComplaintImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ticketNumber: null == ticketNumber
          ? _value.ticketNumber
          : ticketNumber // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ComplaintCategory,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as ComplaintPriority,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ComplaintStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceNumber: freezed == referenceNumber
          ? _value.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userProfile: freezed == userProfile
          ? _value.userProfile
          : userProfile // ignore: cast_nullable_to_non_nullable
              as Profile?,
      product: freezed == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as CatalogProduct?,
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ComplaintMessage>,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<ComplaintAttachment>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ComplaintImpl extends _Complaint {
  const _$ComplaintImpl(
      {required this.id,
      required this.ticketNumber,
      required this.userId,
      required this.subject,
      required this.category,
      required this.description,
      required this.priority,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      this.productId,
      this.referenceNumber,
      this.resolvedAt,
      this.userProfile,
      this.product,
      final List<ComplaintMessage> messages = const <ComplaintMessage>[],
      final List<ComplaintAttachment> attachments =
          const <ComplaintAttachment>[]})
      : _messages = messages,
        _attachments = attachments,
        super._();

  factory _$ComplaintImpl.fromJson(Map<String, dynamic> json) =>
      _$$ComplaintImplFromJson(json);

  @override
  final String id;
  @override
  final String ticketNumber;
  @override
  final String userId;
  @override
  final String subject;
  @override
  final ComplaintCategory category;
  @override
  final String description;
  @override
  final ComplaintPriority priority;
  @override
  final ComplaintStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? productId;
  @override
  final String? referenceNumber;
  @override
  final DateTime? resolvedAt;
  @override
  final Profile? userProfile;
  @override
  final CatalogProduct? product;
  final List<ComplaintMessage> _messages;
  @override
  @JsonKey()
  List<ComplaintMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  final List<ComplaintAttachment> _attachments;
  @override
  @JsonKey()
  List<ComplaintAttachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  String toString() {
    return 'Complaint(id: $id, ticketNumber: $ticketNumber, userId: $userId, subject: $subject, category: $category, description: $description, priority: $priority, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, productId: $productId, referenceNumber: $referenceNumber, resolvedAt: $resolvedAt, userProfile: $userProfile, product: $product, messages: $messages, attachments: $attachments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComplaintImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ticketNumber, ticketNumber) ||
                other.ticketNumber == ticketNumber) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.userProfile, userProfile) ||
                other.userProfile == userProfile) &&
            (identical(other.product, product) || other.product == product) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      ticketNumber,
      userId,
      subject,
      category,
      description,
      priority,
      status,
      createdAt,
      updatedAt,
      productId,
      referenceNumber,
      resolvedAt,
      userProfile,
      product,
      const DeepCollectionEquality().hash(_messages),
      const DeepCollectionEquality().hash(_attachments));

  /// Create a copy of Complaint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComplaintImplCopyWith<_$ComplaintImpl> get copyWith =>
      __$$ComplaintImplCopyWithImpl<_$ComplaintImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ComplaintImplToJson(
      this,
    );
  }
}

abstract class _Complaint extends Complaint {
  const factory _Complaint(
      {required final String id,
      required final String ticketNumber,
      required final String userId,
      required final String subject,
      required final ComplaintCategory category,
      required final String description,
      required final ComplaintPriority priority,
      required final ComplaintStatus status,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String? productId,
      final String? referenceNumber,
      final DateTime? resolvedAt,
      final Profile? userProfile,
      final CatalogProduct? product,
      final List<ComplaintMessage> messages,
      final List<ComplaintAttachment> attachments}) = _$ComplaintImpl;
  const _Complaint._() : super._();

  factory _Complaint.fromJson(Map<String, dynamic> json) =
      _$ComplaintImpl.fromJson;

  @override
  String get id;
  @override
  String get ticketNumber;
  @override
  String get userId;
  @override
  String get subject;
  @override
  ComplaintCategory get category;
  @override
  String get description;
  @override
  ComplaintPriority get priority;
  @override
  ComplaintStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get productId;
  @override
  String? get referenceNumber;
  @override
  DateTime? get resolvedAt;
  @override
  Profile? get userProfile;
  @override
  CatalogProduct? get product;
  @override
  List<ComplaintMessage> get messages;
  @override
  List<ComplaintAttachment> get attachments;

  /// Create a copy of Complaint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComplaintImplCopyWith<_$ComplaintImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
