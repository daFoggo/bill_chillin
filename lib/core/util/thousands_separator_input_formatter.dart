import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat.decimalPattern('vi_VN');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Handle "deletion" of separator
    if (oldValue.text.length > newValue.text.length) {
      // If we are deleting and the cursor is after a separator, we might want to delete the digit before it
      // But standard behavior is usually fine if we just reformat the raw number
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Parse the number
    int value = int.tryParse(newText) ?? 0;

    // Format it
    String formatted = _formatter.format(value);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
