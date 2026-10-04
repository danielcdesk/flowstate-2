import 'package:flutter/material.dart';

import 'package:flowstate/design/tokens.dart';

class QuickAction {
  const QuickAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
}

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({required this.actions, super.key});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth < 420 ? 2 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: FlowTokens.quickActionExtent,
            crossAxisSpacing: FlowTokens.space3,
            mainAxisSpacing: FlowTokens.space3,
          ),
          itemCount: actions.length,
          itemBuilder: (BuildContext context, int index) {
            final QuickAction action = actions[index];
            return Semantics(
              button: true,
              label: action.label,
              child: InkWell(
                onTap: action.onPressed,
                borderRadius: BorderRadius.circular(FlowTokens.radiusMedium),
                child: Padding(
                  padding: const EdgeInsets.all(FlowTokens.space2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(
                          width: FlowTokens.quickActionIconSize,
                          height: FlowTokens.quickActionIconSize,
                          child: Icon(
                            action.icon,
                            size: FlowTokens.iconSmall + FlowTokens.space2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: FlowTokens.space2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          action.label,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
