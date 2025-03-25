import 'dart:ui';

import 'package:flutter/material.dart';

class MorphismWidget extends StatelessWidget {
  const MorphismWidget.circle({
    super.key,
    double? size,
    this.radius = 1,
    this.shape = BoxShape.circle,
    this.child,
  })  : width = size ?? 60,
        height = size ?? 60;

  const MorphismWidget.rounded({
    super.key,
    double? width,
    double? height,
    this.radius = 32.0,
    this.child,
    this.shape = BoxShape.rectangle,
  })  : width = width ?? double.infinity,
        height = height ?? 50;

  final double? width;
  final double? height;
  final BoxShape? shape;
  final double radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final BorderRadiusGeometry? borderRadiusGeometry =
        shape == BoxShape.circle ? null : BorderRadius.circular(radius);

    Widget? widget = BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 10,
        sigmaY: 10,
      ), // Glass blur effect
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          shape: shape!,
          borderRadius: borderRadiusGeometry,
          color: Colors.white
              .withValues(alpha: 0.1), // Semi-transparent glass color
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9), // Light border
            width: 0.01,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.9), // Shadow effect
              blurRadius: 30,
              spreadRadius: 2,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Glossy Highlight
            Container(
              height: (height! * 0.65),
              width: (width! * 0.9),
              margin: EdgeInsets.symmetric(horizontal: width! * 0.05),
              decoration: BoxDecoration(
                shape: shape!,
                borderRadius: borderRadiusGeometry,
                /*
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black87.withValues(alpha: 0.3),
                    Colors.black54.withValues(alpha: 0.1),
                  ],
                ),
                */
                boxShadow: [
                  BoxShadow(
                    blurRadius: height != null && width != null ? 3 : 0,
                    color: Colors.black12,
                    spreadRadius: height != null && width != null ? 10 : 0,
                    blurStyle: BlurStyle.inner,
                  ),
                ],
              ),
            ),
            if (child != null)
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationX(3.14159),
                child: Center(
                  child: child,
                ),
              ),
          ],
        ),
      ),
    );

    if (shape == BoxShape.circle) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationX(3.14159),
        child: ClipOval(
          child: widget,
        ),
      );
    }

    if (shape == BoxShape.rectangle) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationX(3.14159),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: widget,
        ),
      );
    }

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationX(3.14159),
      child: ClipRect(
        child: widget,
      ),
    );
  }
}
