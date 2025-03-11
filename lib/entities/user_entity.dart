class UserEntity {
  final String id;
  final String username;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final int? totalGlazes;
  final int? totalUploads;
  final String? badges;
  final DateTime? createdAt;

  UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.profileImageUrl,
    this.bio,
    this.totalGlazes,
    this.totalUploads,
    this.badges,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile_image_url': profileImageUrl,
      'bio': bio,
      'total_glazes': totalGlazes,
      'total_uploads': totalUploads,
      'badges': badges,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class UserEntityEmpty extends UserEntity {
  UserEntityEmpty()
      : super(
          id: '',
          username: '',
          email: '',
          profileImageUrl: '',
          bio: '',
          totalGlazes: 0,
          totalUploads: 0,
          badges: '',
          createdAt: DateTime.now(),
        );
}
