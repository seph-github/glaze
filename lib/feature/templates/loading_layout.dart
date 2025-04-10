import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lottie/lottie.dart';

class LoadingLayout extends HookWidget {
  const LoadingLayout({
    super.key,
    this.child,
    this.isLoading = false,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  final Widget? child;
  final bool isLoading;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      appBar: appBar,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          if (child != null) child!,
          if (isLoading) ...[
            Container(
              color: Colors.black.withValues(
                alpha: 0.5,
              ),
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
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
