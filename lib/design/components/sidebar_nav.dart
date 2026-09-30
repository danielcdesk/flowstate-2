import 'package:flutter/material.dart';

import 'package:flowstate/design/tokens.dart';

class SidebarNav extends StatelessWidget {
  const SidebarNav({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    super.key,
    this.rail = false,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationRailDestination> destinations;
  final bool rail;

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
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        width: FlowTokens.space8 * 5,
        child: NavigationRail(
          extended: true,
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations,
        ),
      ),
    );
  }
}
