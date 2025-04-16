// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/feature/dashboard/views/dashboard_view.dart';
import 'package:glaze/feature/profile/provider/profile_provider.dart';
import 'package:glaze/feature/profile/views/profile_edit_form.dart';
import 'package:glaze/feature/shops/views/shop_view.dart';
import 'package:glaze/feature/profile/views/profile_view.dart';
import 'package:go_router/go_router.dart';
import 'package:glaze/feature/auth/views/auth_view.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../feature/auth/providers/auth_state_change_provider.dart';
import '../../feature/auth/services/auth_services.dart';
import '../../feature/auth/views/auth_phone_sign_in.dart';
import '../../feature/auth/views/auth_verify_phone.dart';
import '../../feature/challenges/views/challenges_view.dart';
import '../../feature/home/views/home_view.dart';
import '../../feature/moments/views/moments_view.dart';
import '../../feature/onboarding/views/onboarding_view.dart';
import '../../feature/profile/models/profile.dart';
import '../../feature/profile/services/profile_services.dart';
import '../../feature/profile/views/profile_completion_form.dart';
import '../../feature/profile/views/view_user_profile.dart';
import '../../feature/splash/providers/splash_provider.dart';
import '../../feature/splash/views/splash_view.dart';
import '../../feature/settings/views/general_settings_view.dart';

part 'router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final momentsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'moments');
final uploadMomentKey = GlobalKey<NavigatorState>(debugLabel: 'upload-moments');
final premiumNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shop');
final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) async {
    final User? user = AuthServices().currentUser;
    final Profile? profile = await ProfileServices().fetchUserProfile(user?.id ?? '');

    final String currentPath = state.matchedLocation;
    final bool hasSplashCompleted = ref.read(splashProvider).completeSplash;

    log('router redirect: $currentPath, user: ${user != null}, role: ${profile?.role}, completed profile: ${profile?.isCompletedProfile}, splash completed: $hasSplashCompleted');

    if (!hasSplashCompleted) {
      return const SplashRoute().location;
    }

    if (user == null) {
      // Allow access to /auth and /auth/phone-sign-in without redirecting back to /auth
      if (currentPath.startsWith(const AuthRoute().location)) {
        return null;
      }
      return const AuthRoute().location;
    }

    if (currentPath == const HomeRoute().location && profile?.isCompletedProfile == false) {
      return ProfileCompletionFormRoute(id: user.id, role: profile?.role ?? '').location;
    }

    // If the user is already on HomeRoute and the profile is complete, no redirection is needed.
    return null;
  }

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: $appRoutes,
    redirect: redirect,
  );

  ref.listen(
    authStateChangeProvider,
    (previous, next) async {
      if (next is AsyncError) {
        router.go(const AuthRoute().location);
      }
      if (next
          case AsyncData(
            value: final auth
          )) {
        switch (auth.event) {
          case AuthChangeEvent.initialSession:
            log('initialSession');
            break;
          case AuthChangeEvent.passwordRecovery:
            log('passwordRecovery');
            break;
          case AuthChangeEvent.signedIn:
            log('signedIn');
            router.pushReplacement(const HomeRoute().location);
            // ref.watch(userNotifierProvider);
            break;
          case AuthChangeEvent.signedOut:
            log('signedOut');
            ref.invalidate(profileNotifierProvider);
            router.pushReplacement(const AuthRoute().location);
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

@TypedStatefulShellRoute<DashboardShellRoute>(
  branches: [
    TypedStatefulShellBranch<HomeShellBranch>(
      routes: [
        TypedGoRoute<HomeRoute>(path: '/'),
      ],
    ),
    TypedStatefulShellBranch<MomentsShellBranch>(
      routes: [
        TypedGoRoute<MomentsRoute>(path: '/moments'),
      ],
    ),
    TypedStatefulShellBranch<NoViewShellBranch>(
      routes: [
        TypedGoRoute<NoViewRoute>(path: '/placeholder'),
      ],
    ),
    TypedStatefulShellBranch<ShopShellBranch>(
      routes: [
        TypedGoRoute<ShopRoute>(path: '/shop'),
      ],
    ),
    TypedStatefulShellBranch<ProfileShellBranch>(
      routes: [
        TypedGoRoute<ProfileRoute>(path: '/profile'),
      ],
    ),
  ],
)
class DashboardShellRoute extends StatefulShellRouteData {
  const DashboardShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return DashboardView(
      navigationShell: navigationShell,
    );
  }
}

class HomeShellBranch extends StatefulShellBranchData {
  NoTransitionPage builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return const NoTransitionPage(
      child: HomeView(),
    );
  }
}

class MomentsShellBranch extends StatefulShellBranchData {
  NoTransitionPage builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return const NoTransitionPage(
      child: MomentsView(),
    );
  }
}

class NoViewShellBranch extends StatefulShellBranchData {
  NoTransitionPage builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return const NoTransitionPage(
      child: Placeholder(),
    );
  }
}

class ShopShellBranch extends StatefulShellBranchData {
  NoTransitionPage builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return const NoTransitionPage(
      child: ShopView(),
    );
  }
}

class ProfileShellBranch extends StatefulShellBranchData {
  NoTransitionPage builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return const NoTransitionPage(
      child: ProfileView(),
    );
  }
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

@TypedGoRoute<AuthRoute>(
  path: '/auth',
  routes: [
    TypedGoRoute<AuthPhoneSignInRoute>(path: 'phone-sign-in'),
    TypedGoRoute<AuthVerifyPhoneRoute>(path: 'verify-phone'),
  ],
)
class AuthRoute extends GoRouteData {
  const AuthRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AuthView();
  }
}

class AuthPhoneSignInRoute extends GoRouteData {
  const AuthPhoneSignInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AuthPhoneSignIn();
  }
}

class AuthVerifyPhoneRoute extends GoRouteData {
  const AuthVerifyPhoneRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final extras = state.extra;
    final Map<String, String>? data = extras is Map<String, String> ? extras : null;
    final String phoneNumber = data?['phone'] ?? '';
    final String dialCode = data?['dialCode'] ?? '';
    log('AuthVerifyPhoneRoute: phoneNumber: $phoneNumber, dialCode: $dialCode');
    if (phoneNumber.isEmpty || dialCode.isEmpty) {
      return const Placeholder();
    }

    final String phoneNumberWithDialCode = '$dialCode$phoneNumber';
    log('AuthVerifyPhoneRoute: phoneNumberWithDialCode: $phoneNumberWithDialCode');

    return AuthVerifyPhone(
      phoneNumber: phoneNumberWithDialCode,
    );
  }
}

@TypedGoRoute<ShopRoute>(path: '/shop')
class ShopRoute extends GoRouteData {
  const ShopRoute();

  @override
  Widget build(
    BuildContext context,
    GoRouterState state,
  ) {
    return const ShopView();
  }
}

@TypedGoRoute<MomentsRoute>(path: '/moments')
class MomentsRoute extends GoRouteData {
  const MomentsRoute();

  @override
  Widget build(
    BuildContext context,
    GoRouterState state,
  ) {
    return const MomentsView();
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
  Widget build(BuildContext context, GoRouterState state) => const GeneralSettingsView();
}

@TypedGoRoute<ChallengesRoute>(path: '/challenges')
class ChallengesRoute extends GoRouteData {
  const ChallengesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ChallengesView();
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding/:id')
class OnboardingRoute extends GoRouteData {
  const OnboardingRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) => OnboardingView(
        id: id,
      );
}

@TypedGoRoute<ProfileCompletionFormRoute>(path: '/profile-recruiter-form/:id')
class ProfileCompletionFormRoute extends GoRouteData {
  const ProfileCompletionFormRoute({
    required this.id,
    required this.role,
  });

  final String id;
  final String role;

  @override
  Widget build(BuildContext context, GoRouterState state) => ProfileCompletionForm(
        userId: id,
        role: role,
      );
}

@TypedGoRoute<ProfileEditFormRoute>(path: '/edit-profile/:id')
class ProfileEditFormRoute extends GoRouteData {
  const ProfileEditFormRoute({required this.id});
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProfileEditForm(
      id: id,
    );
  }
}

@TypedGoRoute<NoViewRoute>(path: '/placeholder')
class NoViewRoute extends GoRouteData {
  const NoViewRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const Placeholder();
  }
}
