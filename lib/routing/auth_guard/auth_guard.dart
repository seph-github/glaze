import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../feature/auth/views/auth_view.dart';
import '../../providers/user_provider/user_provider.dart';

Widget authGuard(BuildContext context, GoRouterState state,
    Widget Function() builder, WidgetRef ref) {
  final user = ref.read(userProvider).value;
  if (user == null) {
    return AuthView(redirect: state.uri.toString());
  }
  return builder();
}
