import 'package:flutter/material.dart';

import 'package:flowstate/core/app_constants.dart';
import 'package:flowstate/design/theme.dart';
import 'package:flowstate/features/catalog/presentation/design_catalog_page.dart';
import 'package:flowstate/l10n/app_localizations.dart';

class FlowStateApp extends StatelessWidget {
  const FlowStateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: FlowTheme.light(),
      darkTheme: FlowTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const DesignCatalogPage(),
    );
  }
}
