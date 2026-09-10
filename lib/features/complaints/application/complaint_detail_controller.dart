import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../../../data/repositories/supabase_complaint_repository.dart';
import '../../../domain/enums/complaint_priority.dart';
import '../../../domain/enums/complaint_status.dart';
import '../../../domain/models/complaint.dart';

part 'complaint_detail_controller.g.dart';

/// Loads single complaint details, timeline messages, and handles actions.
@riverpod
class ComplaintDetailController extends _$ComplaintDetailController {
  @override
  Future<Complaint> build(String complaintId) async {
    final result = await ref
        .watch(complaintRepositoryProvider)
        .getComplaintById(complaintId);

    return result.fold(
      onSuccess: (complaint) => complaint,
      onFailure: (failure) => throw failure,
    );
  }

  /// Sends a message/reply to this complaint.
  Future<AppFailure?> sendMessage(String message, {bool isInternal = false}) async {
    final result = await ref.read(complaintRepositoryProvider).addMessage(
          complaintId: complaintId,
          message: message,
          isInternal: isInternal,
        );

    return result.fold(
      onSuccess: (_) {
        ref.invalidateSelf();
        return null;
      },
      onFailure: (failure) => failure,
    );
  }

  /// Updates status and/or priority (Owner only).
  Future<AppFailure?> updateStatusAndPriority({
    ComplaintStatus? status,
    ComplaintPriority? priority,
  }) async {
    final result = await ref
        .read(complaintRepositoryProvider)
        .updateComplaintStatusAndPriority(
          complaintId: complaintId,
          status: status,
          priority: priority,
        );

    return result.fold(
      onSuccess: (updated) {
        state = AsyncValue<Complaint>.data(updated);
        return null;
      },
      onFailure: (failure) => failure,
    );
  }
}
