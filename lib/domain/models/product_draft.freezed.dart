// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DraftImage {
  String get id => throw _privateConstructorUsedError;
  String get storagePath => throw _privateConstructorUsedError;
  bool get isPrimary => throw _privateConstructorUsedError;
  bool get isTemporary => throw _privateConstructorUsedError;
  double get uploadProgress => throw _privateConstructorUsedError;
  String? get localPath => throw _privateConstructorUsedError;
  String? get failureMessage => throw _privateConstructorUsedError;

  /// Create a copy of DraftImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DraftImageCopyWith<DraftImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DraftImageCopyWith<$Res> {
  factory $DraftImageCopyWith(
          DraftImage value, $Res Function(DraftImage) then) =
      _$DraftImageCopyWithImpl<$Res, DraftImage>;
  @useResult
  $Res call(
      {String id,
      String storagePath,
      bool isPrimary,
      bool isTemporary,
      double uploadProgress,
      String? localPath,
      String? failureMessage});
}

/// @nodoc
class _$DraftImageCopyWithImpl<$Res, $Val extends DraftImage>
    implements $DraftImageCopyWith<$Res> {
  _$DraftImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DraftImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storagePath = null,
    Object? isPrimary = null,
    Object? isTemporary = null,
    Object? uploadProgress = null,
    Object? localPath = freezed,
    Object? failureMessage = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storagePath: null == storagePath
          ? _value.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String,
      isPrimary: null == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool,
      isTemporary: null == isTemporary
          ? _value.isTemporary
          : isTemporary // ignore: cast_nullable_to_non_nullable
              as bool,
      uploadProgress: null == uploadProgress
          ? _value.uploadProgress
          : uploadProgress // ignore: cast_nullable_to_non_nullable
              as double,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      failureMessage: freezed == failureMessage
          ? _value.failureMessage
          : failureMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DraftImageImplCopyWith<$Res>
    implements $DraftImageCopyWith<$Res> {
  factory _$$DraftImageImplCopyWith(
          _$DraftImageImpl value, $Res Function(_$DraftImageImpl) then) =
      __$$DraftImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String storagePath,
      bool isPrimary,
      bool isTemporary,
      double uploadProgress,
      String? localPath,
      String? failureMessage});
}

/// @nodoc
class __$$DraftImageImplCopyWithImpl<$Res>
    extends _$DraftImageCopyWithImpl<$Res, _$DraftImageImpl>
    implements _$$DraftImageImplCopyWith<$Res> {
  __$$DraftImageImplCopyWithImpl(
      _$DraftImageImpl _value, $Res Function(_$DraftImageImpl) _then)
      : super(_value, _then);

  /// Create a copy of DraftImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storagePath = null,
    Object? isPrimary = null,
    Object? isTemporary = null,
    Object? uploadProgress = null,
    Object? localPath = freezed,
    Object? failureMessage = freezed,
  }) {
    return _then(_$DraftImageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storagePath: null == storagePath
          ? _value.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String,
      isPrimary: null == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool,
      isTemporary: null == isTemporary
          ? _value.isTemporary
          : isTemporary // ignore: cast_nullable_to_non_nullable
              as bool,
      uploadProgress: null == uploadProgress
          ? _value.uploadProgress
          : uploadProgress // ignore: cast_nullable_to_non_nullable
              as double,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      failureMessage: freezed == failureMessage
          ? _value.failureMessage
          : failureMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$DraftImageImpl extends _DraftImage {
  const _$DraftImageImpl(
      {required this.id,
      required this.storagePath,
      required this.isPrimary,
      this.isTemporary = false,
      this.uploadProgress = 1.0,
      this.localPath,
      this.failureMessage})
      : super._();

  @override
  final String id;
  @override
  final String storagePath;
  @override
  final bool isPrimary;
  @override
  @JsonKey()
  final bool isTemporary;
  @override
  @JsonKey()
  final double uploadProgress;
  @override
  final String? localPath;
  @override
  final String? failureMessage;

  @override
  String toString() {
    return 'DraftImage(id: $id, storagePath: $storagePath, isPrimary: $isPrimary, isTemporary: $isTemporary, uploadProgress: $uploadProgress, localPath: $localPath, failureMessage: $failureMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DraftImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
            (identical(other.isTemporary, isTemporary) ||
                other.isTemporary == isTemporary) &&
            (identical(other.uploadProgress, uploadProgress) ||
                other.uploadProgress == uploadProgress) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath) &&
            (identical(other.failureMessage, failureMessage) ||
                other.failureMessage == failureMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, storagePath, isPrimary,
      isTemporary, uploadProgress, localPath, failureMessage);

  /// Create a copy of DraftImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DraftImageImplCopyWith<_$DraftImageImpl> get copyWith =>
      __$$DraftImageImplCopyWithImpl<_$DraftImageImpl>(this, _$identity);
}

abstract class _DraftImage extends DraftImage {
  const factory _DraftImage(
      {required final String id,
      required final String storagePath,
      required final bool isPrimary,
      final bool isTemporary,
      final double uploadProgress,
      final String? localPath,
      final String? failureMessage}) = _$DraftImageImpl;
  const _DraftImage._() : super._();

  @override
  String get id;
  @override
  String get storagePath;
  @override
  bool get isPrimary;
  @override
  bool get isTemporary;
  @override
  double get uploadProgress;
  @override
  String? get localPath;
  @override
  String? get failureMessage;

  /// Create a copy of DraftImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DraftImageImplCopyWith<_$DraftImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SpecificationEntry {
  String get id => throw _privateConstructorUsedError;
  String get key => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;

  /// Create a copy of SpecificationEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpecificationEntryCopyWith<SpecificationEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpecificationEntryCopyWith<$Res> {
  factory $SpecificationEntryCopyWith(
          SpecificationEntry value, $Res Function(SpecificationEntry) then) =
      _$SpecificationEntryCopyWithImpl<$Res, SpecificationEntry>;
  @useResult
  $Res call({String id, String key, String value});
}

/// @nodoc
class _$SpecificationEntryCopyWithImpl<$Res, $Val extends SpecificationEntry>
    implements $SpecificationEntryCopyWith<$Res> {
  _$SpecificationEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpecificationEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? key = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpecificationEntryImplCopyWith<$Res>
    implements $SpecificationEntryCopyWith<$Res> {
  factory _$$SpecificationEntryImplCopyWith(_$SpecificationEntryImpl value,
          $Res Function(_$SpecificationEntryImpl) then) =
      __$$SpecificationEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String key, String value});
}

/// @nodoc
class __$$SpecificationEntryImplCopyWithImpl<$Res>
    extends _$SpecificationEntryCopyWithImpl<$Res, _$SpecificationEntryImpl>
    implements _$$SpecificationEntryImplCopyWith<$Res> {
  __$$SpecificationEntryImplCopyWithImpl(_$SpecificationEntryImpl _value,
      $Res Function(_$SpecificationEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpecificationEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? key = null,
    Object? value = null,
  }) {
    return _then(_$SpecificationEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SpecificationEntryImpl extends _SpecificationEntry {
  const _$SpecificationEntryImpl(
      {required this.id, this.key = '', this.value = ''})
      : super._();

  @override
  final String id;
  @override
  @JsonKey()
  final String key;
  @override
  @JsonKey()
  final String value;

  @override
  String toString() {
    return 'SpecificationEntry(id: $id, key: $key, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpecificationEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, key, value);

  /// Create a copy of SpecificationEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpecificationEntryImplCopyWith<_$SpecificationEntryImpl> get copyWith =>
      __$$SpecificationEntryImplCopyWithImpl<_$SpecificationEntryImpl>(
          this, _$identity);
}

abstract class _SpecificationEntry extends SpecificationEntry {
  const factory _SpecificationEntry(
      {required final String id,
      final String key,
      final String value}) = _$SpecificationEntryImpl;
  const _SpecificationEntry._() : super._();

  @override
  String get id;
  @override
  String get key;
  @override
  String get value;

  /// Create a copy of SpecificationEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpecificationEntryImplCopyWith<_$SpecificationEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProductDraft {
  String get name => throw _privateConstructorUsedError;
  String get modelNumber => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get capacity => throw _privateConstructorUsedError;
  ProductCategory? get category => throw _privateConstructorUsedError;
  String get mrp => throw _privateConstructorUsedError;
  String get wholesalePrice => throw _privateConstructorUsedError;
  String get retailPrice => throw _privateConstructorUsedError;
  int get warrantyMonths => throw _privateConstructorUsedError;
  String get stockQuantity => throw _privateConstructorUsedError;
  bool get inStock => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  List<SpecificationEntry> get specifications =>
      throw _privateConstructorUsedError;
  List<DraftImage> get images => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;
  String? get productCode => throw _privateConstructorUsedError;

  /// Create a copy of ProductDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductDraftCopyWith<ProductDraft> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductDraftCopyWith<$Res> {
  factory $ProductDraftCopyWith(
          ProductDraft value, $Res Function(ProductDraft) then) =
      _$ProductDraftCopyWithImpl<$Res, ProductDraft>;
  @useResult
  $Res call(
      {String name,
      String modelNumber,
      String description,
      String capacity,
      ProductCategory? category,
      String mrp,
      String wholesalePrice,
      String retailPrice,
      int warrantyMonths,
      String stockQuantity,
      bool inStock,
      bool isActive,
      List<SpecificationEntry> specifications,
      List<DraftImage> images,
      String? id,
      String? productCode});
}

/// @nodoc
class _$ProductDraftCopyWithImpl<$Res, $Val extends ProductDraft>
    implements $ProductDraftCopyWith<$Res> {
  _$ProductDraftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? modelNumber = null,
    Object? description = null,
    Object? capacity = null,
    Object? category = freezed,
    Object? mrp = null,
    Object? wholesalePrice = null,
    Object? retailPrice = null,
    Object? warrantyMonths = null,
    Object? stockQuantity = null,
    Object? inStock = null,
    Object? isActive = null,
    Object? specifications = null,
    Object? images = null,
    Object? id = freezed,
    Object? productCode = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      modelNumber: null == modelNumber
          ? _value.modelNumber
          : modelNumber // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      capacity: null == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ProductCategory?,
      mrp: null == mrp
          ? _value.mrp
          : mrp // ignore: cast_nullable_to_non_nullable
              as String,
      wholesalePrice: null == wholesalePrice
          ? _value.wholesalePrice
          : wholesalePrice // ignore: cast_nullable_to_non_nullable
              as String,
      retailPrice: null == retailPrice
          ? _value.retailPrice
          : retailPrice // ignore: cast_nullable_to_non_nullable
              as String,
      warrantyMonths: null == warrantyMonths
          ? _value.warrantyMonths
          : warrantyMonths // ignore: cast_nullable_to_non_nullable
              as int,
      stockQuantity: null == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as String,
      inStock: null == inStock
          ? _value.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      specifications: null == specifications
          ? _value.specifications
          : specifications // ignore: cast_nullable_to_non_nullable
              as List<SpecificationEntry>,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<DraftImage>,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      productCode: freezed == productCode
          ? _value.productCode
          : productCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductDraftImplCopyWith<$Res>
    implements $ProductDraftCopyWith<$Res> {
  factory _$$ProductDraftImplCopyWith(
          _$ProductDraftImpl value, $Res Function(_$ProductDraftImpl) then) =
      __$$ProductDraftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String modelNumber,
      String description,
      String capacity,
      ProductCategory? category,
      String mrp,
      String wholesalePrice,
      String retailPrice,
      int warrantyMonths,
      String stockQuantity,
      bool inStock,
      bool isActive,
      List<SpecificationEntry> specifications,
      List<DraftImage> images,
      String? id,
      String? productCode});
}

/// @nodoc
class __$$ProductDraftImplCopyWithImpl<$Res>
    extends _$ProductDraftCopyWithImpl<$Res, _$ProductDraftImpl>
    implements _$$ProductDraftImplCopyWith<$Res> {
  __$$ProductDraftImplCopyWithImpl(
      _$ProductDraftImpl _value, $Res Function(_$ProductDraftImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? modelNumber = null,
    Object? description = null,
    Object? capacity = null,
    Object? category = freezed,
    Object? mrp = null,
    Object? wholesalePrice = null,
    Object? retailPrice = null,
    Object? warrantyMonths = null,
    Object? stockQuantity = null,
    Object? inStock = null,
    Object? isActive = null,
    Object? specifications = null,
    Object? images = null,
    Object? id = freezed,
    Object? productCode = freezed,
  }) {
    return _then(_$ProductDraftImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      modelNumber: null == modelNumber
          ? _value.modelNumber
          : modelNumber // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      capacity: null == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ProductCategory?,
      mrp: null == mrp
          ? _value.mrp
          : mrp // ignore: cast_nullable_to_non_nullable
              as String,
      wholesalePrice: null == wholesalePrice
          ? _value.wholesalePrice
          : wholesalePrice // ignore: cast_nullable_to_non_nullable
              as String,
      retailPrice: null == retailPrice
          ? _value.retailPrice
          : retailPrice // ignore: cast_nullable_to_non_nullable
              as String,
      warrantyMonths: null == warrantyMonths
          ? _value.warrantyMonths
          : warrantyMonths // ignore: cast_nullable_to_non_nullable
              as int,
      stockQuantity: null == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as String,
      inStock: null == inStock
          ? _value.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      specifications: null == specifications
          ? _value._specifications
          : specifications // ignore: cast_nullable_to_non_nullable
              as List<SpecificationEntry>,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<DraftImage>,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      productCode: freezed == productCode
          ? _value.productCode
          : productCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ProductDraftImpl extends _ProductDraft {
  const _$ProductDraftImpl(
      {this.name = '',
      this.modelNumber = '',
      this.description = '',
      this.capacity = '',
      this.category,
      this.mrp = '',
      this.wholesalePrice = '',
      this.retailPrice = '',
      this.warrantyMonths = 12,
      this.stockQuantity = '1',
      this.inStock = true,
      this.isActive = true,
      final List<SpecificationEntry> specifications =
          const <SpecificationEntry>[],
      final List<DraftImage> images = const <DraftImage>[],
      this.id,
      this.productCode})
      : _specifications = specifications,
        _images = images,
        super._();

  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String modelNumber;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String capacity;
  @override
  final ProductCategory? category;
  @override
  @JsonKey()
  final String mrp;
  @override
  @JsonKey()
  final String wholesalePrice;
  @override
  @JsonKey()
  final String retailPrice;
  @override
  @JsonKey()
  final int warrantyMonths;
  @override
  @JsonKey()
  final String stockQuantity;
  @override
  @JsonKey()
  final bool inStock;
  @override
  @JsonKey()
  final bool isActive;
  final List<SpecificationEntry> _specifications;
  @override
  @JsonKey()
  List<SpecificationEntry> get specifications {
    if (_specifications is EqualUnmodifiableListView) return _specifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_specifications);
  }

  final List<DraftImage> _images;
  @override
  @JsonKey()
  List<DraftImage> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final String? id;
  @override
  final String? productCode;

  @override
  String toString() {
    return 'ProductDraft(name: $name, modelNumber: $modelNumber, description: $description, capacity: $capacity, category: $category, mrp: $mrp, wholesalePrice: $wholesalePrice, retailPrice: $retailPrice, warrantyMonths: $warrantyMonths, stockQuantity: $stockQuantity, inStock: $inStock, isActive: $isActive, specifications: $specifications, images: $images, id: $id, productCode: $productCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductDraftImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.modelNumber, modelNumber) ||
                other.modelNumber == modelNumber) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.mrp, mrp) || other.mrp == mrp) &&
            (identical(other.wholesalePrice, wholesalePrice) ||
                other.wholesalePrice == wholesalePrice) &&
            (identical(other.retailPrice, retailPrice) ||
                other.retailPrice == retailPrice) &&
            (identical(other.warrantyMonths, warrantyMonths) ||
                other.warrantyMonths == warrantyMonths) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.inStock, inStock) || other.inStock == inStock) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality()
                .equals(other._specifications, _specifications) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productCode, productCode) ||
                other.productCode == productCode));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      modelNumber,
      description,
      capacity,
      category,
      mrp,
      wholesalePrice,
      retailPrice,
      warrantyMonths,
      stockQuantity,
      inStock,
      isActive,
      const DeepCollectionEquality().hash(_specifications),
      const DeepCollectionEquality().hash(_images),
      id,
      productCode);

  /// Create a copy of ProductDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductDraftImplCopyWith<_$ProductDraftImpl> get copyWith =>
      __$$ProductDraftImplCopyWithImpl<_$ProductDraftImpl>(this, _$identity);
}

abstract class _ProductDraft extends ProductDraft {
  const factory _ProductDraft(
      {final String name,
      final String modelNumber,
      final String description,
      final String capacity,
      final ProductCategory? category,
      final String mrp,
      final String wholesalePrice,
      final String retailPrice,
      final int warrantyMonths,
      final String stockQuantity,
      final bool inStock,
      final bool isActive,
      final List<SpecificationEntry> specifications,
      final List<DraftImage> images,
      final String? id,
      final String? productCode}) = _$ProductDraftImpl;
  const _ProductDraft._() : super._();

  @override
  String get name;
  @override
  String get modelNumber;
  @override
  String get description;
  @override
  String get capacity;
  @override
  ProductCategory? get category;
  @override
  String get mrp;
  @override
  String get wholesalePrice;
  @override
  String get retailPrice;
  @override
  int get warrantyMonths;
  @override
  String get stockQuantity;
  @override
  bool get inStock;
  @override
  bool get isActive;
  @override
  List<SpecificationEntry> get specifications;
  @override
  List<DraftImage> get images;
  @override
  String? get id;
  @override
  String? get productCode;

  /// Create a copy of ProductDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductDraftImplCopyWith<_$ProductDraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
