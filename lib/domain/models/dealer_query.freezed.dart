// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dealer_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DealerQuery {
  DealerSegment get segment => throw _privateConstructorUsedError;
  String get searchTerm => throw _privateConstructorUsedError;

  /// Create a copy of DealerQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DealerQueryCopyWith<DealerQuery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DealerQueryCopyWith<$Res> {
  factory $DealerQueryCopyWith(
          DealerQuery value, $Res Function(DealerQuery) then) =
      _$DealerQueryCopyWithImpl<$Res, DealerQuery>;
  @useResult
  $Res call({DealerSegment segment, String searchTerm});
}

/// @nodoc
class _$DealerQueryCopyWithImpl<$Res, $Val extends DealerQuery>
    implements $DealerQueryCopyWith<$Res> {
  _$DealerQueryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DealerQuery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? segment = null,
    Object? searchTerm = null,
  }) {
    return _then(_value.copyWith(
      segment: null == segment
          ? _value.segment
          : segment // ignore: cast_nullable_to_non_nullable
              as DealerSegment,
      searchTerm: null == searchTerm
          ? _value.searchTerm
          : searchTerm // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DealerQueryImplCopyWith<$Res>
    implements $DealerQueryCopyWith<$Res> {
  factory _$$DealerQueryImplCopyWith(
          _$DealerQueryImpl value, $Res Function(_$DealerQueryImpl) then) =
      __$$DealerQueryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DealerSegment segment, String searchTerm});
}

/// @nodoc
class __$$DealerQueryImplCopyWithImpl<$Res>
    extends _$DealerQueryCopyWithImpl<$Res, _$DealerQueryImpl>
    implements _$$DealerQueryImplCopyWith<$Res> {
  __$$DealerQueryImplCopyWithImpl(
      _$DealerQueryImpl _value, $Res Function(_$DealerQueryImpl) _then)
      : super(_value, _then);

  /// Create a copy of DealerQuery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? segment = null,
    Object? searchTerm = null,
  }) {
    return _then(_$DealerQueryImpl(
      segment: null == segment
          ? _value.segment
          : segment // ignore: cast_nullable_to_non_nullable
              as DealerSegment,
      searchTerm: null == searchTerm
          ? _value.searchTerm
          : searchTerm // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DealerQueryImpl extends _DealerQuery {
  const _$DealerQueryImpl(
      {this.segment = DealerSegment.all, this.searchTerm = ''})
      : super._();

  @override
  @JsonKey()
  final DealerSegment segment;
  @override
  @JsonKey()
  final String searchTerm;

  @override
  String toString() {
    return 'DealerQuery(segment: $segment, searchTerm: $searchTerm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DealerQueryImpl &&
            (identical(other.segment, segment) || other.segment == segment) &&
            (identical(other.searchTerm, searchTerm) ||
                other.searchTerm == searchTerm));
  }

  @override
  int get hashCode => Object.hash(runtimeType, segment, searchTerm);

  /// Create a copy of DealerQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DealerQueryImplCopyWith<_$DealerQueryImpl> get copyWith =>
      __$$DealerQueryImplCopyWithImpl<_$DealerQueryImpl>(this, _$identity);
}

abstract class _DealerQuery extends DealerQuery {
  const factory _DealerQuery(
      {final DealerSegment segment,
      final String searchTerm}) = _$DealerQueryImpl;
  const _DealerQuery._() : super._();

  @override
  DealerSegment get segment;
  @override
  String get searchTerm;

  /// Create a copy of DealerQuery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DealerQueryImplCopyWith<_$DealerQueryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
