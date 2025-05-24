import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/features/profile/models/feature/feature.dart';
import 'package:glaze/features/profile/provider/profile_provider/profile_provider.dart';
import 'package:glaze/features/templates/loading_layout.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserFeatureView extends ConsumerWidget {
  const UserFeatureView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Feature>? features = ref.watch(profileNotifierProvider).profile?.userFeatures;
    return LoadingLayout(
      isLoading: ref.watch(profileNotifierProvider).isLoading,
      appBar: const AppBarWithBackButton(
        title: Text('Features'),
        centerTitle: true,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: features!.map(
            (feature) {
              return Row(
                children: [
                  Text('Name: ${feature.name}'),
                  const Gap(12.0),
                  Text('Feature_key: ${feature.featureKey}'),
                ],
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
