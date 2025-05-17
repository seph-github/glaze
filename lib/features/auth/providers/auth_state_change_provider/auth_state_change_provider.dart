import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth_services.dart';

part 'auth_state_change_provider.g.dart';

@riverpod
Stream<AuthState> authStateChange(Ref ref) {
  return AuthServices().onAuthStateChange();
}
