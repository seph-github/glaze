import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/styles/color_pallete.dart';
import '../../data/models/category/category_model.dart';
import '../../features/category/provider/category_provider.dart';
import '../../features/moments/widgets/upload_moments_card.dart';
import '../../features/profile/provider/profile_interests_list_provider/profile_interests_list_provider.dart';

class GlazeModal {
  const GlazeModal._();

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
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final size = MediaQuery.of(ctx).size;

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, controller) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: SizedBox(
              height: size.height - kToolbarHeight,
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inverseSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select a Category',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: categoryState.categories.length,
                      itemBuilder: (ctx, index) {
                        return ListTile(
                          title: Text(
                            categoryState.categories[index].name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          onTap: () {
                            categoryController.text = categoryState.categories[index].name;
                            Navigator.pop(ctx);
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

  static Future<void> showUploadContentModalPopUp(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return RepaintBoundary(
          child: SafeArea(
            bottom: false,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: const UploadMomentsCard(),
            ),
          ),
        );
      },
    );
  }
}
