/// The 4pt spacing grid.
///
/// Padding, gaps and insets must come from here. A raw number in a widget is a
/// bug: it is how a layout drifts off the grid one screen at a time.
abstract final class Spacing {
  /// 4dp.
  static const double x1 = 4;

  /// 8dp.
  static const double x2 = 8;

  /// 12dp.
  static const double x3 = 12;

  /// 16dp. The default gutter for screen content.
  static const double x4 = 16;

  /// 20dp.
  static const double x5 = 20;

  /// 24dp.
  static const double x6 = 24;

  /// 32dp.
  static const double x8 = 32;

  /// 40dp.
  static const double x10 = 40;
}
