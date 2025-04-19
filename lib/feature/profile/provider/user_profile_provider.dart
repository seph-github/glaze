import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/services/auth_services.dart';
import '../models/profile.dart';
import '../services/profile_services.dart';

part 'user_profile_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Profile?> userProfile(ref) async {
  final user = AuthServices().currentUser;
  if (user == null) return null;
  return await ProfileServices().fetchUserProfile(user.id);
}
