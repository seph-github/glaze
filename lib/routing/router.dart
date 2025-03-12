import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/feature/auth/providers/auth_service_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:glaze/feature/home/home_page.dart';
import 'package:glaze/feature/auth/views/auth_view.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_guard/auth_guard.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: $appRoutes,
  );
}

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {
  const LoginRoute({this.redirectUri});

  final String? redirectUri;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AuthView(redirect: redirectUri);
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
