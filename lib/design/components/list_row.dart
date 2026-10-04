import 'package:flutter/material.dart';

import 'package:flowstate/design/tokens.dart';

class ListRow extends StatelessWidget {
  const ListRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
    super.key,
    this.onTap,
    this.leading,
    this.showDivider = true,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback? onTap;
  final IconData? leading;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: FlowTokens.space2,
          ),
          minVerticalPadding: FlowTokens.space2,
          onTap: onTap,
          leading: leading == null
              ? null
              : Icon(leading, color: Theme.of(context).colorScheme.primary),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Text(
            trailing,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (showDivider) const Divider(indent: FlowTokens.space2),
      ],
    );
  }
}
