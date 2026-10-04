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
  static const double iconSmall = 20;
  static const double progressThickness = 6;
  static const double heatmapCellSize = 14;
  static const double heatmapCellRadius = 4;
  static const double heatmapGap = 4;
  static const double formMaxWidth = 560;
  static const double habitHeaderStackWidth = 420;
  static const double focusSheetMaxWidth = 560;
  static const double focusTimerSize = 240;
  static const double accessibilityLargeTextScale = 1.4;
  static const EdgeInsets habitRowPadding = EdgeInsets.only(bottom: space2);
  static const EdgeInsets planWeekdayPadding = EdgeInsets.symmetric(
    horizontal: space2,
  );
  static const EdgeInsets planWeekdayButtonPadding = EdgeInsets.symmetric(
    vertical: space2,
  );
  static const EdgeInsets habitDetailPadding = EdgeInsets.fromLTRB(
    space4,
    0,
    space4,
    space4,
  );
  static const EdgeInsets emptyStatePadding = EdgeInsets.all(space8);
  static const EdgeInsets focusSheetPadding = EdgeInsets.all(space6);
  static const EdgeInsets focusLoadingPadding = EdgeInsets.all(space8);

  static EdgeInsets formSheetPadding(double viewInset) =>
      EdgeInsets.fromLTRB(space4, space4, space4, viewInset + space4);
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
