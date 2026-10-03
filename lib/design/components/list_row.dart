import 'package:flutter/material.dart';

import 'package:flowstate/design/tokens.dart';

class ListRow extends StatelessWidget {
  const ListRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
    super.key,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: FlowTokens.space2),
      onTap: onTap,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(trailing, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
