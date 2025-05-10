import 'package:intl/intl.dart';

String priceInDollars(dynamic price) {
  final formatCurrency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  return formatCurrency.format(price / 100);
}

String getPrizeText(String value) {
  if (value.isEmpty) return '';

  if (int.tryParse(value) is int) {
    return '\$${value.replaceAll('\$', '')}';
  } else {
    return value;
  }
}
