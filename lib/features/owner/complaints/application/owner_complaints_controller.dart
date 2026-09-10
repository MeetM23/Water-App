import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/repositories/supabase_complaint_repository.dart';
import '../../../../domain/enums/complaint_category.dart';
import '../../../../domain/enums/complaint_priority.dart';
import '../../../../domain/enums/complaint_status.dart';
import '../../../../domain/models/complaint.dart';

part 'owner_complaints_controller.g.dart';

/// State for owner complaint filter criteria.
class OwnerComplaintFilter {
  const OwnerComplaintFilter({
    this.status,
    this.priority,
    this.category,
    this.searchQuery = '',
  });

  final ComplaintStatus? status;
  final ComplaintPriority? priority;
  final ComplaintCategory? category;
  final String searchQuery;

  OwnerComplaintFilter copyWith({
    ComplaintStatus? status,
    ComplaintPriority? priority,
    ComplaintCategory? category,
    String? searchQuery,
    bool clearStatus = false,
    bool clearPriority = false,
    bool clearCategory = false,
  }) =>
      OwnerComplaintFilter(
        status: clearStatus ? null : (status ?? this.status),
        priority: clearPriority ? null : (priority ?? this.priority),
        category: clearCategory ? null : (category ?? this.category),
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

@riverpod
class OwnerComplaintQueryController extends _$OwnerComplaintQueryController {
  @override
  OwnerComplaintFilter build() => const OwnerComplaintFilter();

  void setStatus(ComplaintStatus? status) {
    state = state.copyWith(status: status, clearStatus: status == null);
  }

  void setPriority(ComplaintPriority? priority) {
    state = state.copyWith(priority: priority, clearPriority: priority == null);
  }

  void setCategory(ComplaintCategory? category) {
    state = state.copyWith(category: category, clearCategory: category == null);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void reset() {
    state = const OwnerComplaintFilter();
  }
}

/// Loads complaints list for the Owner dashboard.
@riverpod
class OwnerComplaintsController extends _$OwnerComplaintsController {
  @override
  Future<List<Complaint>> build() async {
    final filter = ref.watch(ownerComplaintQueryControllerProvider);
    final result = await ref.watch(complaintRepositoryProvider).fetchAllComplaints(
          status: filter.status,
          priority: filter.priority,
          category: filter.category,
          searchQuery: filter.searchQuery,
        );

    return result.fold(
      onSuccess: (complaints) => complaints,
      onFailure: (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
