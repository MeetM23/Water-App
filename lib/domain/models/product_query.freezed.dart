// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProductQuery {
  String get searchTerm => throw _privateConstructorUsedError;
  ProductCategory? get category => throw _privateConstructorUsedError;
  ProductStatusFilter get status => throw _privateConstructorUsedError;
  ProductSort get sort => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;

  /// Create a copy of ProductQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductQueryCopyWith<ProductQuery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductQueryCopyWith<$Res> {
  factory $ProductQueryCopyWith(
          ProductQuery value, $Res Function(ProductQuery) then) =
      _$ProductQueryCopyWithImpl<$Res, ProductQuery>;
  @useResult
  $Res call(
      {String searchTerm,
      ProductCategory? category,
      ProductStatusFilter status,
      ProductSort sort,
      int page,
      int pageSize});
}

/// @nodoc
class _$ProductQueryCopyWithImpl<$Res, $Val extends ProductQuery>
    implements $ProductQueryCopyWith<$Res> {
  _$ProductQueryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductQuery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchTerm = null,
    Object? category = freezed,
    Object? status = null,
    Object? sort = null,
    Object? page = null,
    Object? pageSize = null,
  }) {
    return _then(_value.copyWith(
      searchTerm: null == searchTerm
          ? _value.searchTerm
          : searchTerm // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ProductCategory?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ProductStatusFilter,
      sort: null == sort
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as ProductSort,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductQueryImplCopyWith<$Res>
    implements $ProductQueryCopyWith<$Res> {
  factory _$$ProductQueryImplCopyWith(
          _$ProductQueryImpl value, $Res Function(_$ProductQueryImpl) then) =
      __$$ProductQueryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String searchTerm,
      ProductCategory? category,
      ProductStatusFilter status,
      ProductSort sort,
      int page,
      int pageSize});
}

/// @nodoc
class __$$ProductQueryImplCopyWithImpl<$Res>
    extends _$ProductQueryCopyWithImpl<$Res, _$ProductQueryImpl>
    implements _$$ProductQueryImplCopyWith<$Res> {
  __$$ProductQueryImplCopyWithImpl(
      _$ProductQueryImpl _value, $Res Function(_$ProductQueryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductQuery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchTerm = null,
    Object? category = freezed,
    Object? status = null,
    Object? sort = null,
    Object? page = null,
    Object? pageSize = null,
  }) {
    return _then(_$ProductQueryImpl(
      searchTerm: null == searchTerm
          ? _value.searchTerm
          : searchTerm // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ProductCategory?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ProductStatusFilter,
      sort: null == sort
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as ProductSort,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ProductQueryImpl extends _ProductQuery {
  const _$ProductQueryImpl(
      {this.searchTerm = '',
      this.category,
      this.status = ProductStatusFilter.all,
      this.sort = ProductSort.newest,
      this.page = 0,
      this.pageSize = 20})
      : super._();

  @override
  @JsonKey()
  final String searchTerm;
  @override
  final ProductCategory? category;
  @override
  @JsonKey()
  final ProductStatusFilter status;
  @override
  @JsonKey()
  final ProductSort sort;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int pageSize;

  @override
  String toString() {
    return 'ProductQuery(searchTerm: $searchTerm, category: $category, status: $status, sort: $sort, page: $page, pageSize: $pageSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductQueryImpl &&
            (identical(other.searchTerm, searchTerm) ||
                other.searchTerm == searchTerm) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, searchTerm, category, status, sort, page, pageSize);

  /// Create a copy of ProductQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductQueryImplCopyWith<_$ProductQueryImpl> get copyWith =>
      __$$ProductQueryImplCopyWithImpl<_$ProductQueryImpl>(this, _$identity);
}

abstract class _ProductQuery extends ProductQuery {
  const factory _ProductQuery(
      {final String searchTerm,
      final ProductCategory? category,
      final ProductStatusFilter status,
      final ProductSort sort,
      final int page,
      final int pageSize}) = _$ProductQueryImpl;
  const _ProductQuery._() : super._();

  @override
  String get searchTerm;
  @override
  ProductCategory? get category;
  @override
  ProductStatusFilter get status;
  @override
  ProductSort get sort;
  @override
  int get page;
  @override
  int get pageSize;

  /// Create a copy of ProductQuery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductQueryImplCopyWith<_$ProductQueryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
