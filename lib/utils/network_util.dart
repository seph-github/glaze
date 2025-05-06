import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_util.g.dart';

@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connectivityResult(Ref ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged;
}
