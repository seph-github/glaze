class RecruiterProfileEntity {
  final String id;
  final String? userId;
  final String? organization;
  final String? identificationUrl;
  final bool? isVerified;
  final String? subscriptionStatus;
  final DateTime? subscriptionStartedAt;
  final DateTime? subscriptionExpiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? username;
  final bool? isProfileCompleted;

  RecruiterProfileEntity({
    required this.id,
    this.userId,
    this.organization,
    this.identificationUrl,
    this.isVerified = false,
    this.subscriptionStatus,
    this.subscriptionStartedAt,
    this.subscriptionExpiresAt,
    this.createdAt,
    this.updatedAt,
    this.username,
    this.isProfileCompleted = false,
  });

  // Method to convert an instance to a Map and remove null values
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'id': id,
      'user_id': userId,
      'organization': organization,
      'identification_url': identificationUrl,
      'is_verified': isVerified,
      'subscription_status': subscriptionStatus,
      'subscription_started_at': subscriptionStartedAt?.toIso8601String(),
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'username': username,
      'is_profile_completed': isProfileCompleted,
    };

    // Remove keys with null values
    map.removeWhere((key, value) => value == null);

    return map;
  }
}
