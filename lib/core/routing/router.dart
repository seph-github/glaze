// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/core/routing/nested_navigation_scaffold.dart';
import 'package:glaze/feature/shops/shop_view.dart';
import 'package:glaze/feature/profile/views/profile_view.dart';
import 'package:glaze/repository/auth_repository/auth_repository_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:glaze/feature/auth/views/auth_view.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../feature/home/views/home_view.dart';
import '../../feature/moments/moments_view.dart';
import '../../feature/onboarding/providers/onboarding_provider.dart';
import '../../feature/onboarding/views/onboarding_view.dart';

part 'router.g.dart';

final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final momentsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'moments');
final premiumNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shop');
final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final router = GoRouter(
    // initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, child) {
          return NestedNavigationScaffold(
            navigationShell: child,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: HomeView(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: momentsNavigatorKey,
            routes: [
              GoRoute(
                path: '/moments',
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: MomentsView(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: premiumNavigatorKey,
            routes: [
              GoRoute(
                path: '/shop',
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: ShopView(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileView(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthView(),
      ),
      ...$appRoutes,
    ],
    redirect: (context, state) async {
      final User? user = await ref.read(authServiceProvider).getCurrentUser();
      final String path = state.matchedLocation;
      final bool hasCompletedOnboarding =
          ref.read(onboardingProvider).completeOnBoarding;
      // if (path != const AuthRoute().location && user == null) {
      //   return const HomeRoute().location;
      // }
      log('router redirect: $path, $user, on boarding completed $hasCompletedOnboarding');

      if (path == '/' && !hasCompletedOnboarding) {
        return const OnboardingRoute().location;
      }

      if (path == '/profile' && user == null) {
        return const AuthRoute().location;
      }

      return null;
    },
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
            router.go(const HomeRoute().location);
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

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OnboardingView();
}

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeView();
}

@TypedGoRoute<AuthRoute>(path: '/auth')
class AuthRoute extends GoRouteData {
  const AuthRoute();

  // final String? redirectUri;

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
        return const AuthView();
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

// @TypedGoRoute<UploadRoute>(path: '/upload')
// class UploadRoute extends GoRouteData {
//   const UploadRoute();

//   @override
//   Widget build(BuildContext context, GoRouterState state) {
//     return Consumer(
//       builder: (context, ref, child) {
//         return authGuard(context, state, () => const Placeholder(), ref);
//       },
//     );
//   }
// }

// @TypedGoRoute<GlazeRoute>(path: '/glaze')
// class GlazeRoute extends GoRouteData {
//   const GlazeRoute();

//   @override
//   Widget build(BuildContext context, GoRouterState state) {
//     return Consumer(
//       builder: (context, ref, child) {
//         return authGuard(context, state, () => const Placeholder(), ref);
//       },
//     );
//   }
// }

@TypedGoRoute<ProfileRoute>(path: '/profile')
class ProfileRoute extends GoRouteData {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileView();
  }
}
