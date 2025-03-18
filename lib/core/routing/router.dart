// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/feature/profile/views/profile_view.dart';
import 'package:glaze/repository/auth_service/auth_service_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:glaze/feature/auth/views/auth_view.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../feature/home/views/home_view.dart';
import 'auth_guard/auth_guard.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final router = GoRouter(
    initialLocation: '/',
    routes: $appRoutes,
    redirect: (context, state) async {
      final User? user = await ref.read(authServiceProvider).getCurrentUser();
      final String path = state.matchedLocation;
      if (path != const AuthRoute().location && user == null) {
        return const HomeRoute().location;
      }
      return null;
    },
    refreshListenable: _GoRouterRefreshStream(
      ref.watch(authServiceProvider).onAuthStateChange(),
    ),
  );
  ref.listen(
    authStateChangesProvider,
    (previous, next) {
      if (next is AsyncError) {
        router.go(const AuthRoute().location);
      }
      if (next case AsyncData(value: final auth)) {
        switch (auth.event) {
          case AuthChangeEvent.initialSession:
            log('initialSession');
            break;
          case AuthChangeEvent.passwordRecovery:
            log('passwordRecovery');
            break;
          case AuthChangeEvent.signedIn:
            log('signedIn');
            router.go(const HomeRoute().location);
            break;
          case AuthChangeEvent.signedOut:
            log('signedOut');
            router.go(const AuthRoute().location);
            break;
          case AuthChangeEvent.tokenRefreshed:
            log('tokenRefreshed');
            break;
          case AuthChangeEvent.userUpdated:
            log('userUpdated');
            throw UnimplementedError();
          case AuthChangeEvent.userDeleted:
            log('userDeleted');
            break;
          case AuthChangeEvent.mfaChallengeVerified:
            log('mfaChallengeVerified');

            break;
        }
      }
    },
  );
  return router;
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeView();
}

@TypedGoRoute<AuthRoute>(path: '/login')
class AuthRoute extends GoRouteData {
  const AuthRoute({this.redirectUri});

  final String? redirectUri;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return Consumer(
      builder: (context, ref, child) {
        User? isSignedIn;
        ref.watch(authServiceProvider).getCurrentUser().then(
              (value) async => isSignedIn = value,
            );
        if (isSignedIn != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/');
          });
        }
        return AuthView(redirect: redirectUri);
      },
    );
  }
}

@TypedGoRoute<RegisterRoute>(path: '/register')
class RegisterRoute extends GoRouteData {
  const RegisterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      // const RegisterPage();
      const Placeholder();
}

@TypedGoRoute<UploadRoute>(path: '/upload')
class UploadRoute extends GoRouteData {
  const UploadRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return Consumer(
      builder: (context, ref, child) {
        return authGuard(context, state, () => const Placeholder(), ref);
      },
    );
  }
}

@TypedGoRoute<GlazeRoute>(path: '/glaze')
class GlazeRoute extends GoRouteData {
  const GlazeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return Consumer(
      builder: (context, ref, child) {
        return authGuard(context, state, () => const Placeholder(), ref);
      },
    );
  }
}

@TypedGoRoute<ProfileRoute>(path: '/profile')
class ProfileRoute extends GoRouteData {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileView();
    // return Consumer(
    //   builder: (context, ref, child) {
    //     return authGuard(
    //       context,
    //       state,
    //       () => const ProfileView(),
    //       ref,
    //     );
    //   },
    // );
  }
}
