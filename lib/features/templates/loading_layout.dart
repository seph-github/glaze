import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glaze/gen/assets.gen.dart';

class LoadingLayout extends HookWidget {
  const LoadingLayout({
    super.key,
    this.child,
    this.isLoading = false,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomSheet,
  });

  final Widget? child;
  final bool isLoading;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomSheet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: appBar,
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
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
                child: Image.asset(
                  Assets.images.gif.donutLoading.path,
                ),
              ),
            ),
          ],
        ],
      ),
      bottomSheet: bottomSheet,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
