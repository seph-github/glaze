import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../components/dialogs/dialogs.dart';
import '../../../core/routing/router.dart';
import '../views/upload_moment_view.dart';

part 'home_controller_provider.g.dart';

@riverpod
HomeController homeController(Ref ref) {
  return HomeController();
}

class HomeController {
  void onUploadMoment(BuildContext context, {User? user}) async {
    final router = GoRouter.of(context);

    if (user != null && context.mounted) {
      return await Dialogs.showBottomDialog(
        context,
        child: UploadMoment(),
      );
    } else {
      if (context.mounted) {
        await Dialogs.createContentDialog(
          context,
          title: 'Error',
          content: 'You must logged in to upload a moment',
          onPressed: () {
            router.pushReplacement(const AuthRoute().location);
          },
        );
      }
    }
  }

  void onProfile(BuildContext context, {User? user}) async {
    final router = GoRouter.of(context);

    if (user != null && context.mounted) {
      router.push(const ProfileRoute().location);
    } else {
      if (context.mounted) {
        await Dialogs.createContentDialog(
          context,
          title: 'Error',
          content: 'You must logged in to upload a moment',
          onPressed: () {
            router.pushReplacement(const AuthRoute().location);
          },
        );
      }
    }
  }
}
