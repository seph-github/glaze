enum SubscriptionStatus {
  active('active'),
  inactive('inactive'),
  cancelled('cancelled'),
  pending('pending');

  const SubscriptionStatus(this.name);
  final String name;
}
