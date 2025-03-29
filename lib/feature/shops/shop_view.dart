import 'package:flutter/material.dart';

class ShopView extends StatelessWidget {
  const ShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: DarkCircleWidget(),
      ),
    );
  }
}

class DarkCircleWidget extends StatelessWidget {
  final double size;
  final double opacity;

  const DarkCircleWidget({super.key, this.size = 56.0, this.opacity = 0.8});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter, // Align circles to bottom-center
      children: [
        // Outer Solid White Circle with Increased Glow
        Container(
          width: size + 16, // Increase size to emphasize the outer circle
          height: size + 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.5), // Stronger white glow
          ),
        ),
        // Dark Circle with Gradient and Blur
        Container(
          width: 1,
          height: 1,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0xFF2C2C2C), // Dark center
                Color(0xFF1A1A1A), // Dark edges
              ],
              center: Alignment(0.0, 0.0),
              radius: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(0.8), // Inner shadow with opacity
                blurRadius: 70, // Stronger blur effect
                spreadRadius: 70,
                offset: Offset(2, 2), // Slight shadow offset
              ),
            ],
          ),
        ),
      ],
    );
  }
}
