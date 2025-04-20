import 'package:flutter/material.dart';
import 'package:glaze/feature/challenges/widgets/circle_widget.dart';

class CircleStackPage extends StatelessWidget {
  const CircleStackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30, // Restrict height to avoid overflow
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerRight,
        children: List.generate(4, (index) {
          return Positioned(
            left: index * 22.5, // 3/4 overlap of 30 is 22.5
            child: const CircleWidget(),
          );
        }),
      ),
    );
  }
}
