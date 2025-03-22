import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/core/routing/router.dart';
import 'package:glaze/feature/onboarding/providers/onboarding_provider.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Onboarding View'),
          Consumer(builder: (context, ref, _) {
            return PrimaryButton(
              label: 'Get Started',
              onPressed: () async {
                await ref
                    .read(onboardingProvider)
                    .setOnBoardingComplete(true)
                    .then(
                      (_) => ref.refresh(routerProvider),
                    );
              },
            );
          }),
        ],
      ),
    );
  }
}
