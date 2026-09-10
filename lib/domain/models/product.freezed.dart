// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Product _$ProductFromJson(Map<String, dynamic> json) {
  return _Product.fromJson(json);
}

/// @nodoc
mixin _$Product {
  String get id => throw _privateConstructorUsedError;
  String get productCode => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  ProductCategory get category => throw _privateConstructorUsedError;
  double get wholesalePrice => throw _privateConstructorUsedError;
  double get retailPrice => throw _privateConstructorUsedError;
  bool get inStock => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  Map<String, dynamic> get specifications => throw _privateConstructorUsedError;
  String? get modelNumber => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get capacity => throw _privateConstructorUsedError;
  double? get mrp => throw _privateConstructorUsedError;
  int? get warrantyMonths => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call(
      {String id,
      String productCode,
      String name,
      ProductCategory category,
      double wholesalePrice,
      double retailPrice,
      bool inStock,
      bool isActive,
      DateTime createdAt,
      DateTime updatedAt,
      Map<String, dynamic> specifications,
      String? modelNumber,
      String? description,
      String? capacity,
      double? mrp,
      int? warrantyMonths,
      String? createdBy});
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productCode = null,
    Object? name = null,
    Object? category = null,
    Object? wholesalePrice = null,
    Object? retailPrice = null,
    Object? inStock = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? specifications = null,
    Object? modelNumber = freezed,
    Object? description = freezed,
    Object? capacity = freezed,
    Object? mrp = freezed,
    Object? warrantyMonths = freezed,
    Object? createdBy = freezed,
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
      wholesalePrice: null == wholesalePrice
          ? _value.wholesalePrice
          : wholesalePrice // ignore: cast_nullable_to_non_nullable
              as double,
      retailPrice: null == retailPrice
          ? _value.retailPrice
          : retailPrice // ignore: cast_nullable_to_non_nullable
              as double,
      inStock: null == inStock
          ? _value.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
          _$ProductImpl value, $Res Function(_$ProductImpl) then) =
      __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String productCode,
      String name,
      ProductCategory category,
      double wholesalePrice,
      double retailPrice,
      bool inStock,
      bool isActive,
      DateTime createdAt,
      DateTime updatedAt,
      Map<String, dynamic> specifications,
      String? modelNumber,
      String? description,
      String? capacity,
      double? mrp,
      int? warrantyMonths,
      String? createdBy});
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
      _$ProductImpl _value, $Res Function(_$ProductImpl) _then)
      : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productCode = null,
    Object? name = null,
    Object? category = null,
    Object? wholesalePrice = null,
    Object? retailPrice = null,
    Object? inStock = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? specifications = null,
    Object? modelNumber = freezed,
    Object? description = freezed,
    Object? capacity = freezed,
    Object? mrp = freezed,
    Object? warrantyMonths = freezed,
    Object? createdBy = freezed,
  }) {
    return _then(_$ProductImpl(
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
      wholesalePrice: null == wholesalePrice
          ? _value.wholesalePrice
          : wholesalePrice // ignore: cast_nullable_to_non_nullable
              as double,
      retailPrice: null == retailPrice
          ? _value.retailPrice
          : retailPrice // ignore: cast_nullable_to_non_nullable
              as double,
      inStock: null == inStock
          ? _value.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductImpl extends _Product {
  const _$ProductImpl(
      {required this.id,
      required this.productCode,
      required this.name,
      required this.category,
      required this.wholesalePrice,
      required this.retailPrice,
      required this.inStock,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt,
      final Map<String, dynamic> specifications = const <String, dynamic>{},
      this.modelNumber,
      this.description,
      this.capacity,
      this.mrp,
      this.warrantyMonths,
      this.createdBy})
      : _specifications = specifications,
        super._();

  factory _$ProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImplFromJson(json);

  @override
  final String id;
  @override
  final String productCode;
  @override
  final String name;
  @override
  final ProductCategory category;
  @override
  final double wholesalePrice;
  @override
  final double retailPrice;
  @override
  final bool inStock;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
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
  final String? createdBy;

  @override
  String toString() {
    return 'Product(id: $id, productCode: $productCode, name: $name, category: $category, wholesalePrice: $wholesalePrice, retailPrice: $retailPrice, inStock: $inStock, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, specifications: $specifications, modelNumber: $modelNumber, description: $description, capacity: $capacity, mrp: $mrp, warrantyMonths: $warrantyMonths, createdBy: $createdBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productCode, productCode) ||
                other.productCode == productCode) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.wholesalePrice, wholesalePrice) ||
                other.wholesalePrice == wholesalePrice) &&
            (identical(other.retailPrice, retailPrice) ||
                other.retailPrice == retailPrice) &&
            (identical(other.inStock, inStock) || other.inStock == inStock) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
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
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      productCode,
      name,
      category,
      wholesalePrice,
      retailPrice,
      inStock,
      isActive,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_specifications),
      modelNumber,
      description,
      capacity,
      mrp,
      warrantyMonths,
      createdBy);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImplToJson(
      this,
    );
  }
}

abstract class _Product extends Product {
  const factory _Product(
      {required final String id,
      required final String productCode,
      required final String name,
      required final ProductCategory category,
      required final double wholesalePrice,
      required final double retailPrice,
      required final bool inStock,
      required final bool isActive,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final Map<String, dynamic> specifications,
      final String? modelNumber,
      final String? description,
      final String? capacity,
      final double? mrp,
      final int? warrantyMonths,
      final String? createdBy}) = _$ProductImpl;
  const _Product._() : super._();

  factory _Product.fromJson(Map<String, dynamic> json) = _$ProductImpl.fromJson;

  @override
  String get id;
  @override
  String get productCode;
  @override
  String get name;
  @override
  ProductCategory get category;
  @override
  double get wholesalePrice;
  @override
  double get retailPrice;
  @override
  bool get inStock;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
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
  String? get createdBy;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
