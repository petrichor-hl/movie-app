import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toVnFormat() {
    return '${day.twoDigits()}/${month.twoDigits()}/${year.twoDigits()}';
  }
}

extension IntExtension on int {
  String toVnCurrencyFormat() {
    return NumberFormat.currency(locale: 'vi_VN').format(this);
  }

  String toVnCurrencyWithoutSymbolFormat() {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '').format(this).trim();
  }

  String twoDigits() {
    if (this >= 10) return "$this";
    return "0$this";
  }
}
