// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'warranty_claim.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WarrantyClaim _$WarrantyClaimFromJson(Map<String, dynamic> json) {
  return _WarrantyClaim.fromJson(json);
}

/// @nodoc
mixin _$WarrantyClaim {
  String get id => throw _privateConstructorUsedError;
  String get claimNumber => throw _privateConstructorUsedError;
  String get unitId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get claimType => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get contactPhone => throw _privateConstructorUsedError;
  WarrantyClaimStatus get status => throw _privateConstructorUsedError;
  String? get adminNotes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get userFullName => throw _privateConstructorUsedError;
  String? get userCompany => throw _privateConstructorUsedError;
  String? get userPhone => throw _privateConstructorUsedError;
  String? get userRole => throw _privateConstructorUsedError;
  String? get serialNumber => throw _privateConstructorUsedError;
  String? get productId => throw _privateConstructorUsedError;
  String? get productName => throw _privateConstructorUsedError;
  String? get modelNumber => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;

  /// Serializes this WarrantyClaim to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WarrantyClaim
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WarrantyClaimCopyWith<WarrantyClaim> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WarrantyClaimCopyWith<$Res> {
  factory $WarrantyClaimCopyWith(
          WarrantyClaim value, $Res Function(WarrantyClaim) then) =
      _$WarrantyClaimCopyWithImpl<$Res, WarrantyClaim>;
  @useResult
  $Res call(
      {String id,
      String claimNumber,
      String unitId,
      String userId,
      String claimType,
      String description,
      String contactPhone,
      WarrantyClaimStatus status,
      String? adminNotes,
      DateTime createdAt,
      DateTime updatedAt,
      String? userFullName,
      String? userCompany,
      String? userPhone,
      String? userRole,
      String? serialNumber,
      String? productId,
      String? productName,
      String? modelNumber,
      String? category});
}

/// @nodoc
class _$WarrantyClaimCopyWithImpl<$Res, $Val extends WarrantyClaim>
    implements $WarrantyClaimCopyWith<$Res> {
  _$WarrantyClaimCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WarrantyClaim
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? claimNumber = null,
    Object? unitId = null,
    Object? userId = null,
    Object? claimType = null,
    Object? description = null,
    Object? contactPhone = null,
    Object? status = null,
    Object? adminNotes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userFullName = freezed,
    Object? userCompany = freezed,
    Object? userPhone = freezed,
    Object? userRole = freezed,
    Object? serialNumber = freezed,
    Object? productId = freezed,
    Object? productName = freezed,
    Object? modelNumber = freezed,
    Object? category = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      claimNumber: null == claimNumber
          ? _value.claimNumber
          : claimNumber // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      claimType: null == claimType
          ? _value.claimType
          : claimType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      contactPhone: null == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as WarrantyClaimStatus,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userFullName: freezed == userFullName
          ? _value.userFullName
          : userFullName // ignore: cast_nullable_to_non_nullable
              as String?,
      userCompany: freezed == userCompany
          ? _value.userCompany
          : userCompany // ignore: cast_nullable_to_non_nullable
              as String?,
      userPhone: freezed == userPhone
          ? _value.userPhone
          : userPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      userRole: freezed == userRole
          ? _value.userRole
          : userRole // ignore: cast_nullable_to_non_nullable
              as String?,
      serialNumber: freezed == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      productName: freezed == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String?,
      modelNumber: freezed == modelNumber
          ? _value.modelNumber
          : modelNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WarrantyClaimImplCopyWith<$Res>
    implements $WarrantyClaimCopyWith<$Res> {
  factory _$$WarrantyClaimImplCopyWith(
          _$WarrantyClaimImpl value, $Res Function(_$WarrantyClaimImpl) then) =
      __$$WarrantyClaimImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String claimNumber,
      String unitId,
      String userId,
      String claimType,
      String description,
      String contactPhone,
      WarrantyClaimStatus status,
      String? adminNotes,
      DateTime createdAt,
      DateTime updatedAt,
      String? userFullName,
      String? userCompany,
      String? userPhone,
      String? userRole,
      String? serialNumber,
      String? productId,
      String? productName,
      String? modelNumber,
      String? category});
}

/// @nodoc
class __$$WarrantyClaimImplCopyWithImpl<$Res>
    extends _$WarrantyClaimCopyWithImpl<$Res, _$WarrantyClaimImpl>
    implements _$$WarrantyClaimImplCopyWith<$Res> {
  __$$WarrantyClaimImplCopyWithImpl(
      _$WarrantyClaimImpl _value, $Res Function(_$WarrantyClaimImpl) _then)
      : super(_value, _then);

  /// Create a copy of WarrantyClaim
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? claimNumber = null,
    Object? unitId = null,
    Object? userId = null,
    Object? claimType = null,
    Object? description = null,
    Object? contactPhone = null,
    Object? status = null,
    Object? adminNotes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userFullName = freezed,
    Object? userCompany = freezed,
    Object? userPhone = freezed,
    Object? userRole = freezed,
    Object? serialNumber = freezed,
    Object? productId = freezed,
    Object? productName = freezed,
    Object? modelNumber = freezed,
    Object? category = freezed,
  }) {
    return _then(_$WarrantyClaimImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      claimNumber: null == claimNumber
          ? _value.claimNumber
          : claimNumber // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      claimType: null == claimType
          ? _value.claimType
          : claimType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      contactPhone: null == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as WarrantyClaimStatus,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userFullName: freezed == userFullName
          ? _value.userFullName
          : userFullName // ignore: cast_nullable_to_non_nullable
              as String?,
      userCompany: freezed == userCompany
          ? _value.userCompany
          : userCompany // ignore: cast_nullable_to_non_nullable
              as String?,
      userPhone: freezed == userPhone
          ? _value.userPhone
          : userPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      userRole: freezed == userRole
          ? _value.userRole
          : userRole // ignore: cast_nullable_to_non_nullable
              as String?,
      serialNumber: freezed == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      productName: freezed == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String?,
      modelNumber: freezed == modelNumber
          ? _value.modelNumber
          : modelNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WarrantyClaimImpl extends _WarrantyClaim {
  const _$WarrantyClaimImpl(
      {required this.id,
      required this.claimNumber,
      required this.unitId,
      required this.userId,
      required this.claimType,
      required this.description,
      required this.contactPhone,
      this.status = WarrantyClaimStatus.pending,
      this.adminNotes,
      required this.createdAt,
      required this.updatedAt,
      this.userFullName,
      this.userCompany,
      this.userPhone,
      this.userRole,
      this.serialNumber,
      this.productId,
      this.productName,
      this.modelNumber,
      this.category})
      : super._();

  factory _$WarrantyClaimImpl.fromJson(Map<String, dynamic> json) =>
      _$$WarrantyClaimImplFromJson(json);

  @override
  final String id;
  @override
  final String claimNumber;
  @override
  final String unitId;
  @override
  final String userId;
  @override
  final String claimType;
  @override
  final String description;
  @override
  final String contactPhone;
  @override
  @JsonKey()
  final WarrantyClaimStatus status;
  @override
  final String? adminNotes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? userFullName;
  @override
  final String? userCompany;
  @override
  final String? userPhone;
  @override
  final String? userRole;
  @override
  final String? serialNumber;
  @override
  final String? productId;
  @override
  final String? productName;
  @override
  final String? modelNumber;
  @override
  final String? category;

  @override
  String toString() {
    return 'WarrantyClaim(id: $id, claimNumber: $claimNumber, unitId: $unitId, userId: $userId, claimType: $claimType, description: $description, contactPhone: $contactPhone, status: $status, adminNotes: $adminNotes, createdAt: $createdAt, updatedAt: $updatedAt, userFullName: $userFullName, userCompany: $userCompany, userPhone: $userPhone, userRole: $userRole, serialNumber: $serialNumber, productId: $productId, productName: $productName, modelNumber: $modelNumber, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WarrantyClaimImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.claimNumber, claimNumber) ||
                other.claimNumber == claimNumber) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.claimType, claimType) ||
                other.claimType == claimType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.adminNotes, adminNotes) ||
                other.adminNotes == adminNotes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userFullName, userFullName) ||
                other.userFullName == userFullName) &&
            (identical(other.userCompany, userCompany) ||
                other.userCompany == userCompany) &&
            (identical(other.userPhone, userPhone) ||
                other.userPhone == userPhone) &&
            (identical(other.userRole, userRole) ||
                other.userRole == userRole) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.modelNumber, modelNumber) ||
                other.modelNumber == modelNumber) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        claimNumber,
        unitId,
        userId,
        claimType,
        description,
        contactPhone,
        status,
        adminNotes,
        createdAt,
        updatedAt,
        userFullName,
        userCompany,
        userPhone,
        userRole,
        serialNumber,
        productId,
        productName,
        modelNumber,
        category
      ]);

  /// Create a copy of WarrantyClaim
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WarrantyClaimImplCopyWith<_$WarrantyClaimImpl> get copyWith =>
      __$$WarrantyClaimImplCopyWithImpl<_$WarrantyClaimImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WarrantyClaimImplToJson(
      this,
    );
  }
}

abstract class _WarrantyClaim extends WarrantyClaim {
  const factory _WarrantyClaim(
      {required final String id,
      required final String claimNumber,
      required final String unitId,
      required final String userId,
      required final String claimType,
      required final String description,
      required final String contactPhone,
      final WarrantyClaimStatus status,
      final String? adminNotes,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String? userFullName,
      final String? userCompany,
      final String? userPhone,
      final String? userRole,
      final String? serialNumber,
      final String? productId,
      final String? productName,
      final String? modelNumber,
      final String? category}) = _$WarrantyClaimImpl;
  const _WarrantyClaim._() : super._();

  factory _WarrantyClaim.fromJson(Map<String, dynamic> json) =
      _$WarrantyClaimImpl.fromJson;

  @override
  String get id;
  @override
  String get claimNumber;
  @override
  String get unitId;
  @override
  String get userId;
  @override
  String get claimType;
  @override
  String get description;
  @override
  String get contactPhone;
  @override
  WarrantyClaimStatus get status;
  @override
  String? get adminNotes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get userFullName;
  @override
  String? get userCompany;
  @override
  String? get userPhone;
  @override
  String? get userRole;
  @override
  String? get serialNumber;
  @override
  String? get productId;
  @override
  String? get productName;
  @override
  String? get modelNumber;
  @override
  String? get category;

  /// Create a copy of WarrantyClaim
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WarrantyClaimImplCopyWith<_$WarrantyClaimImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
