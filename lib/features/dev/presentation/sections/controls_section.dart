import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../widgets/gallery_section.dart';

/// Buttons, inputs, cards and badges in every state.
class ControlsSection extends StatefulWidget {
  /// Creates the controls section.
  const ControlsSection({super.key});

  @override
  State<ControlsSection> createState() => _ControlsSectionState();
}

class _ControlsSectionState extends State<ControlsSection> {
  final TextEditingController _plainController = TextEditingController();
  final TextEditingController _filledController = TextEditingController(
    text: 'Bhavnagar Aqua Traders',
  );
  final TextEditingController _invalidController = TextEditingController(
    text: 'not-an-email',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'secretpassword',
  );
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _plainController.dispose();
    _filledController.dispose();
    _invalidController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GallerySection(
          title: 'Buttons',
          children: <Widget>[
            for (final variant in AppButtonVariant.values) ...<Widget>[
              GallerySpecimen(
                caption: '${variant.name} / default',
                child: AppButton(
                  label: 'Continue',
                  onPressed: () {},
                  variant: variant,
                ),
              ),
              GallerySpecimen(
                caption: '${variant.name} / loading',
                child: AppButton(
                  label: 'Continue',
                  onPressed: () {},
                  variant: variant,
                  isLoading: true,
                ),
              ),
              GallerySpecimen(
                caption: '${variant.name} / disabled',
                child: AppButton(
                  label: 'Continue',
                  onPressed: null,
                  variant: variant,
                ),
              ),
              GallerySpecimen(
                caption: '${variant.name} / with icon',
                child: AppButton(
                  label: 'Scan barcode',
                  onPressed: () {},
                  variant: variant,
                  icon: Icons.qr_code_scanner_rounded,
                ),
              ),
            ],
          ],
        ),
        GallerySection(
          title: 'Text fields',
          children: <Widget>[
            GallerySpecimen(
              caption: 'empty with hint and prefix',
              child: AppTextField(
                label: l10n.fieldEmail,
                controller: _plainController,
                hint: l10n.hintEmail,
                prefixIcon: Icons.mail_outline_rounded,
              ),
            ),
            GallerySpecimen(
              caption: 'filled with optional marker',
              child: AppTextField(
                label: l10n.fieldFirmName,
                controller: _filledController,
                trailingLabel: l10n.fieldOptional,
              ),
            ),
            GallerySpecimen(
              caption: 'inline error',
              child: Form(
                autovalidateMode: AutovalidateMode.always,
                child: AppTextField(
                  label: l10n.fieldEmail,
                  controller: _invalidController,
                  validator: (String? value) => Validators.email(value, l10n),
                ),
              ),
            ),
            GallerySpecimen(
              caption: 'password with reveal toggle',
              child: AppTextField(
                label: l10n.fieldPassword,
                controller: _passwordController,
                isObscured: true,
              ),
            ),
            GallerySpecimen(
              caption: 'disabled',
              child: AppTextField(
                label: l10n.fieldCity,
                controller: _plainController,
                isEnabled: false,
                hint: 'Botad',
              ),
            ),
            GallerySpecimen(
              caption: 'search field',
              child: AppSearchField(
                controller: _searchController,
                hint: 'Search products',
                clearTooltip: l10n.actionClear,
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'Cards and badges',
          children: <Widget>[
            const GallerySpecimen(
              caption: 'card / resting',
              child: AppCard(child: Text('Aqua Grand Domestic RO Purifier')),
            ),
            GallerySpecimen(
              caption: 'card / tappable',
              child: AppCard(
                onTap: () {},
                child: const Text('Commercial RO Plant 250 LPH'),
              ),
            ),
            const GallerySpecimen(
              caption: 'card / selected',
              child: AppCard(
                isSelected: true,
                child: Text('Industrial RO Plant 3000 LPH'),
              ),
            ),
            GallerySpecimen(
              caption: 'badges / every tone',
              child: Wrap(
                spacing: Spacing.x2,
                runSpacing: Spacing.x2,
                children: <Widget>[
                  for (final tone in AppBadgeTone.values)
                    AppBadge(label: tone.name, tone: tone, icon: Icons.circle),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
