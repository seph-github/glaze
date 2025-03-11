class SubscriptionEntity {
  final String id;
  final String userId;
  final double price;
  final String status;
  final String duration;
  final DateTime? createdAt;

  SubscriptionEntity({
    required this.id,
    required this.userId,
    required this.price,
    required this.status,
    required this.duration,
    this.createdAt,
  });
}

class SubscriptionStatus {
  static const active = 'active';
  static const inactive = 'inactive';
  static const expired = 'expired';
}

class SubscriptionDuration {
  static const monthly = 'monthly';
  static const yearly = 'yearly';
}
