import 'dart:ui';

import 'package:flutter/material.dart';

class Morphism extends StatelessWidget {
  const Morphism({
    super.key,
    this.child,
    double? size,
  }) : size = size ?? 150;

  final Widget? child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: size,
                width: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white70.withValues(
                    alpha: 0.05,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 10,
                      spreadRadius: 10,
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.2), // White border
                    width: 1,
                  ),
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
