enum ProductType {
  featured(name: 'Featured'),
  subscription(name: 'Subscription'),
  donutBox(name: 'Donut Box'),
  bundle(name: 'Bundle');

  const ProductType({this.name = ''});

  final String name;
}
