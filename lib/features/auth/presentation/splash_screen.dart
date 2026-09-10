import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_state.dart';
import '../application/session_controller.dart';

/// Cold-start screen.
///
/// The router parks here while the restored session is being resolved, so no
/// user ever sees a screen belonging to the wrong role, even for one frame.
/// If resolving the profile fails, this becomes the retry surface rather than
/// dumping the user at a login form they have already passed.
class SplashScreen extends ConsumerWidget {
  /// Creates the splash screen.
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: session.when(
          loading: () => const _SplashBrand(),
          data: (_) => const _SplashBrand(),
          error: (Object error, StackTrace stackTrace) => AppErrorState(
            failure: error is AppFailure
                ? error
                : UnexpectedFailure(cause: error, stackTrace: stackTrace),
            onRetry: () =>
                ref.read(sessionControllerProvider.notifier).reload(),
          ),
        ),
      ),
    );
  }
}

class _SplashBrand extends StatelessWidget {
  const _SplashBrand();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 72,
            width: 72,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadius.cardAll,
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: AppColors.surface,
              size: 36,
            ),
          ),
          const SizedBox(height: Spacing.x8),
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}
