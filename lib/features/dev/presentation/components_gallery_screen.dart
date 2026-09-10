import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import 'sections/controls_section.dart';
import 'sections/states_section.dart';
import 'sections/typography_section.dart';

/// Hidden design-system gallery at `/dev/components`.
///
/// Renders every shared component in every state on one scrollable page so the
/// design system can be reviewed visually without navigating the product. It is
/// not linked from any screen and the router never redirects to it.
///
/// The captions here are developer labels rather than product copy, so unlike
/// the rest of the app they are not routed through the localisation files.
class ComponentsGalleryScreen extends StatelessWidget {
  /// Creates the gallery.
  const ComponentsGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design system')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.x4,
          Spacing.x6,
          Spacing.x4,
          Spacing.x10,
        ),
        children: const <Widget>[
          TypographySection(),
          ControlsSection(),
          StatesSection(),
        ],
      ),
    );
  }
}
