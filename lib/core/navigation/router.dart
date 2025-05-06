// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/core/navigation/observer/route_observer_provider.dart';
import 'package:glaze/feature/auth/providers/auth_provider.dart';
import 'package:glaze/feature/auth/views/auth_forget_password_view.dart';
import 'package:glaze/feature/auth/views/auth_reset_password_view.dart';
import 'package:glaze/feature/dashboard/views/dashboard_view.dart';
import 'package:glaze/feature/profile/provider/user_profile_provider.dart';
import 'package:glaze/feature/profile/views/profile_edit_form.dart';
import 'package:glaze/feature/profile/views/profile_interactive_view.dart';
import 'package:glaze/feature/settings/views/terms_and_condition_view.dart';
import 'package:glaze/feature/shop/views/shop_view.dart';
import 'package:glaze/feature/profile/views/profile_view.dart';
import 'package:glaze/feature/video/view/video_preview_view.dart';
import 'package:go_router/go_router.dart';
import 'package:glaze/feature/auth/views/auth_view.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

import '../../config/enum/profile_type.dart';
import '../../feature/auth/providers/auth_state_change_provider.dart';
import '../../feature/auth/services/auth_services.dart';
import '../../feature/auth/views/auth_phone_sign_in.dart';
import '../../feature/auth/views/auth_verify_phone.dart';
import '../../feature/challenges/views/challenges_view.dart';
import '../../feature/home/models/video_content/video_content.dart';
import '../../feature/home/views/video_feed_view.dart';
import '../../feature/moments/views/moments_view.dart';
import '../../feature/onboarding/views/onboarding_view.dart';
import '../../feature/profile/models/profile.dart';
import '../../feature/profile/views/profile_completion_form.dart';
import '../../feature/profile/views/view_user_profile.dart';
import '../../feature/settings/views/personal_details_view.dart';
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
  final routeObserver = ref.watch(routeObserverProvider);

  FutureOr<String?> redirect(BuildContext context, GoRouterState state) async {
    final User? user = AuthServices().currentUser;
    final Profile? profile = ref.watch(userProfileProvider).value;
    // print('profile $profile');

    final String currentPath = state.matchedLocation;
    final bool hasSplashCompleted = ref.read(splashProvider).completeSplash;

    if (!hasSplashCompleted) {
      return const SplashRoute().location;
    }

    if (user == null) {
      if (currentPath.startsWith(const AuthRoute().location)) {
        return null;
      }
      return const AuthRoute().location;
    }

    if (currentPath == const HomeRoute().location && profile?.isCompletedProfile == false) {
      return ProfileCompletionFormRoute(id: user.id, role: profile?.role ?? ProfileType.user.value).location;
    }

    return null;
  }

  final session = Supabase.instance.client.auth.currentSession;

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: session == null ? const AuthRoute().location : const HomeRoute().location,
    debugLogDiagnostics: true,
    routes: $appRoutes,
    redirect: redirect,
    observers: [
      routeObserver
    ],
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
            final state = ref.watch(authNotifierProvider);

            if (state.authResponse == null && !state.isLoading) {
              router.go(
                const AuthRoute().location,
              );
            }

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
        TypedGoRoute<MomentsRoute>(
          path: '/moments',
          // routes: [
          //   TypedGoRoute<VideoPreviewRoute>(path: 'video-preview')
          // ],
        ),
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
        TypedGoRoute<ProfileRoute>(
          path: '/profile',
          routes: [
            TypedGoRoute<GeneralSettingsRoute>(
              path: 'settings',
              routes: [
                TypedGoRoute<PersonalDetailsRoute>(path: 'personal_details'),
                TypedGoRoute<TermsAndConditionRoute>(path: 'terms_and_conditions'),
              ],
            )
          ],
        ),
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
      child: VideoFeedView(),
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

// @TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const VideoFeedView();
  }
}

@TypedGoRoute<AuthRoute>(
  path: '/auth',
  routes: [
    TypedGoRoute<AuthPhoneSignInRoute>(path: 'phone-sign-in'),
    TypedGoRoute<AuthVerifyPhoneRoute>(path: 'verify-phone'),
    TypedGoRoute<AuthForgetPasswordRoute>(path: 'forget-password'),
    TypedGoRoute<AuthResetPasswordRoute>(path: 'reset-password'),
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

class AuthForgetPasswordRoute extends GoRouteData {
  const AuthForgetPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AuthForgetPasswordView();
  }
}

class AuthResetPasswordRoute extends GoRouteData {
  const AuthResetPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final token = state.uri.queryParameters['access_token'];
    final type = state.uri.queryParameters['type'];
    final email = state.uri.queryParameters['email'];
    final hash = state.uri.queryParameters['token_hash'];

    if (type == 'recovery' && token != null && email != null && hash != null) {
      return AuthResetPasswordView(
        accessToken: token,
        email: email,
        tokenHash: hash,
      );
    } else {
      return const Placeholder();
    }
  }
}

// @TypedGoRoute<ShopRoute>(path: '/shop')
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

// @TypedGoRoute<MomentsRoute>(path: '/moments')
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

// @TypedGoRoute<ProfileRoute>(path: '/profile')
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
    final Map<String, dynamic>? extras = state.extra as Map<String, dynamic>?;
    final VideoPlayerController? controller = extras?['controller'];

    return ViewUserProfile(
      id: id,
      controller: controller,
    );
  }
}

// @TypedGoRoute<GeneralSettingsRoute>(
//   path: '/general-settings',
//   routes: [
//     TypedGoRoute<PersonalDetailsRoute>(path: 'personal_details'),
//     TypedGoRoute<TermsAndConditionRoute>(path: 'terms_and_conditions'),
//   ],
// )
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

@TypedGoRoute<VideoPreviewRoute>(path: '/video-preview')
class VideoPreviewRoute extends GoRouteData {
  const VideoPreviewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final Map<String, dynamic>? extras = state.extra as Map<String, dynamic>?;
    final List<VideoContent> videos = extras?['videos'];
    final int initialIndex = extras?['initialIndex'];

    return VideoPreviewView(
      videos: videos,
      initialIndex: initialIndex,
    );
  }
}

@TypedGoRoute<ProfileInteractiveRoute>(path: '/interactive')
class ProfileInteractiveRoute extends GoRouteData {
  const ProfileInteractiveRoute({
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
    final List<Interact> followers = extras['followers'];
    final List<Interact> following = extras['following'];
    final List<Glaze> glazes = extras['glazes'];

    return ProfileInteractiveView(
      initialIndex: initialIndex,
      followers: followers,
      following: following,
      glazes: glazes,
    );
  }
}

class PersonalDetailsRoute extends GoRouteData {
  const PersonalDetailsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PersonalDetailsView();
  }
}

class TermsAndConditionRoute extends GoRouteData {
  const TermsAndConditionRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TermsAndConditionsPage();
  }
}
