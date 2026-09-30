import 'package:flutter/material.dart';

import 'package:flowstate/design/components/app_button.dart';
import 'package:flowstate/design/components/flow_ring.dart';
import 'package:flowstate/design/tokens.dart';
import 'package:flowstate/l10n/app_localizations.dart';
import 'package:flowstate/l10n/app_localizations_pt.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations =
        AppLocalizations.of(context) ?? AppLocalizationsPtBr();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: FlowTokens.pagePadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: FlowTokens.catalogMaxWidth,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlowRing(
                    progress: 0.72,
                    semanticLabel: localizations.flowRingSemanticLabel,
                    size: FlowTokens.radarSize,
                  ),
                  const SizedBox(height: FlowTokens.space8),
                  Text(
                    localizations.welcomeTitle,
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: FlowTokens.space3),
                  Text(
                    localizations.welcomeDescription,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: FlowTokens.space6),
                  AppButton(
                    label: localizations.continueAction,
                    onPressed: _noop,
                  ),
                  const SizedBox(height: FlowTokens.space3),
                  TextButton(
                    onPressed: null,
                    child: Text(localizations.backupLink),
                  ),
                  const SizedBox(height: FlowTokens.space4),
                  Text(
                    localizations.localDataNote,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
