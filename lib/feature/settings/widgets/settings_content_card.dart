import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SettingsContentCard extends StatelessWidget {
  const SettingsContentCard({
    super.key,
    this.cardLabel,
    this.children,
  });

  final String? cardLabel;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Gap(16),
        Text(cardLabel ?? ''),
        const Gap(10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(32.0),
          ),
          child: Column(
            children: children ?? <Widget>[],
          ),
        ),
      ],
    );
  }
}
