import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/styles/color_pallete.dart';
import '../../data/models/category/category_model.dart';
import '../../feature/profile/provider/recruiter_interests_list_provider.dart';

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
                  ref.watch(recruiterInterestsNotifierProvider);

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
                          .read(recruiterInterestsNotifierProvider.notifier)
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
}
