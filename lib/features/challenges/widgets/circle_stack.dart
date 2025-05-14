import 'package:flutter/material.dart';
import 'package:glaze/features/challenges/widgets/circle_widget.dart';

class CircleStackPage extends StatelessWidget {
  const CircleStackPage({super.key, this.children});

  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    final childCount = children?.length ?? 4;
    final totalWidth = childCount > 1
        ? (childCount - 1) * 22.5 + 32 // assuming each widget is ~32px
        : 32;

    return SizedBox(
      height: 32,
      width: double.tryParse(totalWidth.toString()),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: List.generate(childCount, (index) {
          return Positioned(
            left: index * 22.5,
            child: children != null ? children![index] : const CircleWidget(),
          );
        }),
      ),
    );
  }
}
