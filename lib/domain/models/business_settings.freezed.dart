// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BusinessSettings _$BusinessSettingsFromJson(Map<String, dynamic> json) {
  return _BusinessSettings.fromJson(json);
}

/// @nodoc
mixin _$BusinessSettings {
  String get businessName => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this BusinessSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BusinessSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BusinessSettingsCopyWith<BusinessSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusinessSettingsCopyWith<$Res> {
  factory $BusinessSettingsCopyWith(
          BusinessSettings value, $Res Function(BusinessSettings) then) =
      _$BusinessSettingsCopyWithImpl<$Res, BusinessSettings>;
  @useResult
  $Res call(
      {String businessName, String phone, String address, DateTime? updatedAt});
}

/// @nodoc
class _$BusinessSettingsCopyWithImpl<$Res, $Val extends BusinessSettings>
    implements $BusinessSettingsCopyWith<$Res> {
  _$BusinessSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BusinessSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? businessName = null,
    Object? phone = null,
    Object? address = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      businessName: null == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BusinessSettingsImplCopyWith<$Res>
    implements $BusinessSettingsCopyWith<$Res> {
  factory _$$BusinessSettingsImplCopyWith(_$BusinessSettingsImpl value,
          $Res Function(_$BusinessSettingsImpl) then) =
      __$$BusinessSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String businessName, String phone, String address, DateTime? updatedAt});
}

/// @nodoc
class __$$BusinessSettingsImplCopyWithImpl<$Res>
    extends _$BusinessSettingsCopyWithImpl<$Res, _$BusinessSettingsImpl>
    implements _$$BusinessSettingsImplCopyWith<$Res> {
  __$$BusinessSettingsImplCopyWithImpl(_$BusinessSettingsImpl _value,
      $Res Function(_$BusinessSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusinessSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? businessName = null,
    Object? phone = null,
    Object? address = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$BusinessSettingsImpl(
      businessName: null == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BusinessSettingsImpl extends _BusinessSettings {
  const _$BusinessSettingsImpl(
      {required this.businessName,
      this.phone = '',
      this.address = '',
      this.updatedAt})
      : super._();

  factory _$BusinessSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusinessSettingsImplFromJson(json);

  @override
  final String businessName;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String address;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BusinessSettings(businessName: $businessName, phone: $phone, address: $address, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessSettingsImpl &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, businessName, phone, address, updatedAt);

  /// Create a copy of BusinessSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessSettingsImplCopyWith<_$BusinessSettingsImpl> get copyWith =>
      __$$BusinessSettingsImplCopyWithImpl<_$BusinessSettingsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusinessSettingsImplToJson(
      this,
    );
  }
}

abstract class _BusinessSettings extends BusinessSettings {
  const factory _BusinessSettings(
      {required final String businessName,
      final String phone,
      final String address,
      final DateTime? updatedAt}) = _$BusinessSettingsImpl;
  const _BusinessSettings._() : super._();

  factory _BusinessSettings.fromJson(Map<String, dynamic> json) =
      _$BusinessSettingsImpl.fromJson;

  @override
  String get businessName;
  @override
  String get phone;
  @override
  String get address;
  @override
  DateTime? get updatedAt;

  /// Create a copy of BusinessSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusinessSettingsImplCopyWith<_$BusinessSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
