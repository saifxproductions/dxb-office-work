import 'package:shared_preferences/shared_preferences.dart';

class InvoiceNumberService {
  static const String _keyInv = 'last_invoice_number';
  static const String _keyRef = 'last_reference_number';
  static const int _defaultNumber = 693;
  static const String _prefixInv = '2026-INV';
  static const String _prefixRef = 'ZPI2026-';

  /// Load the last stored invoice number (numeric part only).
  static Future<int> getLastInvoiceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyInv) ?? _defaultNumber;
  }

  /// Persist the invoice number (numeric part only).
  static Future<void> saveInvoiceNumber(int number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyInv, number);
  }

  /// Load the last stored reference number (numeric part only).
  static Future<int> getLastReferenceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyRef) ?? _defaultNumber;
  }

  /// Persist the reference number (numeric part only).
  static Future<void> saveReferenceNumber(int number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRef, number);
  }

  /// Format a number into the full invoice string, e.g. `2026-INV00693`.
  static String formatFull(int number) {
    final padded = number.toString().padLeft(5, '0');
    return '$_prefixInv$padded';
  }

  /// Format a number into the full reference string, e.g. `ZPI2026-00693`.
  static String formatRef(int number) {
    final padded = number.toString().padLeft(5, '0');
    return '$_prefixRef$padded';
  }

  /// Extract the numeric suffix from any string ending in digits or containing INV.
  /// E.g. `2025-INV00693` → 693, `ZPI2026-00700` → 700.
  /// Returns [_defaultNumber] if parsing fails.
  static int parseNumber(String input) {
    final idx = input.indexOf('INV');
    if (idx != -1 && idx + 3 < input.length) {
      return int.tryParse(input.substring(idx + 3)) ?? _defaultNumber;
    }
    // Fallback: try to parse trailing digits
    final match = RegExp(r'(\d+)$').firstMatch(input);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? _defaultNumber;
    }
    return _defaultNumber;
  }
}
