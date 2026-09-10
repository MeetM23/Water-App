import 'package:flutter/widgets.dart';

/// Corner radii. Cards are softer than controls, chips are fully rounded.
abstract final class AppRadius {
  /// Cards, sheets and dialogs.
  static const double card = 12;

  /// Inputs and buttons.
  static const double control = 10;

  /// Chips, pills and badges.
  static const double pill = 999;

  /// [card] as a ready-made [BorderRadius].
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));

  /// [control] as a ready-made [BorderRadius].
  static const BorderRadius controlAll = BorderRadius.all(
    Radius.circular(control),
  );

  /// [pill] as a ready-made [BorderRadius].
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));

  /// Bottom sheets are rounded on their top edge only.
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(16),
  );
}
