import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/styles/color_pallete.dart';
import '../../../data/models/category/category_model.dart';

class InterestChoiceChip extends StatelessWidget {
  const InterestChoiceChip({
    super.key,
    required this.categories,
    this.selectedInterests,
    this.onSelected,
  });

  final List<CategoryModel> categories;
  final List<String>? selectedInterests;
  final void Function(String)? onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What are you interested in?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const Gap(10),
        Consumer(
          builder: (context, ref, _) {
            return Wrap(
              runAlignment: WrapAlignment.spaceEvenly,
              alignment: WrapAlignment.spaceAround,
              spacing: 4.0,
              direction: Axis.horizontal,
              children: categories.map(
                (category) {
                  final isSelected = selectedInterests?.contains(category.name);
                  return ChoiceChip(
                    label: Text(category.name),
                    selected: isSelected ?? false,
                    showCheckmark: false,
                    shape: const StadiumBorder(),
                    backgroundColor: Colors.transparent,
                    selectedColor: ColorPallete.magenta,
                    onSelected: (_) {
                      onSelected?.call(category.name);
                    },
                  );
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }
}
