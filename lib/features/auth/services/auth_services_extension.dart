part of 'auth_services.dart';

extension AuthServicesExtensions on AuthServices {
  Future<AuthResponse> _checkUserProfile(AuthResponse value) async {
    final user = value.user;

    if (user == null) return value;

    final response = await _supabase.from('profiles').select().eq('id', user.id).single();
    final Profile profile = Profile.fromJson(response);

    if (!value.user!.userMetadata!.containsKey('is_onboarding_complete')) {
      log('has no is onboarding');
      await _supabase.auth.updateUser(UserAttributes(data: {
        'is_onboarding_complete': profile.isOnboardingCompleted
      }));
    }

    if (!value.user!.userMetadata!.containsKey('is_profile_complete')) {
      log('has no  profile complete');
      await _supabase.auth.updateUser(UserAttributes(data: {
        'is_profile_complete': profile.isCompletedProfile
      }));
    }

    if (!value.user!.userMetadata!.containsKey('role')) {
      log('has no is role');
      await _supabase.auth.updateUser(UserAttributes(data: {
        'role': profile.role ?? ProfileType.user.value
      }));
    }

    if (!value.user!.userMetadata!.containsKey('is_onboarding_complete') && !value.user!.userMetadata!.containsKey('is_profile_complete') && !value.user!.userMetadata!.containsKey('role')) {
      log('has nothing');
      await _supabase.auth.updateUser(
        UserAttributes(data: rawUserMetaData(profileType: ProfileType.user)),
      );
    }

    return value;
  }

  Future<AuthResponse> _checkUserFeature(AuthResponse value) async {
    final String userId = value.user!.id;

    final result = await _supabase.from('user_active_features').select().eq('user_id', userId);

    if (result.isEmpty) {
      await _supabase.rpc(
        'assign_free_features_to_user',
        params: {
          'new_user_id': userId
        },
      );
    }

    return value;
  }

  String generateCodeVerifier() {
    final random = Random.secure();

    const length = 128;
    // Length of the code verifier

    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  String createCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);

    final digest = sha256.convert(bytes);

    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  Future<void> storeCodeVerifier() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Generate code verifier
    final codeVerifier = generateCodeVerifier();

    // Store in local storage
    await prefs.setString('supabase.auth.token-code-verifier', codeVerifier);
  }
}
