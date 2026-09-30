import 'package:flutter/material.dart';

import 'package:flowstate/design/components/flow_ring.dart';
import 'package:flowstate/design/tokens.dart';

class HeroStat extends StatelessWidget {
  const HeroStat({
    required this.title,
    required this.value,
    required this.progress,
    super.key,
  });

  final String title;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FlowTokens.space6),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: FlowTokens.space2),
                  Text(value, style: Theme.of(context).textTheme.displaySmall),
                ],
              ),
            ),
            FlowRing(
              progress: progress,
              semanticLabel: title,
              centerLabel: '${(progress * 100).round()}%',
              size: FlowTokens.space8 * 3,
            ),
          ],
        ),
      ),
    );
  }
}
