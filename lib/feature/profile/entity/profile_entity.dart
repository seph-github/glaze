class ProfileEntity {
  final String id;
  final String? username;
  final String? email;
  final String? profileImageUrl;
  final String? bio;
  final int? totalGlazes;
  final int? totalUploads;
  final Map<String, dynamic>? badges;
  final DateTime? createdAt;
  final String? provider;
  final int? totalFollowers;
  final int? totalFollowing;
  final String? usernameId;
  final String? role;
  final String? countryCode;
  final String? phoneNumber;
  final bool? isOnboardingCompleted;
  final String? fullName;
  final List<String>? interests;
  final bool? isCompletedProfile;
  final DateTime? updatedAt;

  ProfileEntity({
    required this.id,
    this.username,
    this.email,
    this.profileImageUrl,
    this.bio,
    this.totalGlazes,
    this.totalUploads,
    this.badges,
    this.createdAt,
    this.provider,
    this.totalFollowers,
    this.totalFollowing,
    this.usernameId,
    this.role,
    this.countryCode,
    this.phoneNumber,
    this.isOnboardingCompleted,
    this.fullName,
    this.interests,
    this.isCompletedProfile,
    this.updatedAt,
  });

  // Method to convert an instance to a Map and remove null values
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'id': id,
      'username': username,
      'email': email,
      'profile_image_url': profileImageUrl,
      'bio': bio,
      'total_glazes': totalGlazes,
      'total_uploads': totalUploads,
      'badges': badges,
      'created_at': createdAt?.toIso8601String(),
      'provider': provider,
      'total_followers': totalFollowers,
      'total_following': totalFollowing,
      'username_id': usernameId,
      'role': role,
      'country_code': countryCode,
      'phone_number': phoneNumber,
      'is_onboarding_completed': isOnboardingCompleted,
      'full_name': fullName,
      'interests': interests,
      'is_completed_profile': isCompletedProfile,
      'updated_at': updatedAt?.toIso8601String(),
    };

    // Remove keys with null values
    map.removeWhere((key, value) => value == null);

    return map;
  }
}
