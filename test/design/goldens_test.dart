import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/app/shell.dart';
import 'package:flowstate/design/theme.dart';
import 'package:flowstate/l10n/app_localizations.dart';

const Size _compactViewport = Size(390, 844);
const Size _expandedViewport = Size(1440, 900);

void main() {
  testWidgets(
    'Flow State compact light golden',
    (WidgetTester tester) async {
      await _pumpFlow(tester, _compactViewport, FlowTheme.light());
      await expectLater(
        find.byType(AdaptiveShell),
        matchesGoldenFile('goldens/flow-state-compact-light.png'),
      );
    },
    skip: Platform.isWindows,
  );

  testWidgets(
    'Flow State compact dark golden',
    (WidgetTester tester) async {
      await _pumpFlow(tester, _compactViewport, FlowTheme.dark());
      await expectLater(
        find.byType(AdaptiveShell),
        matchesGoldenFile('goldens/flow-state-compact-dark.png'),
      );
    },
    skip: Platform.isWindows,
  );

  testWidgets(
    'Flow State expanded light golden',
    (WidgetTester tester) async {
      await _pumpFlow(tester, _expandedViewport, FlowTheme.light());
      await expectLater(
        find.byType(AdaptiveShell),
        matchesGoldenFile('goldens/flow-state-expanded-light.png'),
      );
    },
    skip: Platform.isWindows,
  );

  testWidgets(
    'Flow State expanded dark golden',
    (WidgetTester tester) async {
      await _pumpFlow(tester, _expandedViewport, FlowTheme.dark());
      await expectLater(
        find.byType(AdaptiveShell),
        matchesGoldenFile('goldens/flow-state-expanded-dark.png'),
      );
    },
    skip: Platform.isWindows,
  );

  testWidgets(
    'Flow State compact light at 200 percent text',
    (WidgetTester tester) async {
      await _pumpFlow(
        tester,
        _compactViewport,
        FlowTheme.light(),
        textScaleFactor: 2,
      );
      await expectLater(
        find.byType(AdaptiveShell),
        matchesGoldenFile('goldens/flow-state-compact-light-text-200.png'),
      );
    },
    skip: Platform.isWindows,
  );
}

Future<void> _pumpFlow(
  WidgetTester tester,
  Size viewport,
  ThemeData theme, {
  double textScaleFactor = 1,
}) async {
  tester.view
    ..physicalSize = viewport
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (BuildContext context) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScaleFactor),
            ),
            child: const AdaptiveShell(),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}
