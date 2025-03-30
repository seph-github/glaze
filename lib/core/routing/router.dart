// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/core/nested_navigation_scaffold.dart';
import 'package:glaze/feature/onboarding/provider/onboarding_provider.dart';
import 'package:glaze/feature/shops/shop_view.dart';
import 'package:glaze/feature/profile/views/profile_view.dart';
import 'package:glaze/data/repository/auth_repository/auth_repository_provider.dart';
import 'package:glaze/data/repository/user_repository/user_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:glaze/feature/auth/views/auth_view.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../feature/challenges/views/challenges_view.dart';
import '../../feature/home/views/home_view.dart';
import '../../feature/moments/views/moments_view.dart';
import '../../feature/onboarding/views/onboarding_view.dart';
import '../../feature/profile/views/view_user_profile.dart';
import '../../feature/splash/providers/splash_provider.dart';
import '../../feature/splash/views/splash_view.dart';
import '../../feature/settings/views/general_settings_view.dart';

part 'router.g.dart';

final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final momentsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'moments');
final uploadMomentKey = GlobalKey<NavigatorState>(debugLabel: 'upload-moments');
final premiumNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shop');
final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final router = GoRouter(
    debugLogDiagnostics: true,
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
            navigatorKey: uploadMomentKey,
            routes: [
              GoRoute(
                path: '/upload-moments',
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: Placeholder(),
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
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: ProfileView(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      ...$appRoutes,
    ],
    redirect: (context, state) async {
      final User? user = await ref.read(authServiceProvider).getCurrentUser();
      final String path = state.matchedLocation;
      final bool hasSplashCompleted = ref.read(splashProvider).completeSplash;
      final bool hasCompletedOnboarding =
          ref.read(onboardingProvider).completeOnBoarding;

      log('router redirect: $path, user: ${user != null}, splash screen completed $hasSplashCompleted, on boarding completed $hasCompletedOnboarding');

      if (path == '/' && user == null && !hasSplashCompleted) {
        return const SplashRoute().location;
      }

      if (path == '/' && user == null && !hasCompletedOnboarding) {
        return const OnboardingRoute().location;
      }

      if (path == '/profile' && user == null) {
        return const AuthRoute().location;
      }

      // Ensure no unnecessary redirects to the home route
      // if (path == '/' && user != null) {
      //   return null;
      // }

      return null;
    },
  );

  ref.listen(
    authStateChangesProvider,
    (previous, next) async {
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
            ref.watch(userNotifierProvider);
            break;
          case AuthChangeEvent.signedOut:
            log('signedOut');
            ref.invalidate(userNotifierProvider);
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

@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashView();
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

@TypedGoRoute<ProfileRoute>(path: '/profile')
class ProfileRoute extends GoRouteData {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileView();
  }
}

@TypedGoRoute<ViewUserProfileRoute>(path: '/view-user-profile/:id')
class ViewUserProfileRoute extends GoRouteData {
  const ViewUserProfileRoute({required this.id});
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ViewUserProfile(id: id);
  }
}

@TypedGoRoute<GeneralSettingsRoute>(path: '/general-settings')
class GeneralSettingsRoute extends GoRouteData {
  const GeneralSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const GeneralSettingsView();
}

@TypedGoRoute<ChallengesRoute>(path: '/challenges')
class ChallengesRoute extends GoRouteData {
  const ChallengesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ChallengesView();
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OnboardingView();
}
