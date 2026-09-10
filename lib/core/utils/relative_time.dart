import '../../l10n/generated/app_localizations.dart';

/// Human phrasing for "how long ago".
///
/// The owner reads these to judge urgency, not to know a timestamp: a request
/// from "3 days ago" needs answering, one from "just now" can wait a minute.
/// Precision beyond a day is therefore deliberately discarded.
abstract final class RelativeTime {
  /// Formats the gap between [moment] and [now] in words.
  ///
  /// [now] is a parameter rather than read from the clock so this is testable
  /// without freezing time.
  static String format(
    AppLocalizations l10n,
    DateTime moment, {
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final elapsed = reference.difference(moment);

    // A clock skew between the phone and the server can put a just-created row
    // slightly in the future. "In 3 seconds" would be nonsense, so anything
    // not yet in the past reads as just now.
    if (elapsed.inMinutes < 1) {
      return l10n.timeJustNow;
    }
    if (elapsed.inHours < 1) {
      return l10n.timeMinutes(elapsed.inMinutes);
    }
    if (elapsed.inDays < 1) {
      return l10n.timeHours(elapsed.inHours);
    }
    return l10n.timeDays(elapsed.inDays);
  }
}
