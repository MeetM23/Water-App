import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../data/repositories/supabase_settings_repository.dart';
import '../../../../domain/models/business_settings.dart';

part 'business_settings_controller.g.dart';

/// The business details printed on labels and exports.
///
/// Kept alive because the label builder reads it on every print job and the
/// value changes perhaps twice a year; refetching it per sheet would be a
/// round trip for nothing.
@Riverpod(keepAlive: true)
class BusinessSettingsController extends _$BusinessSettingsController {
  @override
  Future<BusinessSettings> build() async {
    final result = await ref.read(settingsRepositoryProvider).fetch();
    return result.fold(
      onSuccess: (value) => value,
      onFailure: (failure) => throw failure,
    );
  }

  /// Saves new details, returning the failure rather than throwing.
  ///
  /// The edit form keeps whatever the owner typed on failure, so this must not
  /// blow away the loaded state on an error.
  Future<AppFailure?> save(BusinessSettings settings) async {
    final result = await ref.read(settingsRepositoryProvider).save(settings);

    final failure = result.failureOrNull;
    if (failure != null) {
      return failure;
    }

    state = AsyncValue<BusinessSettings>.data(result.valueOrNull!);
    return null;
  }

  /// Reloads from the server.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
