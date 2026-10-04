import 'package:flutter/material.dart';

import 'package:flowstate/design/tokens.dart';

abstract final class FlowTheme {
  static ThemeData light() {
    final ColorScheme colors =
        ColorScheme.fromSeed(
          seedColor: FlowTokens.accentBlueDark,
          brightness: Brightness.light,
        ).copyWith(
          primary: FlowTokens.accentBlueDark,
          onPrimary: Colors.white,
          secondary: FlowTokens.accentPurple,
          error: FlowTokens.accentCoral,
          surface: FlowTokens.surfaceLight,
          surfaceContainerLow: FlowTokens.canvasLight,
          outline: const Color(0xFFD8E1EA),
        );
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: colors,
      scaffoldBackgroundColor: FlowTokens.canvasLight,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: FlowTokens.canvasLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: FlowTokens.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FlowTokens.radiusLarge),
          side: BorderSide(color: colors.outline.withValues(alpha: 0.72)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: FlowTokens.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: colors.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: colors.primary.withValues(alpha: 0.14),
        selectedIconTheme: IconThemeData(color: colors.primary),
        selectedLabelTextStyle: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline.withValues(alpha: 0.7),
        space: 1,
        thickness: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(FlowTokens.tapTarget, FlowTokens.tapTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FlowTokens.radiusMedium),
          ),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final ColorScheme colors =
        ColorScheme.fromSeed(
          seedColor: FlowTokens.accentBlue,
          brightness: Brightness.dark,
        ).copyWith(
          primary: FlowTokens.accentBlue,
          onPrimary: FlowTokens.canvasDark,
          secondary: FlowTokens.accentPurple,
          error: FlowTokens.accentCoral,
          surface: FlowTokens.surfaceDark,
          surfaceContainerLow: FlowTokens.canvasDark,
          surfaceContainer: FlowTokens.surfaceDarkRaised,
          outline: const Color(0xFF294459),
        );
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colors,
      scaffoldBackgroundColor: FlowTokens.canvasDark,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: FlowTokens.canvasDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: FlowTokens.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FlowTokens.radiusLarge),
          side: BorderSide(color: colors.outline.withValues(alpha: 0.7)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: FlowTokens.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: colors.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: colors.primary.withValues(alpha: 0.15),
        selectedIconTheme: IconThemeData(color: colors.primary),
        selectedLabelTextStyle: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline.withValues(alpha: 0.7),
        space: 1,
        thickness: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(FlowTokens.tapTarget, FlowTokens.tapTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FlowTokens.radiusMedium),
          ),
        ),
      ),
    );
  }
}
