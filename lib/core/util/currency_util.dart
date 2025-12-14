import 'package:intl/intl.dart';

class CurrencyUtil {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'VND',
    decimalDigits: 0,
  );

  static final _compactFormat = NumberFormat.compact(locale: 'vi_VN');

  static final _numberFormat = NumberFormat("#,##0", "vi_VN");

  /// Formats amount with currency symbol (e.g. 100.000 đ)
  static String format(num amount) {
    // Trimming the symbol manually if needed to match existing style "100.000 đ" vs "100.000đ"
    // NumberFormat.currency(symbol: 'đ') usually puts "100.000 đ"
    return _currencyFormat.format(amount);
  }

  /// Formats amount without currency symbol (e.g. 100.000)
  static String formatAmount(num amount) {
    return _numberFormat.format(amount);
  }

  /// Formats amount compactly (e.g. 1Tr, 100K)
  static String formatCompact(num amount) {
    return _compactFormat.format(amount);
  }
}
