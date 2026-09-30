import 'package:flutter/material.dart';

import 'package:flowstate/design/tokens.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({required this.title, required this.message, super.key});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(FlowTokens.space8),
      child: Column(
        children: <Widget>[
          Icon(Icons.auto_awesome_outlined, size: FlowTokens.space8),
          const SizedBox(height: FlowTokens.space3),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: FlowTokens.space2),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
