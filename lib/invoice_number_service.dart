import 'package:shared_preferences/shared_preferences.dart';

class InvoiceNumberService {
  static const String _key = 'last_invoice_number';
  static const int _defaultNumber = 693;
  static const String _prefix = '2026-INV';

  /// Load the last stored invoice number (numeric part only).
  static Future<int> getLastInvoiceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? _defaultNumber;
  }

  /// Persist the invoice number (numeric part only).
  static Future<void> saveInvoiceNumber(int number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, number);
  }

  /// Format a number into the full invoice string, e.g. `2025-INV00693`.
  /// Uses 5-digit zero padding but expands naturally beyond 99999.
  static String formatFull(int number) {
    final padded = number.toString().padLeft(5, '0');
    return '$_prefix$padded';
  }

  /// Extract the numeric suffix from a full invoice string.
  /// E.g. `2025-INV00693` → 693, `2025-INV00700` → 700.
  /// Returns [_defaultNumber] if parsing fails.
  static int parseNumber(String invoiceString) {
    final idx = invoiceString.indexOf('INV');
    if (idx != -1 && idx + 3 < invoiceString.length) {
      return int.tryParse(invoiceString.substring(idx + 3)) ?? _defaultNumber;
    }
    // Fallback: try to parse trailing digits
    final match = RegExp(r'(\d+)$').firstMatch(invoiceString);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? _defaultNumber;
    }
    return _defaultNumber;
  }
}
