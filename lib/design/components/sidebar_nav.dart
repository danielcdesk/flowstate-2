import 'package:flutter/material.dart';

import 'package:flowstate/design/tokens.dart';

class SidebarNav extends StatelessWidget {
  const SidebarNav({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    super.key,
    this.rail = false,
    this.brandLabel = 'Flow State',
    this.onSettingsPressed,
    this.settingsLabel = 'Configurações',
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationRailDestination> destinations;
  final bool rail;
  final String brandLabel;
  final VoidCallback? onSettingsPressed;
  final String settingsLabel;

  @override
  Widget build(BuildContext context) {
    if (rail) {
      return NavigationRail(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        labelType: NavigationRailLabelType.all,
        destinations: destinations,
      );
    }
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox(
        width: FlowTokens.sidebarWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FlowTokens.space3,
            vertical: FlowTokens.space4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  FlowTokens.space3,
                  FlowTokens.space2,
                  FlowTokens.space3,
                  FlowTokens.space6,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.all_inclusive_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: FlowTokens.iconSmall + FlowTokens.space2,
                    ),
                    const SizedBox(width: FlowTokens.space2),
                    Expanded(
                      child: Text(
                        brandLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: NavigationRail(
                  extended: true,
                  backgroundColor: Colors.transparent,
                  selectedIndex: currentIndex,
                  onDestinationSelected: onDestinationSelected,
                  destinations: destinations,
                ),
              ),
              if (onSettingsPressed != null)
                ListTile(
                  onTap: onSettingsPressed,
                  leading: const Icon(Icons.tune_rounded),
                  title: Text(settingsLabel),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FlowTokens.space3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      FlowTokens.radiusMedium,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
