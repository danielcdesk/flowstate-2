import 'package:flutter/material.dart';

import 'package:flowstate/design/components/skill_radar.dart';
import 'package:flowstate/design/tokens.dart';
import 'package:flowstate/l10n/app_localizations.dart';
import 'package:flowstate/l10n/app_localizations_pt.dart';

class DesignCatalogPage extends StatelessWidget {
  const DesignCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations =
        AppLocalizations.of(context) ?? AppLocalizationsPtBr();
    return Scaffold(
      appBar: AppBar(title: Text(localizations.designCatalogTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: FlowTokens.catalogMaxWidth,
          ),
          child: SingleChildScrollView(
            padding: FlowTokens.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  localizations.skillRadarTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: FlowTokens.space2),
                Text(localizations.skillRadarDescription),
                const SizedBox(height: FlowTokens.space8),
                Card(
                  child: Padding(
                    padding: FlowTokens.cardPadding,
                    child: SkillRadar(
                      title: localizations.skillRadarAccessibleTitle,
                      metrics: <SkillRadarMetric>[
                        SkillRadarMetric(
                          label: localizations.skillConsistency,
                          value: 78,
                        ),
                        SkillRadarMetric(
                          label: localizations.skillFocus,
                          value: 64,
                        ),
                        SkillRadarMetric(
                          label: localizations.skillPlanning,
                          value: 53,
                        ),
                        SkillRadarMetric(
                          label: localizations.skillEnergy,
                          value: 71,
                        ),
                        SkillRadarMetric(
                          label: localizations.skillStrength,
                          value: 42,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
