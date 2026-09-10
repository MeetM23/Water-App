import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Shared page frame for the signed-out screens.
///
/// Keeps the brand mark, headline and content column identical across login
/// and sign-up, and keeps the form clear of the keyboard on small handsets.
class AuthShell extends StatelessWidget {
  /// Creates an auth page frame.
  const AuthShell({
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });

  /// Screen headline.
  final String title;

  /// One line under the headline.
  final String subtitle;

  /// Page content, laid out in a column.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Spacing.x5,
                Spacing.x8,
                Spacing.x5,
                Spacing.x8,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const BrandMark(),
                        const SizedBox(height: Spacing.x8),
                        Text(
                          title,
                          style: context.textTheme.displayLarge?.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: Spacing.x2),
                        Text(
                          subtitle,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: Spacing.x8),
                        ...children,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The Maruti Water lockup: a tinted droplet tile beside the company name.
class BrandMark extends StatelessWidget {
  /// Creates the brand lockup.
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 44,
          width: 44,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadius.cardAll,
          ),
          child: const Icon(
            Icons.water_drop_rounded,
            color: AppColors.surface,
            size: 24,
          ),
        ),
        const SizedBox(width: Spacing.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                AppConfig.companyName,
                style: context.textTheme.titleMedium?.copyWith(
                  color: AppColors.ink,
                ),
              ),
              Text(
                AppConfig.companyLocation,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
