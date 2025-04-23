import 'package:flutter/material.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/app_bar_with_back_button.dart';

class AuthForgetPasswordView extends HookConsumerWidget {
  const AuthForgetPasswordView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    return LoadingLayout(
      appBar: AppBarWithBackButton(
        onBackButtonPressed: () {
          router.pop();
        },
      ),
      child: SafeArea(
        child: Container(
          child: Column(),
        ),
      ),
    );
  }
}
