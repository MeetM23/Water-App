import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Search input used above catalogue and dealer lists.
///
/// Shows a clear button once there is text, so a dealer can get back to the
/// full list without selecting and deleting.
class AppSearchField extends StatefulWidget {
  /// Creates a search field.
  const AppSearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    super.key,
    this.clearTooltip,
  });

  /// Controller owning the query text.
  final TextEditingController controller;

  /// Placeholder describing what can be searched.
  final String hint;

  /// Called on every change to the query.
  final ValueChanged<String> onChanged;

  /// Tooltip on the clear button.
  final String? clearTooltip;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() => setState(() {});

  void _clear() {
    widget.controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;

    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: AppColors.ink),
      decoration: InputDecoration(
        hintText: widget.hint,
        fillColor: AppColors.surface,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: hasText
            ? IconButton(
                onPressed: _clear,
                icon: const Icon(Icons.close_rounded, size: 18),
                tooltip: widget.clearTooltip,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.x3,
          vertical: Spacing.x3,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.controlAll,
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
