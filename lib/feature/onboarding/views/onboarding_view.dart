import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/feature/auth/services/auth_services.dart';
import 'package:glaze/feature/profile/provider/profile_provider/profile_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../core/navigation/router.dart';
import '../../../core/styles/color_pallete.dart';
import '../provider/onboarding_provider.dart';

class OnboardingView extends HookWidget {
  const OnboardingView({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final Size size = MediaQuery.sizeOf(context);

    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(onboardingDataProvider);
        final index = ref.watch(onboardingDataNotifierProvider);

        Future<void> handleContinue({bool? skip = false}) async {
          final User? user = AuthServices().currentUser;

          if (index == state.length - 1 || skip == true) {
            await ref
                .read(profileNotifierProvider.notifier)
                .setFlagsCompleted(
                  id,
                  table: 'profiles',
                  column: 'id',
                  data: ({
                    'is_onboarding_completed': true,
                  }),
                )
                .then(
                  (_) => router.go(
                    ProfileCompletionFormRoute(id: user?.id as String, role: user?.userMetadata?['role'] as String).location,
                  ),
                );
          }
          ref.read(onboardingDataNotifierProvider.notifier).next();
        }

        return LoadingLayout(
          isLoading: ref.watch(profileNotifierProvider).isLoading,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async => await handleContinue(skip: true),
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Container(
                  height: size.height * 0.5,
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
                  onPressed: handleContinue,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
