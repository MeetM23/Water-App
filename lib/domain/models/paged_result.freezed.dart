// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paged_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PagedResult<T> {
  List<T> get items => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;

  /// Create a copy of PagedResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PagedResultCopyWith<T, PagedResult<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PagedResultCopyWith<T, $Res> {
  factory $PagedResultCopyWith(
          PagedResult<T> value, $Res Function(PagedResult<T>) then) =
      _$PagedResultCopyWithImpl<T, $Res, PagedResult<T>>;
  @useResult
  $Res call({List<T> items, int page, bool hasMore});
}

/// @nodoc
class _$PagedResultCopyWithImpl<T, $Res, $Val extends PagedResult<T>>
    implements $PagedResultCopyWith<T, $Res> {
  _$PagedResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PagedResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? hasMore = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<T>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PagedResultImplCopyWith<T, $Res>
    implements $PagedResultCopyWith<T, $Res> {
  factory _$$PagedResultImplCopyWith(_$PagedResultImpl<T> value,
          $Res Function(_$PagedResultImpl<T>) then) =
      __$$PagedResultImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({List<T> items, int page, bool hasMore});
}

/// @nodoc
class __$$PagedResultImplCopyWithImpl<T, $Res>
    extends _$PagedResultCopyWithImpl<T, $Res, _$PagedResultImpl<T>>
    implements _$$PagedResultImplCopyWith<T, $Res> {
  __$$PagedResultImplCopyWithImpl(
      _$PagedResultImpl<T> _value, $Res Function(_$PagedResultImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of PagedResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? hasMore = null,
  }) {
    return _then(_$PagedResultImpl<T>(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<T>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$PagedResultImpl<T> extends _PagedResult<T> {
  const _$PagedResultImpl(
      {required final List<T> items, required this.page, required this.hasMore})
      : _items = items,
        super._();

  final List<T> _items;
  @override
  List<T> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int page;
  @override
  final bool hasMore;

  @override
  String toString() {
    return 'PagedResult<$T>(items: $items, page: $page, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PagedResultImpl<T> &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_items), page, hasMore);

  /// Create a copy of PagedResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PagedResultImplCopyWith<T, _$PagedResultImpl<T>> get copyWith =>
      __$$PagedResultImplCopyWithImpl<T, _$PagedResultImpl<T>>(
          this, _$identity);
}

abstract class _PagedResult<T> extends PagedResult<T> {
  const factory _PagedResult(
      {required final List<T> items,
      required final int page,
      required final bool hasMore}) = _$PagedResultImpl<T>;
  const _PagedResult._() : super._();

  @override
  List<T> get items;
  @override
  int get page;
  @override
  bool get hasMore;

  /// Create a copy of PagedResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PagedResultImplCopyWith<T, _$PagedResultImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
