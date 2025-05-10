import 'package:intl/intl.dart';

String priceInDollars(dynamic price) {
  final formatCurrency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  return formatCurrency.format(price / 100);
}
