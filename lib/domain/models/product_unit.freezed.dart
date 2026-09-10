// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_unit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductUnit _$ProductUnitFromJson(Map<String, dynamic> json) {
  return _ProductUnit.fromJson(json);
}

/// @nodoc
mixin _$ProductUnit {
  String get unitId => throw _privateConstructorUsedError;
  String get serialNumber => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  ProductCategory get category => throw _privateConstructorUsedError;
  DateTime get manufacturedAt => throw _privateConstructorUsedError;
  String? get modelNumber => throw _privateConstructorUsedError;
  int? get defaultWarrantyMonths => throw _privateConstructorUsedError;
  UnitRegistrationInfo? get registration => throw _privateConstructorUsedError;

  /// Serializes this ProductUnit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductUnit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductUnitCopyWith<ProductUnit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductUnitCopyWith<$Res> {
  factory $ProductUnitCopyWith(
          ProductUnit value, $Res Function(ProductUnit) then) =
      _$ProductUnitCopyWithImpl<$Res, ProductUnit>;
  @useResult
  $Res call(
      {String unitId,
      String serialNumber,
      String productId,
      String productName,
      ProductCategory category,
      DateTime manufacturedAt,
      String? modelNumber,
      int? defaultWarrantyMonths,
      UnitRegistrationInfo? registration});

  $UnitRegistrationInfoCopyWith<$Res>? get registration;
}

/// @nodoc
class _$ProductUnitCopyWithImpl<$Res, $Val extends ProductUnit>
    implements $ProductUnitCopyWith<$Res> {
  _$ProductUnitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductUnit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unitId = null,
    Object? serialNumber = null,
    Object? productId = null,
    Object? productName = null,
    Object? category = null,
    Object? manufacturedAt = null,
    Object? modelNumber = freezed,
    Object? defaultWarrantyMonths = freezed,
    Object? registration = freezed,
  }) {
    return _then(_value.copyWith(
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      serialNumber: null == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ProductCategory,
      manufacturedAt: null == manufacturedAt
          ? _value.manufacturedAt
          : manufacturedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      modelNumber: freezed == modelNumber
          ? _value.modelNumber
          : modelNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultWarrantyMonths: freezed == defaultWarrantyMonths
          ? _value.defaultWarrantyMonths
          : defaultWarrantyMonths // ignore: cast_nullable_to_non_nullable
              as int?,
      registration: freezed == registration
          ? _value.registration
          : registration // ignore: cast_nullable_to_non_nullable
              as UnitRegistrationInfo?,
    ) as $Val);
  }

  /// Create a copy of ProductUnit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UnitRegistrationInfoCopyWith<$Res>? get registration {
    if (_value.registration == null) {
      return null;
    }

    return $UnitRegistrationInfoCopyWith<$Res>(_value.registration!, (value) {
      return _then(_value.copyWith(registration: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductUnitImplCopyWith<$Res>
    implements $ProductUnitCopyWith<$Res> {
  factory _$$ProductUnitImplCopyWith(
          _$ProductUnitImpl value, $Res Function(_$ProductUnitImpl) then) =
      __$$ProductUnitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String unitId,
      String serialNumber,
      String productId,
      String productName,
      ProductCategory category,
      DateTime manufacturedAt,
      String? modelNumber,
      int? defaultWarrantyMonths,
      UnitRegistrationInfo? registration});

  @override
  $UnitRegistrationInfoCopyWith<$Res>? get registration;
}

/// @nodoc
class __$$ProductUnitImplCopyWithImpl<$Res>
    extends _$ProductUnitCopyWithImpl<$Res, _$ProductUnitImpl>
    implements _$$ProductUnitImplCopyWith<$Res> {
  __$$ProductUnitImplCopyWithImpl(
      _$ProductUnitImpl _value, $Res Function(_$ProductUnitImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductUnit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unitId = null,
    Object? serialNumber = null,
    Object? productId = null,
    Object? productName = null,
    Object? category = null,
    Object? manufacturedAt = null,
    Object? modelNumber = freezed,
    Object? defaultWarrantyMonths = freezed,
    Object? registration = freezed,
  }) {
    return _then(_$ProductUnitImpl(
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      serialNumber: null == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ProductCategory,
      manufacturedAt: null == manufacturedAt
          ? _value.manufacturedAt
          : manufacturedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      modelNumber: freezed == modelNumber
          ? _value.modelNumber
          : modelNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultWarrantyMonths: freezed == defaultWarrantyMonths
          ? _value.defaultWarrantyMonths
          : defaultWarrantyMonths // ignore: cast_nullable_to_non_nullable
              as int?,
      registration: freezed == registration
          ? _value.registration
          : registration // ignore: cast_nullable_to_non_nullable
              as UnitRegistrationInfo?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductUnitImpl implements _ProductUnit {
  const _$ProductUnitImpl(
      {required this.unitId,
      required this.serialNumber,
      required this.productId,
      required this.productName,
      required this.category,
      required this.manufacturedAt,
      this.modelNumber,
      this.defaultWarrantyMonths,
      this.registration});

  factory _$ProductUnitImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductUnitImplFromJson(json);

  @override
  final String unitId;
  @override
  final String serialNumber;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final ProductCategory category;
  @override
  final DateTime manufacturedAt;
  @override
  final String? modelNumber;
  @override
  final int? defaultWarrantyMonths;
  @override
  final UnitRegistrationInfo? registration;

  @override
  String toString() {
    return 'ProductUnit(unitId: $unitId, serialNumber: $serialNumber, productId: $productId, productName: $productName, category: $category, manufacturedAt: $manufacturedAt, modelNumber: $modelNumber, defaultWarrantyMonths: $defaultWarrantyMonths, registration: $registration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductUnitImpl &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.manufacturedAt, manufacturedAt) ||
                other.manufacturedAt == manufacturedAt) &&
            (identical(other.modelNumber, modelNumber) ||
                other.modelNumber == modelNumber) &&
            (identical(other.defaultWarrantyMonths, defaultWarrantyMonths) ||
                other.defaultWarrantyMonths == defaultWarrantyMonths) &&
            (identical(other.registration, registration) ||
                other.registration == registration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      unitId,
      serialNumber,
      productId,
      productName,
      category,
      manufacturedAt,
      modelNumber,
      defaultWarrantyMonths,
      registration);

  /// Create a copy of ProductUnit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductUnitImplCopyWith<_$ProductUnitImpl> get copyWith =>
      __$$ProductUnitImplCopyWithImpl<_$ProductUnitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductUnitImplToJson(
      this,
    );
  }
}

abstract class _ProductUnit implements ProductUnit {
  const factory _ProductUnit(
      {required final String unitId,
      required final String serialNumber,
      required final String productId,
      required final String productName,
      required final ProductCategory category,
      required final DateTime manufacturedAt,
      final String? modelNumber,
      final int? defaultWarrantyMonths,
      final UnitRegistrationInfo? registration}) = _$ProductUnitImpl;

  factory _ProductUnit.fromJson(Map<String, dynamic> json) =
      _$ProductUnitImpl.fromJson;

  @override
  String get unitId;
  @override
  String get serialNumber;
  @override
  String get productId;
  @override
  String get productName;
  @override
  ProductCategory get category;
  @override
  DateTime get manufacturedAt;
  @override
  String? get modelNumber;
  @override
  int? get defaultWarrantyMonths;
  @override
  UnitRegistrationInfo? get registration;

  /// Create a copy of ProductUnit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductUnitImplCopyWith<_$ProductUnitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UnitRegistrationInfo _$UnitRegistrationInfoFromJson(Map<String, dynamic> json) {
  return _UnitRegistrationInfo.fromJson(json);
}

/// @nodoc
mixin _$UnitRegistrationInfo {
  String get id => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get customerPhone => throw _privateConstructorUsedError;
  DateTime get purchaseDate => throw _privateConstructorUsedError;
  DateTime get installationDate => throw _privateConstructorUsedError;
  DateTime get warrantyStartDate => throw _privateConstructorUsedError;
  int get warrantyMonths => throw _privateConstructorUsedError;
  DateTime get warrantyEndDate => throw _privateConstructorUsedError;
  String? get customerCity => throw _privateConstructorUsedError;
  String? get customerAddress => throw _privateConstructorUsedError;
  String? get invoiceNumber => throw _privateConstructorUsedError;
  String? get registeredBy => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this UnitRegistrationInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UnitRegistrationInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UnitRegistrationInfoCopyWith<UnitRegistrationInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnitRegistrationInfoCopyWith<$Res> {
  factory $UnitRegistrationInfoCopyWith(UnitRegistrationInfo value,
          $Res Function(UnitRegistrationInfo) then) =
      _$UnitRegistrationInfoCopyWithImpl<$Res, UnitRegistrationInfo>;
  @useResult
  $Res call(
      {String id,
      String customerName,
      String customerPhone,
      DateTime purchaseDate,
      DateTime installationDate,
      DateTime warrantyStartDate,
      int warrantyMonths,
      DateTime warrantyEndDate,
      String? customerCity,
      String? customerAddress,
      String? invoiceNumber,
      String? registeredBy,
      DateTime? createdAt});
}

/// @nodoc
class _$UnitRegistrationInfoCopyWithImpl<$Res,
        $Val extends UnitRegistrationInfo>
    implements $UnitRegistrationInfoCopyWith<$Res> {
  _$UnitRegistrationInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UnitRegistrationInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? customerPhone = null,
    Object? purchaseDate = null,
    Object? installationDate = null,
    Object? warrantyStartDate = null,
    Object? warrantyMonths = null,
    Object? warrantyEndDate = null,
    Object? customerCity = freezed,
    Object? customerAddress = freezed,
    Object? invoiceNumber = freezed,
    Object? registeredBy = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: null == customerPhone
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      purchaseDate: null == purchaseDate
          ? _value.purchaseDate
          : purchaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      installationDate: null == installationDate
          ? _value.installationDate
          : installationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      warrantyStartDate: null == warrantyStartDate
          ? _value.warrantyStartDate
          : warrantyStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      warrantyMonths: null == warrantyMonths
          ? _value.warrantyMonths
          : warrantyMonths // ignore: cast_nullable_to_non_nullable
              as int,
      warrantyEndDate: null == warrantyEndDate
          ? _value.warrantyEndDate
          : warrantyEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      customerCity: freezed == customerCity
          ? _value.customerCity
          : customerCity // ignore: cast_nullable_to_non_nullable
              as String?,
      customerAddress: freezed == customerAddress
          ? _value.customerAddress
          : customerAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      invoiceNumber: freezed == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      registeredBy: freezed == registeredBy
          ? _value.registeredBy
          : registeredBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UnitRegistrationInfoImplCopyWith<$Res>
    implements $UnitRegistrationInfoCopyWith<$Res> {
  factory _$$UnitRegistrationInfoImplCopyWith(_$UnitRegistrationInfoImpl value,
          $Res Function(_$UnitRegistrationInfoImpl) then) =
      __$$UnitRegistrationInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String customerName,
      String customerPhone,
      DateTime purchaseDate,
      DateTime installationDate,
      DateTime warrantyStartDate,
      int warrantyMonths,
      DateTime warrantyEndDate,
      String? customerCity,
      String? customerAddress,
      String? invoiceNumber,
      String? registeredBy,
      DateTime? createdAt});
}

/// @nodoc
class __$$UnitRegistrationInfoImplCopyWithImpl<$Res>
    extends _$UnitRegistrationInfoCopyWithImpl<$Res, _$UnitRegistrationInfoImpl>
    implements _$$UnitRegistrationInfoImplCopyWith<$Res> {
  __$$UnitRegistrationInfoImplCopyWithImpl(_$UnitRegistrationInfoImpl _value,
      $Res Function(_$UnitRegistrationInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of UnitRegistrationInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? customerPhone = null,
    Object? purchaseDate = null,
    Object? installationDate = null,
    Object? warrantyStartDate = null,
    Object? warrantyMonths = null,
    Object? warrantyEndDate = null,
    Object? customerCity = freezed,
    Object? customerAddress = freezed,
    Object? invoiceNumber = freezed,
    Object? registeredBy = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$UnitRegistrationInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: null == customerPhone
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      purchaseDate: null == purchaseDate
          ? _value.purchaseDate
          : purchaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      installationDate: null == installationDate
          ? _value.installationDate
          : installationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      warrantyStartDate: null == warrantyStartDate
          ? _value.warrantyStartDate
          : warrantyStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      warrantyMonths: null == warrantyMonths
          ? _value.warrantyMonths
          : warrantyMonths // ignore: cast_nullable_to_non_nullable
              as int,
      warrantyEndDate: null == warrantyEndDate
          ? _value.warrantyEndDate
          : warrantyEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      customerCity: freezed == customerCity
          ? _value.customerCity
          : customerCity // ignore: cast_nullable_to_non_nullable
              as String?,
      customerAddress: freezed == customerAddress
          ? _value.customerAddress
          : customerAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      invoiceNumber: freezed == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      registeredBy: freezed == registeredBy
          ? _value.registeredBy
          : registeredBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UnitRegistrationInfoImpl extends _UnitRegistrationInfo {
  const _$UnitRegistrationInfoImpl(
      {required this.id,
      required this.customerName,
      required this.customerPhone,
      required this.purchaseDate,
      required this.installationDate,
      required this.warrantyStartDate,
      required this.warrantyMonths,
      required this.warrantyEndDate,
      this.customerCity,
      this.customerAddress,
      this.invoiceNumber,
      this.registeredBy,
      this.createdAt})
      : super._();

  factory _$UnitRegistrationInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnitRegistrationInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String customerName;
  @override
  final String customerPhone;
  @override
  final DateTime purchaseDate;
  @override
  final DateTime installationDate;
  @override
  final DateTime warrantyStartDate;
  @override
  final int warrantyMonths;
  @override
  final DateTime warrantyEndDate;
  @override
  final String? customerCity;
  @override
  final String? customerAddress;
  @override
  final String? invoiceNumber;
  @override
  final String? registeredBy;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'UnitRegistrationInfo(id: $id, customerName: $customerName, customerPhone: $customerPhone, purchaseDate: $purchaseDate, installationDate: $installationDate, warrantyStartDate: $warrantyStartDate, warrantyMonths: $warrantyMonths, warrantyEndDate: $warrantyEndDate, customerCity: $customerCity, customerAddress: $customerAddress, invoiceNumber: $invoiceNumber, registeredBy: $registeredBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnitRegistrationInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.installationDate, installationDate) ||
                other.installationDate == installationDate) &&
            (identical(other.warrantyStartDate, warrantyStartDate) ||
                other.warrantyStartDate == warrantyStartDate) &&
            (identical(other.warrantyMonths, warrantyMonths) ||
                other.warrantyMonths == warrantyMonths) &&
            (identical(other.warrantyEndDate, warrantyEndDate) ||
                other.warrantyEndDate == warrantyEndDate) &&
            (identical(other.customerCity, customerCity) ||
                other.customerCity == customerCity) &&
            (identical(other.customerAddress, customerAddress) ||
                other.customerAddress == customerAddress) &&
            (identical(other.invoiceNumber, invoiceNumber) ||
                other.invoiceNumber == invoiceNumber) &&
            (identical(other.registeredBy, registeredBy) ||
                other.registeredBy == registeredBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      customerName,
      customerPhone,
      purchaseDate,
      installationDate,
      warrantyStartDate,
      warrantyMonths,
      warrantyEndDate,
      customerCity,
      customerAddress,
      invoiceNumber,
      registeredBy,
      createdAt);

  /// Create a copy of UnitRegistrationInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnitRegistrationInfoImplCopyWith<_$UnitRegistrationInfoImpl>
      get copyWith =>
          __$$UnitRegistrationInfoImplCopyWithImpl<_$UnitRegistrationInfoImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UnitRegistrationInfoImplToJson(
      this,
    );
  }
}

abstract class _UnitRegistrationInfo extends UnitRegistrationInfo {
  const factory _UnitRegistrationInfo(
      {required final String id,
      required final String customerName,
      required final String customerPhone,
      required final DateTime purchaseDate,
      required final DateTime installationDate,
      required final DateTime warrantyStartDate,
      required final int warrantyMonths,
      required final DateTime warrantyEndDate,
      final String? customerCity,
      final String? customerAddress,
      final String? invoiceNumber,
      final String? registeredBy,
      final DateTime? createdAt}) = _$UnitRegistrationInfoImpl;
  const _UnitRegistrationInfo._() : super._();

  factory _UnitRegistrationInfo.fromJson(Map<String, dynamic> json) =
      _$UnitRegistrationInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get customerName;
  @override
  String get customerPhone;
  @override
  DateTime get purchaseDate;
  @override
  DateTime get installationDate;
  @override
  DateTime get warrantyStartDate;
  @override
  int get warrantyMonths;
  @override
  DateTime get warrantyEndDate;
  @override
  String? get customerCity;
  @override
  String? get customerAddress;
  @override
  String? get invoiceNumber;
  @override
  String? get registeredBy;
  @override
  DateTime? get createdAt;

  /// Create a copy of UnitRegistrationInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnitRegistrationInfoImplCopyWith<_$UnitRegistrationInfoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
