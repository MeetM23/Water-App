import 'package:flutter/material.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../domain/models/profile.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// The preset reasons a registration is turned down.
///
/// A fixed list rather than a free-text box because the reason reaches the
/// dealer verbatim, and because the owner rejecting twenty accounts should not
/// have to compose twenty sentences. `other` exists for the case the list does
/// not cover, and is the only option that demands the owner write something.
enum RejectionReason {
  /// The firm is not a registered business.
  notRegistered,

  /// The same firm already has an account.
  duplicate,

  /// The firm is outside the area the client serves.
  outsideArea,

  /// Anything else, described in the note.
  other,
}

/// Localised text for a [RejectionReason].
extension RejectionReasonLabel on RejectionReason {
  /// The label shown to the owner and stored for the dealer.
  String label(AppLocalizations l10n) => switch (this) {
    RejectionReason.notRegistered => l10n.rejectReasonNotBusiness,
    RejectionReason.duplicate => l10n.rejectReasonDuplicate,
    RejectionReason.outsideArea => l10n.rejectReasonOutsideArea,
    RejectionReason.other => l10n.rejectReasonOther,
  };
}

/// What the owner chose in the rejection sheet.
class RejectionOutcome {
  /// Creates an outcome.
  const RejectionOutcome({required this.reason, required this.notes});

  /// The preset reason.
  final RejectionReason reason;

  /// Free text the owner added, possibly empty.
  final String notes;

  /// The single string written to `rejection_reason` and shown to the dealer.
  ///
  /// For [RejectionReason.other] the note is the whole reason; otherwise it is
  /// appended so the dealer gets both the category and any specifics.
  String message(AppLocalizations l10n) {
    final trimmed = notes.trim();
    if (reason == RejectionReason.other) {
      return trimmed;
    }
    return trimmed.isEmpty
        ? reason.label(l10n)
        : '${reason.label(l10n)} - $trimmed';
  }
}

/// Collects a reason before a registration is turned down.
class RejectDealerSheet extends StatefulWidget {
  /// Creates the sheet.
  const RejectDealerSheet({required this.profile, super.key});

  /// The dealer being rejected.
  final Profile profile;

  /// Opens the sheet, returning the outcome or null if cancelled.
  static Future<RejectionOutcome?> show(
    BuildContext context, {
    required Profile profile,
  }) => showModalBottomSheet<RejectionOutcome>(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      // Lifts the sheet clear of the keyboard when the note field has focus.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: RejectDealerSheet(profile: profile),
    ),
  );

  @override
  State<RejectDealerSheet> createState() => _RejectDealerSheetState();
}

class _RejectDealerSheetState extends State<RejectDealerSheet> {
  final TextEditingController _notes = TextEditingController();
  RejectionReason? _reason;
  bool _hasAttemptedSubmit = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  /// Why the sheet will not submit yet, or null when it will.
  String? _blockingError(AppLocalizations l10n) {
    if (_reason == null) {
      return l10n.rejectPickReason;
    }
    if (_reason == RejectionReason.other && _notes.text.trim().isEmpty) {
      return l10n.rejectNeedsNote;
    }
    return null;
  }

  void _submit() {
    setState(() => _hasAttemptedSubmit = true);
    if (_blockingError(context.l10n) != null) {
      return;
    }
    Navigator.of(
      context,
    ).pop(RejectionOutcome(reason: _reason!, notes: _notes.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _hasAttemptedSubmit ? _blockingError(l10n) : null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.rejectSheetTitle(widget.profile.firmName),
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: Spacing.x2),
            Text(
              l10n.rejectSheetBody,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: Spacing.x5),
            for (final reason in RejectionReason.values)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.x2),
                child: _ReasonOption(
                  label: reason.label(l10n),
                  isSelected: _reason == reason,
                  onTap: () => setState(() => _reason = reason),
                ),
              ),
            const SizedBox(height: Spacing.x4),
            AppTextField(
              label: l10n.rejectNotesLabel,
              controller: _notes,
              hint: l10n.rejectNotesHint,
              trailingLabel: _reason == RejectionReason.other
                  ? null
                  : l10n.fieldOptional,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_hasAttemptedSubmit) {
                  setState(() {});
                }
              },
            ),
            if (error != null) ...<Widget>[
              const SizedBox(height: Spacing.x3),
              Text(
                error,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ],
            const SizedBox(height: Spacing.x5),
            AppButton(
              label: l10n.actionConfirmReject,
              onPressed: _submit,
              variant: AppButtonVariant.danger,
            ),
            const SizedBox(height: Spacing.x2),
            AppButton(
              label: l10n.actionCancel,
              onPressed: () => Navigator.of(context).pop(),
              variant: AppButtonVariant.text,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonOption extends StatelessWidget {
  const _ReasonOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.controlAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.x4,
            vertical: Spacing.x3,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryTint : AppColors.surface,
            borderRadius: AppRadius.controlAll,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              const SizedBox(width: Spacing.x3),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
