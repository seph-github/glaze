import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/core/routing/router.dart';
import 'package:glaze/feature/splash/providers/splash_provider.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Image.asset(
                'assets/images/glaze_icon_logo.png',
                width: MediaQuery.of(context).size.width / 2,
              ),
              const Gap(15),
              const Text(
                'Create, share, and shine! Capture epic\nmoments, join challenges, and go viral!🚀',
              ),
              const Gap(20),
              Consumer(
                builder: (context, ref, _) {
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
                },
              ),
              const Gap(50),
            ],
          ),
        ),
      ),
    );
  }
}
