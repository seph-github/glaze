import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/styles/color_pallete.dart';
import '../../data/models/category/category_model.dart';
import '../../feature/category/provider/category_provider.dart';
import '../../feature/profile/provider/profile_interests_list_provider/profile_interests_list_provider.dart';

class GlazeModal {
  static Future<void> showInterestListModal(BuildContext context, List<CategoryModel> interests) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: ColorPallete.inputFilledColor,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Consumer(
            builder: (context, ref, child) {
              final selectedInterests = ref.watch(profileInterestsNotifierProvider);

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
                      ref.read(profileInterestsNotifierProvider.notifier).addToInterestList(interestName);
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

  static Future<void> showPermissionDeniedModal(BuildContext context, String permissionName) {
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

  static Future<void> showCategoryModalPopup(
    BuildContext context,
    CategoryState categoryState,
    TextEditingController categoryController,
  ) {
    return showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        final size = MediaQuery.of(ctx).size;

        return CupertinoPopupSurface(
          child: Material(
            child: Container(
              height: size.height - kToolbarHeight, // Set height to half of the screen
              width: double.infinity,

              color: ColorPallete.backgroundColor,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Gap(16.0),
                  Text(
                    'Select a Category',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: categoryState.categories.length,
                      itemBuilder: (ctx, index) {
                        return ListTile(
                          title: Text(
                            categoryState.categories[index].name,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                          ),
                          onTap: () {
                            categoryController.text = categoryState.categories[index].name;
                            ctx.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
