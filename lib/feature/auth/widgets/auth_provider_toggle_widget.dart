import 'package:flutter/material.dart';

import '../../../core/styles/color_pallete.dart';

class AuthProviderToggleWidget extends StatelessWidget {
  const AuthProviderToggleWidget({
    super.key,
    required this.toggleItems,
    required this.itemsValue,
    required this.selectedIndex,
  });

  final ValueNotifier<List<String>> toggleItems;
  final ValueNotifier<List<bool>> itemsValue;
  final ValueNotifier<int> selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60.0,
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(62.0),
        color: Colors.white10,
      ),
      child: Row(
        children: toggleItems.value
            .map(
              (item) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (item == 'Email') {
                      itemsValue.value = [true, false];
                    } else {
                      itemsValue.value = [false, true];
                    }
                    selectedIndex.value = toggleItems.value.indexOf(item);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(62.0),
                      color:
                          selectedIndex.value == toggleItems.value.indexOf(item)
                              ? ColorPallete.backgroundColor
                              : Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: selectedIndex.value ==
                                  toggleItems.value.indexOf(item)
                              ? Colors.white
                              : ColorPallete.hintTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
