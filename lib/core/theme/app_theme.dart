import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Assembles the single [ThemeData] the app runs on.
///
/// Component themes are defined here so that a bare Material widget dropped
/// anywhere in the tree already looks like part of this product. Nothing is
/// left to Material defaults: no seeded colour scheme, no elevation overlays,
/// no stock app bar.
abstract final class AppTheme {
  /// The light theme. The client brief specifies a single light palette, so no
  /// dark theme is shipped.
  static ThemeData get light {
    const text = _textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: _scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
      textTheme: text,
      fontFamily: AppTypography.latin,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: _appBarTheme(text),
      cardTheme: _cardTheme,
      inputDecorationTheme: _inputTheme(text),
      elevatedButtonTheme: _elevatedButtonTheme(text),
      outlinedButtonTheme: _outlinedButtonTheme(text),
      textButtonTheme: _textButtonTheme(text),
      chipTheme: _chipTheme(text),
      dialogTheme: _dialogTheme(text),
      snackBarTheme: _snackBarTheme(text),
      bottomSheetTheme: _bottomSheetTheme,
      dividerTheme: _dividerTheme,
      listTileTheme: _listTileTheme(text),
      navigationBarTheme: _navigationBarTheme(text),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearMinHeight: 3,
      ),
      floatingActionButtonTheme: _floatingActionButtonTheme(text),
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 20),
    );
  }

  static const ColorScheme _scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.surface,
    primaryContainer: AppColors.primaryTint,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.primaryDark,
    onSecondary: AppColors.surface,
    error: AppColors.danger,
    onError: AppColors.surface,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
    scrim: AppColors.scrim,
  );

  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTypography.displayLg,
    displayMedium: AppTypography.displayLg,
    displaySmall: AppTypography.titleLg,
    headlineLarge: AppTypography.displayLg,
    headlineMedium: AppTypography.titleLg,
    headlineSmall: AppTypography.titleMd,
    titleLarge: AppTypography.titleLg,
    titleMedium: AppTypography.titleMd,
    titleSmall: AppTypography.labelLg,
    bodyLarge: AppTypography.bodyLg,
    bodyMedium: AppTypography.bodyMd,
    bodySmall: AppTypography.bodySm,
    labelLarge: AppTypography.labelLg,
    labelMedium: AppTypography.labelSm,
    labelSmall: AppTypography.labelSm,
  );

  static AppBarTheme _appBarTheme(TextTheme text) => AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.ink,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleSpacing: Spacing.x4,
    titleTextStyle: text.titleLarge?.copyWith(color: AppColors.ink),
    iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    shape: const Border(bottom: BorderSide(color: AppColors.border)),
  );

  static const CardTheme _cardTheme = CardTheme(
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.cardAll,
      side: BorderSide(color: AppColors.border),
    ),
  );

  static InputDecorationTheme _inputTheme(TextTheme text) =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.x3,
          vertical: Spacing.x3,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: AppColors.disabledInk),
        labelStyle: text.labelLarge?.copyWith(color: AppColors.textSecondary),
        errorStyle: text.bodySmall?.copyWith(color: AppColors.danger),
        border: _inputBorder(AppColors.border),
        enabledBorder: _inputBorder(AppColors.border),
        focusedBorder: _inputBorder(AppColors.primary, width: 1.5),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger, width: 1.5),
        disabledBorder: _inputBorder(AppColors.border),
      );

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: AppRadius.controlAll,
        borderSide: BorderSide(color: color, width: width),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(TextTheme text) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          disabledBackgroundColor: AppColors.disabledFill,
          disabledForegroundColor: AppColors.disabledInk,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.x5),
          textStyle: text.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.controlAll,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(TextTheme text) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          disabledForegroundColor: AppColors.disabledInk,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.x5),
          textStyle: text.labelLarge,
          side: const BorderSide(color: AppColors.border),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.controlAll,
          ),
        ),
      );

  static TextButtonThemeData _textButtonTheme(TextTheme text) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.disabledInk,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.x3),
          textStyle: text.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.controlAll,
          ),
        ),
      );

  static ChipThemeData _chipTheme(TextTheme text) => ChipThemeData(
    backgroundColor: AppColors.primaryTint,
    selectedColor: AppColors.primary,
    secondarySelectedColor: AppColors.primary,
    disabledColor: AppColors.disabledFill,
    checkmarkColor: Colors.white,
    labelStyle: text.labelSmall?.copyWith(color: AppColors.primaryDark),
    secondaryLabelStyle: text.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
    padding: const EdgeInsets.symmetric(
      horizontal: Spacing.x3,
      vertical: Spacing.x1,
    ),
    side: BorderSide.none,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
  );

  static FloatingActionButtonThemeData _floatingActionButtonTheme(TextTheme text) =>
      FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        extendedTextStyle: text.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );

  static DialogTheme _dialogTheme(TextTheme text) => DialogTheme(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    insetPadding: const EdgeInsets.all(Spacing.x6),
    titleTextStyle: text.titleMedium?.copyWith(color: AppColors.ink),
    contentTextStyle: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
  );

  static SnackBarThemeData _snackBarTheme(TextTheme text) => SnackBarThemeData(
    backgroundColor: AppColors.ink,
    contentTextStyle: text.bodyMedium?.copyWith(color: AppColors.surface),
    actionTextColor: AppColors.primaryTint,
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    insetPadding: const EdgeInsets.all(Spacing.x4),
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.controlAll),
  );

  static const BottomSheetThemeData _bottomSheetTheme = BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    modalElevation: 0,
    showDragHandle: true,
    dragHandleColor: AppColors.border,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
  );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.border,
    thickness: 1,
    space: 1,
  );

  static NavigationBarThemeData _navigationBarTheme(TextTheme text) =>
      NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryTint,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (Set<WidgetState> states) => text.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryDark
                : AppColors.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryDark
                : AppColors.textSecondary,
          ),
        ),
      );

  static ListTileThemeData _listTileTheme(TextTheme text) => ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: Spacing.x4,
      vertical: Spacing.x2,
    ),
    titleTextStyle: text.bodyLarge?.copyWith(color: AppColors.ink),
    subtitleTextStyle: text.bodySmall?.copyWith(color: AppColors.textSecondary),
    iconColor: AppColors.textSecondary,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
  );
}
