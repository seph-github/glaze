import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/feature/profile/provider/profile_provider/profile_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';

class PersonalDetailsView extends StatelessWidget {
  const PersonalDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final state = ref.watch(profileNotifierProvider);

      final profile = state.profile;
      return LoadingLayout(
        isLoading: state.isLoading,
        appBar: const AppBarWithBackButton(
          title: Text('Personal Details'),
          centerTitle: true,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(16.0),
                Text(
                  'My Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Gap(8.0),
                _buildDetailItem(
                  context,
                  label: 'Full Name',
                  value: profile?.fullName ?? '',
                ),
                _buildDetailItem(
                  context,
                  label: 'Email',
                  value: profile?.email ?? '',
                ),
                _buildDetailItem(
                  context,
                  label: 'Username',
                  value: profile?.username ?? '',
                ),
                _buildDetailItem(
                  context,
                  label: 'Contact Number',
                  value: profile?.phoneNumber ?? '',
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDetailItem(BuildContext context, {required String label, String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Gap(8.0),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: ColorPallete.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Gap(4.0),
          Text(
            value ?? '',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(
            height: 4,
            color: ColorPallete.hintTextColor,
            thickness: 0.5,
          ),
        ],
      ),
    );
  }
}
