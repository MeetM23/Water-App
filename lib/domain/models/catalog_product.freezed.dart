// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CatalogProduct _$CatalogProductFromJson(Map<String, dynamic> json) {
  return _CatalogProduct.fromJson(json);
}

/// @nodoc
mixin _$CatalogProduct {
  String get id => throw _privateConstructorUsedError;
  String get productCode => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  ProductCategory get category => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  bool get inStock => throw _privateConstructorUsedError;
  Map<String, dynamic> get specifications => throw _privateConstructorUsedError;
  String? get modelNumber => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get capacity => throw _privateConstructorUsedError;
  double? get mrp => throw _privateConstructorUsedError;
  int? get warrantyMonths => throw _privateConstructorUsedError;
  String? get primaryImagePath => throw _privateConstructorUsedError;

  /// Serializes this CatalogProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatalogProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatalogProductCopyWith<CatalogProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatalogProductCopyWith<$Res> {
  factory $CatalogProductCopyWith(
          CatalogProduct value, $Res Function(CatalogProduct) then) =
      _$CatalogProductCopyWithImpl<$Res, CatalogProduct>;
  @useResult
  $Res call(
      {String id,
      String productCode,
      String name,
      ProductCategory category,
      double price,
      bool inStock,
      Map<String, dynamic> specifications,
      String? modelNumber,
      String? description,
      String? capacity,
      double? mrp,
      int? warrantyMonths,
      String? primaryImagePath});
}

/// @nodoc
class _$CatalogProductCopyWithImpl<$Res, $Val extends CatalogProduct>
    implements $CatalogProductCopyWith<$Res> {
  _$CatalogProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatalogProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productCode = null,
    Object? name = null,
    Object? category = null,
    Object? price = null,
    Object? inStock = null,
    Object? specifications = null,
    Object? modelNumber = freezed,
    Object? description = freezed,
    Object? capacity = freezed,
    Object? mrp = freezed,
    Object? warrantyMonths = freezed,
    Object? primaryImagePath = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productCode: null == productCode
          ? _value.productCode
          : productCode // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ProductCategory,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      inStock: null == inStock
          ? _value.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      specifications: null == specifications
          ? _value.specifications
          : specifications // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      modelNumber: freezed == modelNumber
          ? _value.modelNumber
          : modelNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as String?,
      mrp: freezed == mrp
          ? _value.mrp
          : mrp // ignore: cast_nullable_to_non_nullable
              as double?,
      warrantyMonths: freezed == warrantyMonths
          ? _value.warrantyMonths
          : warrantyMonths // ignore: cast_nullable_to_non_nullable
              as int?,
      primaryImagePath: freezed == primaryImagePath
          ? _value.primaryImagePath
          : primaryImagePath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CatalogProductImplCopyWith<$Res>
    implements $CatalogProductCopyWith<$Res> {
  factory _$$CatalogProductImplCopyWith(_$CatalogProductImpl value,
          $Res Function(_$CatalogProductImpl) then) =
      __$$CatalogProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String productCode,
      String name,
      ProductCategory category,
      double price,
      bool inStock,
      Map<String, dynamic> specifications,
      String? modelNumber,
      String? description,
      String? capacity,
      double? mrp,
      int? warrantyMonths,
      String? primaryImagePath});
}

/// @nodoc
class __$$CatalogProductImplCopyWithImpl<$Res>
    extends _$CatalogProductCopyWithImpl<$Res, _$CatalogProductImpl>
    implements _$$CatalogProductImplCopyWith<$Res> {
  __$$CatalogProductImplCopyWithImpl(
      _$CatalogProductImpl _value, $Res Function(_$CatalogProductImpl) _then)
      : super(_value, _then);

  /// Create a copy of CatalogProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productCode = null,
    Object? name = null,
    Object? category = null,
    Object? price = null,
    Object? inStock = null,
    Object? specifications = null,
    Object? modelNumber = freezed,
    Object? description = freezed,
    Object? capacity = freezed,
    Object? mrp = freezed,
    Object? warrantyMonths = freezed,
    Object? primaryImagePath = freezed,
  }) {
    return _then(_$CatalogProductImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productCode: null == productCode
          ? _value.productCode
          : productCode // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ProductCategory,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      inStock: null == inStock
          ? _value.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      specifications: null == specifications
          ? _value._specifications
          : specifications // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      modelNumber: freezed == modelNumber
          ? _value.modelNumber
          : modelNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as String?,
      mrp: freezed == mrp
          ? _value.mrp
          : mrp // ignore: cast_nullable_to_non_nullable
              as double?,
      warrantyMonths: freezed == warrantyMonths
          ? _value.warrantyMonths
          : warrantyMonths // ignore: cast_nullable_to_non_nullable
              as int?,
      primaryImagePath: freezed == primaryImagePath
          ? _value.primaryImagePath
          : primaryImagePath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CatalogProductImpl extends _CatalogProduct {
  const _$CatalogProductImpl(
      {required this.id,
      required this.productCode,
      required this.name,
      required this.category,
      required this.price,
      required this.inStock,
      final Map<String, dynamic> specifications = const <String, dynamic>{},
      this.modelNumber,
      this.description,
      this.capacity,
      this.mrp,
      this.warrantyMonths,
      this.primaryImagePath})
      : _specifications = specifications,
        super._();

  factory _$CatalogProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatalogProductImplFromJson(json);

  @override
  final String id;
  @override
  final String productCode;
  @override
  final String name;
  @override
  final ProductCategory category;
  @override
  final double price;
  @override
  final bool inStock;
  final Map<String, dynamic> _specifications;
  @override
  @JsonKey()
  Map<String, dynamic> get specifications {
    if (_specifications is EqualUnmodifiableMapView) return _specifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_specifications);
  }

  @override
  final String? modelNumber;
  @override
  final String? description;
  @override
  final String? capacity;
  @override
  final double? mrp;
  @override
  final int? warrantyMonths;
  @override
  final String? primaryImagePath;

  @override
  String toString() {
    return 'CatalogProduct(id: $id, productCode: $productCode, name: $name, category: $category, price: $price, inStock: $inStock, specifications: $specifications, modelNumber: $modelNumber, description: $description, capacity: $capacity, mrp: $mrp, warrantyMonths: $warrantyMonths, primaryImagePath: $primaryImagePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatalogProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productCode, productCode) ||
                other.productCode == productCode) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.inStock, inStock) || other.inStock == inStock) &&
            const DeepCollectionEquality()
                .equals(other._specifications, _specifications) &&
            (identical(other.modelNumber, modelNumber) ||
                other.modelNumber == modelNumber) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.mrp, mrp) || other.mrp == mrp) &&
            (identical(other.warrantyMonths, warrantyMonths) ||
                other.warrantyMonths == warrantyMonths) &&
            (identical(other.primaryImagePath, primaryImagePath) ||
                other.primaryImagePath == primaryImagePath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      productCode,
      name,
      category,
      price,
      inStock,
      const DeepCollectionEquality().hash(_specifications),
      modelNumber,
      description,
      capacity,
      mrp,
      warrantyMonths,
      primaryImagePath);

  /// Create a copy of CatalogProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatalogProductImplCopyWith<_$CatalogProductImpl> get copyWith =>
      __$$CatalogProductImplCopyWithImpl<_$CatalogProductImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CatalogProductImplToJson(
      this,
    );
  }
}

abstract class _CatalogProduct extends CatalogProduct {
  const factory _CatalogProduct(
      {required final String id,
      required final String productCode,
      required final String name,
      required final ProductCategory category,
      required final double price,
      required final bool inStock,
      final Map<String, dynamic> specifications,
      final String? modelNumber,
      final String? description,
      final String? capacity,
      final double? mrp,
      final int? warrantyMonths,
      final String? primaryImagePath}) = _$CatalogProductImpl;
  const _CatalogProduct._() : super._();

  factory _CatalogProduct.fromJson(Map<String, dynamic> json) =
      _$CatalogProductImpl.fromJson;

  @override
  String get id;
  @override
  String get productCode;
  @override
  String get name;
  @override
  ProductCategory get category;
  @override
  double get price;
  @override
  bool get inStock;
  @override
  Map<String, dynamic> get specifications;
  @override
  String? get modelNumber;
  @override
  String? get description;
  @override
  String? get capacity;
  @override
  double? get mrp;
  @override
  int? get warrantyMonths;
  @override
  String? get primaryImagePath;

  /// Create a copy of CatalogProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatalogProductImplCopyWith<_$CatalogProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
