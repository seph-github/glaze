import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/styles/color_pallete.dart';
import '../../data/models/category/category_model.dart';
import '../../feature/profile/provider/profile_interests_list_provider.dart';

class GlazeModal {
  static Future<void> showInterestListModal(
      BuildContext context, List<CategoryModel> interests) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: ColorPallete.inputFilledColor,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Consumer(
            builder: (context, ref, child) {
              final selectedInterests =
                  ref.watch(profileInterestsNotifierProvider);

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: interests.length,
                itemBuilder: (context, index) {
                  final interestName = interests[index].name;
                  final isSelected = selectedInterests.contains(interestName);

                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(interestName),
                    checkColor: ColorPallete.backgroundColor,
                    activeColor: ColorPallete.magenta,
                    selected: isSelected,
                    selectedTileColor: ColorPallete.inputFilledColor,
                    onChanged: (value) {
                      ref
                          .read(profileInterestsNotifierProvider.notifier)
                          .addToInterestList(interestName);
                      setState(() {});
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  static Future<void> showPermissionDeniedModal(
      BuildContext context, String permissionName) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: ColorPallete.inputFilledColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Permission Denied',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Please enable $permissionName permission in your device settings.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        );
      },
    );
  }
}
