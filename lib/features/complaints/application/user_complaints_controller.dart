import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../../../data/repositories/supabase_complaint_repository.dart';
import '../../../domain/enums/complaint_category.dart';
import '../../../domain/enums/complaint_priority.dart';
import '../../../domain/models/complaint.dart';

part 'user_complaints_controller.g.dart';

/// Loads and manages complaints for the logged-in dealer.
@riverpod
class UserComplaintsController extends _$UserComplaintsController {
  @override
  Future<List<Complaint>> build() async {
    final result =
        await ref.watch(complaintRepositoryProvider).fetchUserComplaints();

    return result.fold(
      onSuccess: (complaints) => complaints,
      onFailure: (failure) => throw failure,
    );
  }

  /// Refreshes the complaints list.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Submits a new complaint.
  Future<({Complaint? complaint, AppFailure? failure})> submitComplaint({
    required String subject,
    required ComplaintCategory category,
    required String description,
    required ComplaintPriority priority,
    String? productId,
    String? unitId,
    String? referenceNumber,
    List<({String fileName, Uint8List bytes})>? attachmentFiles,
  }) async {
    final result = await ref.read(complaintRepositoryProvider).createComplaint(
          subject: subject,
          category: category,
          description: description,
          priority: priority,
          productId: productId,
          unitId: unitId,
          referenceNumber: referenceNumber,
          attachmentFiles: attachmentFiles,
        );

    return result.fold(
      onSuccess: (complaint) {
        ref.invalidateSelf();
        return (complaint: complaint, failure: null);
      },
      onFailure: (failure) => (complaint: null, failure: failure),
    );
  }
}
