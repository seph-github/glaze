import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/data/repository/user_repository/user_repository.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../core/routing/router.dart';
import '../../../core/styles/color_pallete.dart';
import '../provider/onboarding_provider.dart';

class OnboardingView extends ConsumerWidget {
  const OnboardingView({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingDataProvider);
    final index = ref.watch(onboardingDataNotifierProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Container(
              height: 450.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: ColorPallete.lightBackgroundColor,
                border: Border.all(
                  color: ColorPallete.borderColor,
                  width: 0.25,
                ),
              ),
              child: SvgPicture.asset(state[index]['image'] as String),
            ),
            const Gap(24.0),
            Text(
              state[index]['title'] as String,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              state[index]['subtitle'] as String,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: ColorPallete.hintTextColor,
                  ),
            ),
            const Gap(32.0),
            PrimaryButton(
              label: 'Continue',
              onPressed: () async {
                if (index == state.length - 1) {
                  await ref.read(userRepositoryProvider).setFlagsCompleted(
                    id: '1',
                    table: 'profiles',
                    data: {
                      'is_onboarding_completed': true,
                    },
                  ).then(
                    (_) => ref.refresh(routerProvider),
                  );
                }
                ref.read(onboardingDataNotifierProvider.notifier).next();
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Skip',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Container(
              height: 60.0,
              width: 60.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ColorPallete.borderColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  Text(
                    '/${state.length}',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
