import 'package:freezed_annotation/freezed_annotation.dart';

part 'warranty_claim.freezed.dart';
part 'warranty_claim.g.dart';

/// Status of a warranty claim ticket.
enum WarrantyClaimStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('resolved')
  resolved;

  /// Human-readable label for the UI.
  String get label => switch (this) {
        pending => 'Pending',
        approved => 'Approved',
        rejected => 'Rejected',
        resolved => 'Resolved',
      };
}

/// A warranty claim submitted by a retailer/wholesaler for a physical RO unit.
@freezed
class WarrantyClaim with _$WarrantyClaim {
  /// Creates a warranty claim model.
  const factory WarrantyClaim({
    required String id,
    required String claimNumber,
    required String unitId,
    required String userId,
    required String claimType,
    required String description,
    required String contactPhone,
    @Default(WarrantyClaimStatus.pending) WarrantyClaimStatus status,
    String? adminNotes,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? userFullName,
    String? userCompany,
    String? userPhone,
    String? userRole,
    String? serialNumber,
    String? productId,
    String? productName,
    String? modelNumber,
    String? category,
  }) = _WarrantyClaim;

  const WarrantyClaim._();

  /// Deserializes a warranty claim row or RPC response.
  factory WarrantyClaim.fromJson(Map<String, dynamic> json) =>
      _$WarrantyClaimFromJson(json);
}
