import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/feature/profile/provider/profile_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';

class PersonalDetailsView extends StatelessWidget {
  const PersonalDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final state = ref.watch(profileNotifierProvider);

      final profile = state.profile;
      print('profile $profile');
      return LoadingLayout(
        isLoading: state.isLoading,
        appBar: AppBarWithBackButton(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Personal Details'),
          centerTitle: true,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(16.0),
                Text(
                  'My Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Gap(8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Table(
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                            child: Text(
                              'Full Name:',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ColorPallete.hintTextColor),
                            ),
                          ),
                          TableCell(
                            child: Text(
                              profile?.fullName ?? '',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: Text(
                              'Date of Birth:',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ColorPallete.hintTextColor),
                            ),
                          ),
                          TableCell(
                            child: Text(
                              'July 04, 1989',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: Text(
                              'Nationality:',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ColorPallete.hintTextColor),
                            ),
                          ),
                          TableCell(
                            child: Text(
                              'American',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: Text(
                              'Address:',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ColorPallete.hintTextColor),
                            ),
                          ),
                          TableCell(
                            child: Text(
                              'California, USA',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: Text(
                              'Phone Number:',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ColorPallete.hintTextColor),
                            ),
                          ),
                          TableCell(
                            child: Text(
                              profile?.phoneNumber ?? '',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: Text(
                              'Email Address:',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ColorPallete.hintTextColor),
                            ),
                          ),
                          TableCell(
                            child: Text(
                              profile?.email ?? '',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
