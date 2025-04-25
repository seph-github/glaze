// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:glaze/repository/auth_service/auth_service_provider.dart';
// import 'package:go_router/go_router.dart';

// import '../../../feature/auth/views/auth_view.dart';

// Widget authGuard(BuildContext context, GoRouterState state,
//     Widget Function() builder, WidgetRef ref) {
//   final user = ref.read(authServiceProvider).getCurrentUser();

//   Widget widget = const SizedBox.shrink();

//   user.then(
//     (value) {
//       if (value != null) {
//         widget = AuthView(redirect: state.uri.toString());
//       }
//       widget = builder();
//     },
//   );

//   return widget;
// }
