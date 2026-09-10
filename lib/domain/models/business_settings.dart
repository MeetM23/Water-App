import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_settings.freezed.dart';
part 'business_settings.g.dart';

/// The business details printed on labels and exports.
///
/// Held in the database rather than in a constant because the client changes a
/// phone number or moves premises far more often than the app ships, and a
/// label reprint must not wait on a store review.
@freezed
class BusinessSettings with _$BusinessSettings {
  /// Creates a settings record.
  const factory BusinessSettings({
    required String businessName,
    @Default('') String phone,
    @Default('') String address,
    DateTime? updatedAt,
  }) = _BusinessSettings;

  const BusinessSettings._();

  /// Reads a business_settings row.
  factory BusinessSettings.fromJson(Map<String, dynamic> json) =>
      _$BusinessSettingsFromJson(json);

  /// The single line printed under the wordmark on a label, or null when
  /// neither a phone nor an address has been entered yet.
  ///
  /// A label is millimetres tall, so this is deliberately one short line: the
  /// phone alone if that is all there is, otherwise phone and address joined.
  String? get labelFooter {
    final parts = <String>[
      if (phone.trim().isNotEmpty) phone.trim(),
      if (address.trim().isNotEmpty) address.trim(),
    ];
    return parts.isEmpty ? null : parts.join('  ');
  }
}
