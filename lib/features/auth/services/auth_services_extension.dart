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
}
