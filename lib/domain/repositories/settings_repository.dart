import '../../core/errors/result.dart';
import '../models/business_settings.dart';

/// The single row of business details used on labels and exports.
abstract interface class SettingsRepository {
  /// Loads the current details.
  Future<Result<BusinessSettings>> fetch();

  /// Saves the details. Owner only, enforced by row level security.
  Future<Result<BusinessSettings>> save(BusinessSettings settings);
}
