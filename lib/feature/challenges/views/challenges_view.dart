import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ChallengesView extends StatelessWidget {
  const ChallengesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Upcoming Challenges',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              'Stay tuned for exciting challenges to test your skills!',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey),
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }
}
