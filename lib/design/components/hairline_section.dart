import 'package:flutter/material.dart';

import 'package:flowstate/design/tokens.dart';

class HairlineSection extends StatelessWidget {
  const HairlineSection({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Divider(height: 1),
        const SizedBox(height: FlowTokens.space4),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: FlowTokens.space2),
        child,
      ],
    );
  }
}
