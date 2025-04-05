class RecruiterProfileEntity {
  final String? fullName;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? organization;
  final List<String>? interests;
  final String? identificationUrl;
  final bool? isVerified;
  final String? subscriptionStatus;
  final DateTime? subscriptionStartedAt;
  final DateTime? subscriptionExpiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isProfileCompleted;

  RecruiterProfileEntity({
    this.fullName,
    this.username,
    this.email,
    this.phoneNumber,
    this.organization,
    this.interests,
    this.identificationUrl,
    this.isVerified,
    this.subscriptionStatus,
    this.subscriptionStartedAt,
    this.subscriptionExpiresAt,
    this.createdAt,
    this.updatedAt,
    this.isProfileCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'organization': organization,
      'interests': interests,
      'identification_url': identificationUrl,
      'is_verified': isVerified,
      'subscription_status': subscriptionStatus,
      'subscription_started_at': subscriptionStartedAt?.toIso8601String(),
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'is_profile_completed': isProfileCompleted,
    };
  }
}
