// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/core/navigation/observer/route_observer_provider.dart';
import 'package:glaze/features/auth/views/auth_forget_password_view.dart';
import 'package:glaze/features/auth/views/auth_reset_password_view.dart';
import 'package:glaze/features/challenges/models/challenge/challenge.dart';
import 'package:glaze/features/challenges/views/challenge_details_view.dart';
import 'package:glaze/features/challenges/views/challenge_leaderboard_view.dart';
import 'package:glaze/features/challenges/views/challenge_submit_entry.dart';
import 'package:glaze/features/dashboard/views/dashboard_view.dart';
import 'package:glaze/features/profile/views/profile_edit_form.dart';
import 'package:glaze/features/profile/views/profile_interactive_view.dart';
import 'package:glaze/features/settings/views/terms_and_condition_view.dart';
import 'package:glaze/features/shop/models/shop_product/shop_product.dart';
import 'package:glaze/features/shop/views/checkout_view.dart';
import 'package:glaze/features/shop/views/shop_view.dart';
import 'package:glaze/features/profile/views/profile_view.dart';
import 'package:glaze/features/video/view/video_preview_view.dart';
import 'package:go_router/go_router.dart';
import 'package:glaze/features/auth/views/auth_view.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/auth_state_change_provider.dart';
import '../../features/auth/services/auth_services.dart';
import '../../features/auth/views/auth_phone_sign_in.dart';
import '../../features/auth/views/auth_verify_phone.dart';
import '../../features/home/models/video_content/video_content.dart';
import '../../features/home/views/video_feed_view.dart';
import '../../features/moments/views/moments_view.dart';
import '../../features/onboarding/views/onboarding_view.dart';
import '../../features/profile/models/profile/profile.dart';
import '../../features/profile/views/profile_completion_form.dart';
import '../../features/profile/views/view_user_profile.dart';
import '../../features/settings/views/personal_details_view.dart';
import '../../features/splash/providers/splash_provider.dart';
import '../../features/splash/views/splash_view.dart';
import '../../features/settings/views/general_settings_view.dart';

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
    final hasSplashCompleted = ref.read(splashProvider).completeSplash;
    final bool isCompletedProfile = user?.userMetadata?['is_profile_complete'] ?? false;
    final bool isOnBoardingCompleted = user?.userMetadata?['is_onboarding_complete'] ?? false;
    final destination = state.fullPath;

    if (!hasSplashCompleted) {
      return const SplashRoute().location;
    }

    if (user == null) {
      if (destination!.contains('/auth/phone-sign-in')) {
        return const AuthPhoneSignInRoute().location;
      } else if (destination.contains('/auth/forget-password')) {
        return const AuthForgetPasswordRoute().location;
      } else if (destination.contains('/auth/reset-password')) {
        return const AuthResetPasswordRoute().location;
      } else if (destination.contains('/auth/verify-phone')) {
        return const AuthVerifyPhoneRoute().location;
      }
      return const AuthRoute().location;
    }

    if (!isOnBoardingCompleted) {
      return OnboardingRoute(id: user.id).location;
    }

    if (!isCompletedProfile) {
      return ProfileCompletionFormRoute(id: user.id, role: user.role as String).location;
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
              router.replace(const AuthRoute().location);
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
          // routes: [
          //   TypedGoRoute<GeneralSettingsRoute>(
          //     path: 'settings',
          //     routes: [
          //       TypedGoRoute<PersonalDetailsRoute>(path: 'personal_details'),
          //       TypedGoRoute<TermsAndConditionRoute>(path: 'terms_and_conditions'),
          //     ],
          // )
          // ],
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
  const ViewUserProfileRoute(this.$extra, {required this.id});
  final VideoPlayerController? $extra;
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ViewUserProfile(
      id: id,
      controller: $extra,
    );
  }
}

@TypedGoRoute<GeneralSettingsRoute>(path: '/general-settings')
class GeneralSettingsRoute extends GoRouteData {
  const GeneralSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const GeneralSettingsView();
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
  const VideoPreviewRoute(this.$extra, {required this.initialIndex});
  final List<VideoContent> $extra;
  final int initialIndex;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return VideoPreviewView(
      videos: $extra,
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

@TypedGoRoute<PersonalDetailsRoute>(path: '/personal-details')
class PersonalDetailsRoute extends GoRouteData {
  const PersonalDetailsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PersonalDetailsView();
  }
}

@TypedGoRoute<TermsAndConditionRoute>(path: '/terms-and-conditions')
class TermsAndConditionRoute extends GoRouteData {
  const TermsAndConditionRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TermsAndConditionsPage();
  }
}

@TypedGoRoute<CheckoutRoute>(path: '/checkout')
class CheckoutRoute extends GoRouteData {
  const CheckoutRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final extra = state.extra as Map<String, dynamic>;
    final ShopProduct product = extra['product'];

    return CheckoutView(product: product);
  }
}

@TypedGoRoute<ChallengeDetailsRoute>(path: '/challenge-details')
class ChallengeDetailsRoute extends GoRouteData {
  const ChallengeDetailsRoute(
    this.$extra, {
    required this.useColor,
  });

  final Challenge $extra;
  final int useColor;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChallengeDetailsView(
      challenge: $extra,
      useColor: Color(useColor),
    );
  }
}

@TypedGoRoute<ChallengeLeaderboardRoute>(path: '/leaderboard')
class ChallengeLeaderboardRoute extends GoRouteData {
  const ChallengeLeaderboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ChallengeLeaderBoardView();
  }
}

@TypedGoRoute<ChallengeSubmitEntryRoute>(path: '/submit-entry')
class ChallengeSubmitEntryRoute extends GoRouteData {
  const ChallengeSubmitEntryRoute({
    required this.challengeId,
  });

  final String challengeId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChallengeSubmitEntry(challengeId: challengeId);
  }
}
