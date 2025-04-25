import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'route_observer_provider.g.dart';

@riverpod
RouteObserver<PageRoute> routeObserver(ref) {
  return RouteObserver<PageRoute>();
}
