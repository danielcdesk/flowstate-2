import 'package:flutter/material.dart';

import 'package:flowstate/design/tokens.dart';

abstract final class FlowTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FlowTokens.accentLime,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: FlowTokens.canvasLight,
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FlowTokens.accentLime,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: FlowTokens.canvasDark,
      useMaterial3: true,
    );
  }
}
