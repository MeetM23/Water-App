// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_lookup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductLookup _$ProductLookupFromJson(Map<String, dynamic> json) {
  return _ProductLookup.fromJson(json);
}

/// @nodoc
mixin _$ProductLookup {
  String get unitId => throw _privateConstructorUsedError;
  String get serialNumber => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  ProductCategory get category => throw _privateConstructorUsedError;
  DateTime get manufacturedAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get modelNumber => throw _privateConstructorUsedError;
  String? get productCode => throw _privateConstructorUsedError;
  int get stockQuantity => throw _privateConstructorUsedError;
  int? get defaultWarrantyMonths => throw _privateConstructorUsedError;
  ProductRegistrationInfo? get registration =>
      throw _privateConstructorUsedError;

  /// Serializes this ProductLookup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductLookup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductLookupCopyWith<ProductLookup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductLookupCopyWith<$Res> {
  factory $ProductLookupCopyWith(
          ProductLookup value, $Res Function(ProductLookup) then) =
      _$ProductLookupCopyWithImpl<$Res, ProductLookup>;
  @useResult
  $Res call(
      {String unitId,
      String serialNumber,
      String productId,
      String productName,
      ProductCategory category,
      DateTime manufacturedAt,
      String status,
      String? modelNumber,
      String? productCode,
      int stockQuantity,
      int? defaultWarrantyMonths,
      ProductRegistrationInfo? registration});

  $ProductRegistrationInfoCopyWith<$Res>? get registration;
}

/// @nodoc
class _$ProductLookupCopyWithImpl<$Res, $Val extends ProductLookup>
    implements $ProductLookupCopyWith<$Res> {
  _$ProductLookupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductLookup
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
    Object? status = null,
    Object? modelNumber = freezed,
    Object? productCode = freezed,
    Object? stockQuantity = null,
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      modelNumber: freezed == modelNumber
          ? _value.modelNumber
          : modelNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      productCode: freezed == productCode
          ? _value.productCode
          : productCode // ignore: cast_nullable_to_non_nullable
              as String?,
      stockQuantity: null == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      defaultWarrantyMonths: freezed == defaultWarrantyMonths
          ? _value.defaultWarrantyMonths
          : defaultWarrantyMonths // ignore: cast_nullable_to_non_nullable
              as int?,
      registration: freezed == registration
          ? _value.registration
          : registration // ignore: cast_nullable_to_non_nullable
              as ProductRegistrationInfo?,
    ) as $Val);
  }

  /// Create a copy of ProductLookup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductRegistrationInfoCopyWith<$Res>? get registration {
    if (_value.registration == null) {
      return null;
    }

    return $ProductRegistrationInfoCopyWith<$Res>(_value.registration!,
        (value) {
      return _then(_value.copyWith(registration: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductLookupImplCopyWith<$Res>
    implements $ProductLookupCopyWith<$Res> {
  factory _$$ProductLookupImplCopyWith(
          _$ProductLookupImpl value, $Res Function(_$ProductLookupImpl) then) =
      __$$ProductLookupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String unitId,
      String serialNumber,
      String productId,
      String productName,
      ProductCategory category,
      DateTime manufacturedAt,
      String status,
      String? modelNumber,
      String? productCode,
      int stockQuantity,
      int? defaultWarrantyMonths,
      ProductRegistrationInfo? registration});

  @override
  $ProductRegistrationInfoCopyWith<$Res>? get registration;
}

/// @nodoc
class __$$ProductLookupImplCopyWithImpl<$Res>
    extends _$ProductLookupCopyWithImpl<$Res, _$ProductLookupImpl>
    implements _$$ProductLookupImplCopyWith<$Res> {
  __$$ProductLookupImplCopyWithImpl(
      _$ProductLookupImpl _value, $Res Function(_$ProductLookupImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductLookup
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
    Object? status = null,
    Object? modelNumber = freezed,
    Object? productCode = freezed,
    Object? stockQuantity = null,
    Object? defaultWarrantyMonths = freezed,
    Object? registration = freezed,
  }) {
    return _then(_$ProductLookupImpl(
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      modelNumber: freezed == modelNumber
          ? _value.modelNumber
          : modelNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      productCode: freezed == productCode
          ? _value.productCode
          : productCode // ignore: cast_nullable_to_non_nullable
              as String?,
      stockQuantity: null == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      defaultWarrantyMonths: freezed == defaultWarrantyMonths
          ? _value.defaultWarrantyMonths
          : defaultWarrantyMonths // ignore: cast_nullable_to_non_nullable
              as int?,
      registration: freezed == registration
          ? _value.registration
          : registration // ignore: cast_nullable_to_non_nullable
              as ProductRegistrationInfo?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductLookupImpl implements _ProductLookup {
  const _$ProductLookupImpl(
      {required this.unitId,
      required this.serialNumber,
      required this.productId,
      required this.productName,
      required this.category,
      required this.manufacturedAt,
      this.status = 'available',
      this.modelNumber,
      this.productCode,
      this.stockQuantity = 0,
      this.defaultWarrantyMonths,
      this.registration});

  factory _$ProductLookupImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductLookupImplFromJson(json);

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
  @JsonKey()
  final String status;
  @override
  final String? modelNumber;
  @override
  final String? productCode;
  @override
  @JsonKey()
  final int stockQuantity;
  @override
  final int? defaultWarrantyMonths;
  @override
  final ProductRegistrationInfo? registration;

  @override
  String toString() {
    return 'ProductLookup(unitId: $unitId, serialNumber: $serialNumber, productId: $productId, productName: $productName, category: $category, manufacturedAt: $manufacturedAt, status: $status, modelNumber: $modelNumber, productCode: $productCode, stockQuantity: $stockQuantity, defaultWarrantyMonths: $defaultWarrantyMonths, registration: $registration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductLookupImpl &&
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
            (identical(other.status, status) || other.status == status) &&
            (identical(other.modelNumber, modelNumber) ||
                other.modelNumber == modelNumber) &&
            (identical(other.productCode, productCode) ||
                other.productCode == productCode) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
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
      status,
      modelNumber,
      productCode,
      stockQuantity,
      defaultWarrantyMonths,
      registration);

  /// Create a copy of ProductLookup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductLookupImplCopyWith<_$ProductLookupImpl> get copyWith =>
      __$$ProductLookupImplCopyWithImpl<_$ProductLookupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductLookupImplToJson(
      this,
    );
  }
}

abstract class _ProductLookup implements ProductLookup {
  const factory _ProductLookup(
      {required final String unitId,
      required final String serialNumber,
      required final String productId,
      required final String productName,
      required final ProductCategory category,
      required final DateTime manufacturedAt,
      final String status,
      final String? modelNumber,
      final String? productCode,
      final int stockQuantity,
      final int? defaultWarrantyMonths,
      final ProductRegistrationInfo? registration}) = _$ProductLookupImpl;

  factory _ProductLookup.fromJson(Map<String, dynamic> json) =
      _$ProductLookupImpl.fromJson;

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
  String get status;
  @override
  String? get modelNumber;
  @override
  String? get productCode;
  @override
  int get stockQuantity;
  @override
  int? get defaultWarrantyMonths;
  @override
  ProductRegistrationInfo? get registration;

  /// Create a copy of ProductLookup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductLookupImplCopyWith<_$ProductLookupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductRegistrationInfo _$ProductRegistrationInfoFromJson(
    Map<String, dynamic> json) {
  return _ProductRegistrationInfo.fromJson(json);
}

/// @nodoc
mixin _$ProductRegistrationInfo {
  String get id => throw _privateConstructorUsedError;
  String? get customerName => throw _privateConstructorUsedError;
  String? get customerPhone => throw _privateConstructorUsedError;
  DateTime get purchaseDate => throw _privateConstructorUsedError;
  DateTime get installationDate => throw _privateConstructorUsedError;
  DateTime get warrantyStartDate => throw _privateConstructorUsedError;
  int get warrantyMonths => throw _privateConstructorUsedError;
  DateTime get warrantyEndDate => throw _privateConstructorUsedError;
  String? get customerCity => throw _privateConstructorUsedError;
  String? get customerAddress => throw _privateConstructorUsedError;
  String? get invoiceNumber => throw _privateConstructorUsedError;
  String? get sellerName => throw _privateConstructorUsedError;
  String? get sellerPhone => throw _privateConstructorUsedError;
  String? get registeredBy => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ProductRegistrationInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductRegistrationInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductRegistrationInfoCopyWith<ProductRegistrationInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductRegistrationInfoCopyWith<$Res> {
  factory $ProductRegistrationInfoCopyWith(ProductRegistrationInfo value,
          $Res Function(ProductRegistrationInfo) then) =
      _$ProductRegistrationInfoCopyWithImpl<$Res, ProductRegistrationInfo>;
  @useResult
  $Res call(
      {String id,
      String? customerName,
      String? customerPhone,
      DateTime purchaseDate,
      DateTime installationDate,
      DateTime warrantyStartDate,
      int warrantyMonths,
      DateTime warrantyEndDate,
      String? customerCity,
      String? customerAddress,
      String? invoiceNumber,
      String? sellerName,
      String? sellerPhone,
      String? registeredBy,
      DateTime? createdAt});
}

/// @nodoc
class _$ProductRegistrationInfoCopyWithImpl<$Res,
        $Val extends ProductRegistrationInfo>
    implements $ProductRegistrationInfoCopyWith<$Res> {
  _$ProductRegistrationInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductRegistrationInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? purchaseDate = null,
    Object? installationDate = null,
    Object? warrantyStartDate = null,
    Object? warrantyMonths = null,
    Object? warrantyEndDate = null,
    Object? customerCity = freezed,
    Object? customerAddress = freezed,
    Object? invoiceNumber = freezed,
    Object? sellerName = freezed,
    Object? sellerPhone = freezed,
    Object? registeredBy = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
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
      sellerName: freezed == sellerName
          ? _value.sellerName
          : sellerName // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerPhone: freezed == sellerPhone
          ? _value.sellerPhone
          : sellerPhone // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ProductRegistrationInfoImplCopyWith<$Res>
    implements $ProductRegistrationInfoCopyWith<$Res> {
  factory _$$ProductRegistrationInfoImplCopyWith(
          _$ProductRegistrationInfoImpl value,
          $Res Function(_$ProductRegistrationInfoImpl) then) =
      __$$ProductRegistrationInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? customerName,
      String? customerPhone,
      DateTime purchaseDate,
      DateTime installationDate,
      DateTime warrantyStartDate,
      int warrantyMonths,
      DateTime warrantyEndDate,
      String? customerCity,
      String? customerAddress,
      String? invoiceNumber,
      String? sellerName,
      String? sellerPhone,
      String? registeredBy,
      DateTime? createdAt});
}

/// @nodoc
class __$$ProductRegistrationInfoImplCopyWithImpl<$Res>
    extends _$ProductRegistrationInfoCopyWithImpl<$Res,
        _$ProductRegistrationInfoImpl>
    implements _$$ProductRegistrationInfoImplCopyWith<$Res> {
  __$$ProductRegistrationInfoImplCopyWithImpl(
      _$ProductRegistrationInfoImpl _value,
      $Res Function(_$ProductRegistrationInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductRegistrationInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? purchaseDate = null,
    Object? installationDate = null,
    Object? warrantyStartDate = null,
    Object? warrantyMonths = null,
    Object? warrantyEndDate = null,
    Object? customerCity = freezed,
    Object? customerAddress = freezed,
    Object? invoiceNumber = freezed,
    Object? sellerName = freezed,
    Object? sellerPhone = freezed,
    Object? registeredBy = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$ProductRegistrationInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
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
      sellerName: freezed == sellerName
          ? _value.sellerName
          : sellerName // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerPhone: freezed == sellerPhone
          ? _value.sellerPhone
          : sellerPhone // ignore: cast_nullable_to_non_nullable
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
class _$ProductRegistrationInfoImpl extends _ProductRegistrationInfo {
  const _$ProductRegistrationInfoImpl(
      {required this.id,
      this.customerName,
      this.customerPhone,
      required this.purchaseDate,
      required this.installationDate,
      required this.warrantyStartDate,
      required this.warrantyMonths,
      required this.warrantyEndDate,
      this.customerCity,
      this.customerAddress,
      this.invoiceNumber,
      this.sellerName,
      this.sellerPhone,
      this.registeredBy,
      this.createdAt})
      : super._();

  factory _$ProductRegistrationInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductRegistrationInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String? customerName;
  @override
  final String? customerPhone;
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
  final String? sellerName;
  @override
  final String? sellerPhone;
  @override
  final String? registeredBy;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ProductRegistrationInfo(id: $id, customerName: $customerName, customerPhone: $customerPhone, purchaseDate: $purchaseDate, installationDate: $installationDate, warrantyStartDate: $warrantyStartDate, warrantyMonths: $warrantyMonths, warrantyEndDate: $warrantyEndDate, customerCity: $customerCity, customerAddress: $customerAddress, invoiceNumber: $invoiceNumber, sellerName: $sellerName, sellerPhone: $sellerPhone, registeredBy: $registeredBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductRegistrationInfoImpl &&
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
            (identical(other.sellerName, sellerName) ||
                other.sellerName == sellerName) &&
            (identical(other.sellerPhone, sellerPhone) ||
                other.sellerPhone == sellerPhone) &&
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
      sellerName,
      sellerPhone,
      registeredBy,
      createdAt);

  /// Create a copy of ProductRegistrationInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductRegistrationInfoImplCopyWith<_$ProductRegistrationInfoImpl>
      get copyWith => __$$ProductRegistrationInfoImplCopyWithImpl<
          _$ProductRegistrationInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductRegistrationInfoImplToJson(
      this,
    );
  }
}

abstract class _ProductRegistrationInfo extends ProductRegistrationInfo {
  const factory _ProductRegistrationInfo(
      {required final String id,
      final String? customerName,
      final String? customerPhone,
      required final DateTime purchaseDate,
      required final DateTime installationDate,
      required final DateTime warrantyStartDate,
      required final int warrantyMonths,
      required final DateTime warrantyEndDate,
      final String? customerCity,
      final String? customerAddress,
      final String? invoiceNumber,
      final String? sellerName,
      final String? sellerPhone,
      final String? registeredBy,
      final DateTime? createdAt}) = _$ProductRegistrationInfoImpl;
  const _ProductRegistrationInfo._() : super._();

  factory _ProductRegistrationInfo.fromJson(Map<String, dynamic> json) =
      _$ProductRegistrationInfoImpl.fromJson;

  @override
  String get id;
  @override
  String? get customerName;
  @override
  String? get customerPhone;
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
  String? get sellerName;
  @override
  String? get sellerPhone;
  @override
  String? get registeredBy;
  @override
  DateTime? get createdAt;

  /// Create a copy of ProductRegistrationInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductRegistrationInfoImplCopyWith<_$ProductRegistrationInfoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
