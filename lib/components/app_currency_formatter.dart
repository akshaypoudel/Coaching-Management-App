import 'package:intl/intl.dart';

class AppFormatter {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String formatCurrency(num amount) {
    return _currency.format(amount);
  }
}
