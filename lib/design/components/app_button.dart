import 'package:flutter/material.dart';

import 'package:flowstate/design/tokens.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.secondary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final Widget child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon),
              const SizedBox(width: FlowTokens.space2),
              Text(label),
            ],
          );
    return secondary
        ? OutlinedButton(onPressed: onPressed, child: child)
        : FilledButton(onPressed: onPressed, child: child);
  }
}
