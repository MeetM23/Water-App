import 'package:flutter/material.dart';

import '../extensions/build_context_x.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// A labelled integer stepper.
///
/// Used for values that move in small known increments, such as warranty
/// months or a label quantity, where a keyboard is slower than two buttons.
class AppStepperField extends StatelessWidget {
  /// Creates a stepper.
  const AppStepperField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.minimum = 0,
    this.maximum = 999,
    this.step = 1,
    this.suffix,
  });

  /// What the number means.
  final String label;

  /// Current value.
  final int value;

  /// Called with the new value.
  final ValueChanged<int> onChanged;

  /// Lowest permitted value.
  final int minimum;

  /// Highest permitted value.
  final int maximum;

  /// How much each press moves the value.
  final int step;

  /// Optional unit shown beside the number.
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final canDecrease = value - step >= minimum;
    final canIncrease = value + step <= maximum;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(color: AppColors.ink),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: AppRadius.controlAll,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _StepButton(
                icon: Icons.remove_rounded,
                onPressed: canDecrease ? () => onChanged(value - step) : null,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 56),
                child: Text(
                  suffix == null ? '$value' : '$value $suffix',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
              _StepButton(
                icon: Icons.add_rounded,
                onPressed: canIncrease ? () => onChanged(value + step) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(Spacing.x2),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      color: AppColors.ink,
      disabledColor: AppColors.disabledInk,
    );
  }
}
