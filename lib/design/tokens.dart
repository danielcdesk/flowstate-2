import 'package:flutter/material.dart';

abstract final class FlowTokens {
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double radiusMedium = 16;
  static const double radarSize = 280;
  static const double catalogMaxWidth = 720;
  static const double contentMaxWidth = 1100;
  static const double tapTarget = 56;
  static const double compactBreakpoint = 600;
  static const double expandedBreakpoint = 840;

  static const Color canvasDark = Color(0xFF101210);
  static const Color surfaceDark = Color(0xFF171A17);
  static const Color canvasLight = Color(0xFFF4F5F2);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color accentLime = Color(0xFFD6FF59);
  static const Color textDark = Color(0xFF101210);
  static const Color textLight = Color(0xFFF4F5F2);

  static const EdgeInsets pagePadding = EdgeInsets.all(space6);
  static const EdgeInsets cardPadding = EdgeInsets.all(space6);
  static const EdgeInsets sectionPadding = EdgeInsets.all(space4);
}
