import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/repositories/supabase_dealer_repository.dart';
import '../../../../domain/enums/dealer_segment.dart';
import '../../../../domain/models/dealer_activity.dart';
import '../../../../domain/models/dealer_query.dart';
import '../../../../domain/models/profile.dart';

part 'dealer_directory_controller.g.dart';

/// How long the directory waits after the last keystroke before querying.
const Duration dealerSearchDebounce = Duration(milliseconds: 300);

/// Segment and search state for the dealer directory.
@riverpod
class DealerQueryController extends _$DealerQueryController {
  Timer? _debounce;

  @override
  DealerQuery build() {
    ref.onDispose(() => _debounce?.cancel());
    return const DealerQuery();
  }

  /// Switches segment, keeping any search term in place.
  ///
  /// Keeping the term is deliberate: an owner who has typed "Rajkot" is
  /// looking for a firm, and flipping between wholesalers and retailers is how
  /// they find out which list it is in.
  void setSegment(DealerSegment segment) =>
      state = state.copyWith(segment: segment);

  /// Updates the search term once typing pauses.
  void search(String term) {
    _debounce?.cancel();
    _debounce = Timer(dealerSearchDebounce, () {
      state = state.copyWith(searchTerm: term);
    });
  }

  /// Clears the search term, keeping the segment.
  void clearSearch() {
    _debounce?.cancel();
    state = state.copyWith(searchTerm: '');
  }
}

/// Loads the directory slice the owner is currently looking at.
@riverpod
class DealerDirectoryController extends _$DealerDirectoryController {
  @override
  Future<List<Profile>> build() async {
    final query = ref.watch(dealerQueryControllerProvider);
    final result = await ref.read(dealerRepositoryProvider).search(query);
    return result.fold(
      onSuccess: (value) => value,
      onFailure: (failure) => throw failure,
    );
  }

  /// Reloads the current slice.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// One dealer's profile and activity, for the detail screen.
class DealerDetail {
  /// Creates a detail bundle.
  const DealerDetail({required this.profile, required this.activity});

  /// The dealer.
  final Profile profile;

  /// How much they have used the catalogue.
  final DealerActivity activity;
}

/// Loads one dealer with their scan totals.
@riverpod
class DealerDetailController extends _$DealerDetailController {
  @override
  Future<DealerDetail> build(String userId) async {
    final profileResult = await ref
        .read(dealerRepositoryProvider)
        .fetchById(userId);

    final profile = profileResult.fold(
      onSuccess: (value) => value,
      onFailure: (failure) => throw failure,
    );

    final activity = await ref.read(dealerRepositoryProvider).activity(userId);

    return DealerDetail(
      profile: profile,
      // Activity is supporting detail. A dealer whose scan totals will not
      // load is still a dealer the owner may need to suspend right now.
      activity: activity.valueOrNull ?? const DealerActivity(totalScans: 0),
    );
  }

  /// Reloads this dealer.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
