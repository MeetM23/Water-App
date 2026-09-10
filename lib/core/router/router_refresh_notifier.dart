import 'package:flutter/foundation.dart';

/// Bridges a Riverpod provider to the `refreshListenable` of go_router.
///
/// go_router re-evaluates its redirect whenever this notifies, which is how a
/// mid-session status change, such as the owner suspending an account, moves
/// the user off the screen they are on without any navigation code.
class RouterRefreshNotifier extends ChangeNotifier {
  /// Asks go_router to run its redirect again.
  void refresh() => notifyListeners();
}
