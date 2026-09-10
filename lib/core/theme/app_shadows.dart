import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Elevation for this app is a hairline border plus a soft shadow.
///
/// Material elevation overlays are deliberately unused: they tint surfaces and
/// make every screen read as a stock Flutter app.
abstract final class AppShadows {
  /// Resting elevation for cards and list rows.
  ///
  /// Ink at four percent opacity, blurred 12, offset two down.
  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(color: Color(0x0A0F1729), blurRadius: 12, offset: Offset(0, 2)),
  ];

  /// Raised elevation for sheets, menus and pressed cards.
  static const List<BoxShadow> lifted = <BoxShadow>[
    BoxShadow(color: Color(0x140F1729), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// The hairline that pairs with [soft].
  static const Border hairline = Border.fromBorderSide(
    BorderSide(color: AppColors.border),
  );
}
