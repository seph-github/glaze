import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lottie/lottie.dart';
// import 'package:glaze/core/styles/color_pallete.dart';

class LoadingLayout extends HookWidget {
  const LoadingLayout({
    super.key,
    this.child,
    this.isLoading = false,
  });

  final Widget? child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          if (child != null) child!,
          if (isLoading) ...[
            Container(
              color: Colors.black.withValues(alpha: 0.5), // Darkened overlay
            ),
            Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: Lottie.asset(
                  'assets/lotties/donut_sprinkled.json',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
