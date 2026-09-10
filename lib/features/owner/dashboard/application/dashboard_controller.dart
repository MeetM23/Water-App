import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/repositories/supabase_dealer_repository.dart';
import '../../../../data/repositories/supabase_product_repository.dart';
import '../../../../domain/models/dealer_activity.dart';
import '../../../../domain/models/product.dart';
import '../../../../domain/models/product_query.dart';
import '../../../../domain/repositories/product_repository.dart';

part 'dashboard_controller.g.dart';

/// How far back the most-scanned table looks.
const int scanWindowDays = 30;

/// The dashboard is deliberately several small providers rather than one.
///
/// A single provider would mean one slow or failing query blanks the whole
/// screen, and the owner opens this screen to answer "is there anything
/// waiting for me" — a question the pending count can answer even when the
/// scan analytics are down. Each card below loads, fails and retries alone.

/// Catalogue totals: how many products, how many need attention.
@riverpod
Future<ProductCounts> productCountsCard(
  Ref<AsyncValue<ProductCounts>> ref,
) async {
  final result = await ref.read(productRepositoryProvider).counts();
  return result.fold(
    onSuccess: (value) => value,
    onFailure: (failure) => throw failure,
  );
}

/// Dealer headcounts, including the pending queue.
@riverpod
Future<DealerCounts> dealerCountsCard(Ref<AsyncValue<DealerCounts>> ref) async {
  final result = await ref.read(dealerRepositoryProvider).counts();
  return result.fold(
    onSuccess: (value) => value,
    onFailure: (failure) => throw failure,
  );
}

/// The five products dealers scanned most in the last [scanWindowDays] days.
@riverpod
Future<List<ScannedProduct>> topScannedCard(
  Ref<AsyncValue<List<ScannedProduct>>> ref,
) async {
  final result = await ref
      .read(productRepositoryProvider)
      .topScanned(days: scanWindowDays, limit: 5);
  return result.fold(
    onSuccess: (value) => value,
    onFailure: (failure) => throw failure,
  );
}

/// The most recently added products, for the horizontal strip.
@riverpod
Future<List<Product>> recentProductsCard(
  Ref<AsyncValue<List<Product>>> ref,
) async {
  final result = await ref
      .read(productRepositoryProvider)
      .fetchPage(const ProductQuery(pageSize: 8));
  return result.fold(
    onSuccess: (value) => value.items,
    onFailure: (failure) => throw failure,
  );
}

/// The dealer decision feed.
@riverpod
Future<List<DealerActivityEntry>> dealerActivityCard(
  Ref<AsyncValue<List<DealerActivityEntry>>> ref,
) async {
  final result = await ref.read(dealerRepositoryProvider).recentActivity();
  return result.fold(
    onSuccess: (value) => value,
    onFailure: (failure) => throw failure,
  );
}

/// Invalidates every dashboard card at once, for pull to refresh.
///
/// Cards still fail independently; this only means one pull reloads them all
/// rather than making the owner retry five cards by hand. Takes a [WidgetRef]
/// because the only caller is the pull-to-refresh gesture on the screen.
void refreshDashboard(WidgetRef ref) {
  ref
    ..invalidate(productCountsCardProvider)
    ..invalidate(dealerCountsCardProvider)
    ..invalidate(topScannedCardProvider)
    ..invalidate(recentProductsCardProvider)
    ..invalidate(dealerActivityCardProvider);
}
