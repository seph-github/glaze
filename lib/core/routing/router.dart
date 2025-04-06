// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/data/models/profile/recruiter_profile_model.dart';
import 'package:glaze/data/models/profile/user_model.dart';
import 'package:glaze/feature/dashboard/views/dashboard_view.dart';
import 'package:glaze/feature/profile/views/profile_user_form.dart';
import 'package:glaze/feature/shops/shop_view.dart';
import 'package:glaze/feature/profile/views/profile_view.dart';
import 'package:glaze/data/repository/auth_repository/auth_repository_provider.dart';
import 'package:glaze/data/repository/user_repository/user_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:glaze/feature/auth/views/auth_view.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/enum/profile_type.dart';
import '../../feature/challenges/views/challenges_view.dart';
import '../../feature/home/views/home_view.dart';
import '../../feature/moments/views/moments_view.dart';
import '../../feature/onboarding/views/onboarding_view.dart';
import '../../feature/profile/views/profile_recruiter_form.dart';
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
    final User? user = await ref.read(authServiceProvider).getCurrentUser();
    final UserModel? profile =
        await ref.read(userRepositoryProvider).fetchUser(id: user?.id);
    final RecruiterProfileModel? recruiterProfile = await ref
        .read(userRepositoryProvider)
        .fetchRecruiterProfile(id: user?.id);

    final String currentPath = state.matchedLocation;
    final bool hasSplashCompleted = ref.read(splashProvider).completeSplash;

    log('router redirect: $currentPath, user: ${user != null}, role: ${profile?.role}, splash completed: $hasSplashCompleted');

    // Step 1: Ensure splash screen is completed
    if (!hasSplashCompleted) {
      return const SplashRoute().location;
    }

    // Step 2: Navigate to auth screen if user is not authenticated
    if (user == null) {
      return const AuthRoute().location;
    }

    // Step 3: Check user role and redirect accordingly
    if (profile?.role == ProfileType.recruiter.value &&
        profile?.isOnboardingCompleted == false &&
        recruiterProfile?.isProfileCompleted == false) {
      return ProfileRecruiterFormRoute(id: user.id).location;
    } else if (profile?.role == ProfileType.recruiter.value &&
        profile?.isOnboardingCompleted == false &&
        recruiterProfile?.isProfileCompleted == true) {
      return OnboardingRoute(id: user.id).location;
    } else if (profile?.role == ProfileType.user.value &&
        profile?.isOnboardingCompleted == false) {
      return OnboardingRoute(id: user.id).location;
    }

    // Step 4: Default to home/dashboard if the user is authenticated
    if (currentPath == const SplashRoute().location &&
        (profile?.role == 'recruiter' || profile?.role == 'user') &&
        profile?.isOnboardingCompleted == true) {
      return const HomeRoute().location;
    }

    if (currentPath == const HomeRoute().location) {
      return null;
    }

    return null;
  }

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: const SplashRoute().location,
    debugLogDiagnostics: true,
    routes: $appRoutes,
    redirect: redirect,
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
            router.go(const HomeRoute().location);
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

@TypedGoRoute<AuthRoute>(path: '/auth')
class AuthRoute extends GoRouteData {
  const AuthRoute();

  // final String? redirectUri;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // return Consumer(
    //   builder: (context, ref, child) {
    //     User? isSignedIn;
    //     ref.watch(authServiceProvider).getCurrentUser().then(
    //           (value) async => isSignedIn = value,
    //         );
    //     if (isSignedIn != null) {
    //       WidgetsBinding.instance.addPostFrameCallback((_) {
    //         context.go('/');
    //       });
    //     }
    return const AuthView();
    // },
    // );
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

@TypedGoRoute<OnboardingRoute>(path: '/onboarding/:id')
class OnboardingRoute extends GoRouteData {
  const OnboardingRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) => OnboardingView(
        id: id,
      );
}

@TypedGoRoute<ProfileRecruiterFormRoute>(path: '/profile-recruiter-form/:id')
class ProfileRecruiterFormRoute extends GoRouteData {
  const ProfileRecruiterFormRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ProfileRecruiterForm(
        userId: id,
      );
}

@TypedGoRoute<ProfileUserFormRoute>(path: '/user-profile/:id')
class ProfileUserFormRoute extends GoRouteData {
  const ProfileUserFormRoute({required this.id});
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProfileUserForm(
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
