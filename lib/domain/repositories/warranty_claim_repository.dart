import '../../core/errors/result.dart';
import '../models/warranty_claim.dart';

/// Repository contract for warranty claim management.
abstract interface class WarrantyClaimRepository {
  /// Submits a new warranty claim for a physical unit.
  Future<Result<WarrantyClaim>> submitClaim({
    required String unitId,
    required String claimType,
    required String description,
    required String contactPhone,
  });

  /// Fetches claims submitted by the current user or all claims for Owner/Admin.
  Future<Result<List<WarrantyClaim>>> fetchClaims({
    String? userId,
    WarrantyClaimStatus? status,
  });

  /// Fetches detailed claim information by claim ID.
  Future<Result<WarrantyClaim?>> fetchClaimById(String claimId);

  /// Updates status and admin notes for a warranty claim (Owner only).
  Future<Result<void>> updateClaimStatus({
    required String claimId,
    required WarrantyClaimStatus status,
    String? adminNotes,
  });
}
