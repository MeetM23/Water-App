import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extensions/build_context_x.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The only text input in the app.
///
/// The label sits above the field rather than floating inside it, and errors
/// appear inline underneath. Validation runs when the field loses focus and on
/// every keystroke thereafter, so a user who has already made a mistake sees it
/// corrected live instead of only at submit time.
class AppTextField extends StatefulWidget {
  /// Creates a labelled text field.
  const AppTextField({
    required this.label,
    required this.controller,
    super.key,
    this.hint,
    this.helperText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.prefixIcon,
    this.suffix,
    this.isObscured = false,
    this.isEnabled = true,
    this.autofillHints,
    this.maxLength,
    this.maxLines = 1,
    this.onSubmitted,
    this.onChanged,
    this.trailingLabel,
    this.textCapitalization = TextCapitalization.none,
  });

  /// Text shown above the field.
  final String label;

  /// Controller owning the field text.
  final TextEditingController controller;

  /// Placeholder shown while the field is empty.
  final String? hint;

  /// Persistent guidance shown below the field when there is no error.
  final String? helperText;

  /// Returns null when valid, or the message to display inline.
  final String? Function(String?)? validator;

  /// Keyboard layout to request.
  final TextInputType? keyboardType;

  /// What the keyboard action key does.
  final TextInputAction? textInputAction;

  /// Input filtering, for example digits only.
  final List<TextInputFormatter>? inputFormatters;

  /// Optional leading icon inside the field.
  final IconData? prefixIcon;

  /// Optional trailing widget inside the field.
  final Widget? suffix;

  /// Whether this is a password field. Adds a reveal toggle.
  final bool isObscured;

  /// Whether the field accepts input.
  final bool isEnabled;

  /// Autofill hints for the platform password manager.
  final List<String>? autofillHints;

  /// Hard limit on entered characters.
  final int? maxLength;

  /// Maximum number of lines.
  final int maxLines;

  /// Called when the keyboard action key is pressed.
  final ValueChanged<String>? onSubmitted;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Small muted text at the end of the label row, such as "Optional".
  final String? trailingLabel;

  /// How the platform keyboard capitalises input.
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasBeenTouched = false;
  bool _isTextHidden = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && !_hasBeenTouched) {
      setState(() => _hasBeenTouched = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              widget.label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: widget.isEnabled ? AppColors.ink : AppColors.disabledInk,
              ),
            ),
            if (widget.trailingLabel != null) ...<Widget>[
              const SizedBox(width: Spacing.x2),
              Text(
                widget.trailingLabel!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: Spacing.x2),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          validator: widget.validator,
          autovalidateMode: _hasBeenTouched
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          obscureText: widget.isObscured && _isTextHidden,
          enabled: widget.isEnabled,
          autofillHints: widget.autofillHints,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          onFieldSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          textCapitalization: widget.textCapitalization,
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.ink),
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            counterText: '',
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: 20),
            suffixIcon: _buildSuffix(context),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffix(BuildContext context) {
    if (widget.isObscured) {
      return IconButton(
        onPressed: () => setState(() => _isTextHidden = !_isTextHidden),
        icon: Icon(
          _isTextHidden
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 20,
        ),
        tooltip: _isTextHidden
            ? context.l10n.actionShow
            : context.l10n.actionHide,
      );
    }
    return widget.suffix;
  }
}
