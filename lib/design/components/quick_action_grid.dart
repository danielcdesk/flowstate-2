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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 92,
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
                  Icon(action.icon, size: FlowTokens.tapTarget / 2),
                  const SizedBox(height: FlowTokens.space2),
                  Text(action.label, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
