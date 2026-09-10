// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalogue_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CatalogueSnapshot _$CatalogueSnapshotFromJson(Map<String, dynamic> json) {
  return _CatalogueSnapshot.fromJson(json);
}

/// @nodoc
mixin _$CatalogueSnapshot {
  List<CatalogProduct> get products => throw _privateConstructorUsedError;
  DateTime get fetchedAt => throw _privateConstructorUsedError;

  /// Serializes this CatalogueSnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatalogueSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatalogueSnapshotCopyWith<CatalogueSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatalogueSnapshotCopyWith<$Res> {
  factory $CatalogueSnapshotCopyWith(
          CatalogueSnapshot value, $Res Function(CatalogueSnapshot) then) =
      _$CatalogueSnapshotCopyWithImpl<$Res, CatalogueSnapshot>;
  @useResult
  $Res call({List<CatalogProduct> products, DateTime fetchedAt});
}

/// @nodoc
class _$CatalogueSnapshotCopyWithImpl<$Res, $Val extends CatalogueSnapshot>
    implements $CatalogueSnapshotCopyWith<$Res> {
  _$CatalogueSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatalogueSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? products = null,
    Object? fetchedAt = null,
  }) {
    return _then(_value.copyWith(
      products: null == products
          ? _value.products
          : products // ignore: cast_nullable_to_non_nullable
              as List<CatalogProduct>,
      fetchedAt: null == fetchedAt
          ? _value.fetchedAt
          : fetchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CatalogueSnapshotImplCopyWith<$Res>
    implements $CatalogueSnapshotCopyWith<$Res> {
  factory _$$CatalogueSnapshotImplCopyWith(_$CatalogueSnapshotImpl value,
          $Res Function(_$CatalogueSnapshotImpl) then) =
      __$$CatalogueSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CatalogProduct> products, DateTime fetchedAt});
}

/// @nodoc
class __$$CatalogueSnapshotImplCopyWithImpl<$Res>
    extends _$CatalogueSnapshotCopyWithImpl<$Res, _$CatalogueSnapshotImpl>
    implements _$$CatalogueSnapshotImplCopyWith<$Res> {
  __$$CatalogueSnapshotImplCopyWithImpl(_$CatalogueSnapshotImpl _value,
      $Res Function(_$CatalogueSnapshotImpl) _then)
      : super(_value, _then);

  /// Create a copy of CatalogueSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? products = null,
    Object? fetchedAt = null,
  }) {
    return _then(_$CatalogueSnapshotImpl(
      products: null == products
          ? _value._products
          : products // ignore: cast_nullable_to_non_nullable
              as List<CatalogProduct>,
      fetchedAt: null == fetchedAt
          ? _value.fetchedAt
          : fetchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CatalogueSnapshotImpl extends _CatalogueSnapshot {
  const _$CatalogueSnapshotImpl(
      {required final List<CatalogProduct> products, required this.fetchedAt})
      : _products = products,
        super._();

  factory _$CatalogueSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatalogueSnapshotImplFromJson(json);

  final List<CatalogProduct> _products;
  @override
  List<CatalogProduct> get products {
    if (_products is EqualUnmodifiableListView) return _products;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_products);
  }

  @override
  final DateTime fetchedAt;

  @override
  String toString() {
    return 'CatalogueSnapshot(products: $products, fetchedAt: $fetchedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatalogueSnapshotImpl &&
            const DeepCollectionEquality().equals(other._products, _products) &&
            (identical(other.fetchedAt, fetchedAt) ||
                other.fetchedAt == fetchedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_products), fetchedAt);

  /// Create a copy of CatalogueSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatalogueSnapshotImplCopyWith<_$CatalogueSnapshotImpl> get copyWith =>
      __$$CatalogueSnapshotImplCopyWithImpl<_$CatalogueSnapshotImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CatalogueSnapshotImplToJson(
      this,
    );
  }
}

abstract class _CatalogueSnapshot extends CatalogueSnapshot {
  const factory _CatalogueSnapshot(
      {required final List<CatalogProduct> products,
      required final DateTime fetchedAt}) = _$CatalogueSnapshotImpl;
  const _CatalogueSnapshot._() : super._();

  factory _CatalogueSnapshot.fromJson(Map<String, dynamic> json) =
      _$CatalogueSnapshotImpl.fromJson;

  @override
  List<CatalogProduct> get products;
  @override
  DateTime get fetchedAt;

  /// Create a copy of CatalogueSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatalogueSnapshotImplCopyWith<_$CatalogueSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
