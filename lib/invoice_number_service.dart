import 'package:shared_preferences/shared_preferences.dart';

class InvoiceNumberService {
  static const String _keyInv = 'last_invoice_number';
  static const String _keyRef = 'last_reference_number';
  static const String _keyInvConsumed = 'invoice_consumed';
  static const String _keyRefConsumed = 'reference_consumed';
  
  static const int _defaultNumber = 748;
  static const String _prefixInv = '2026-INV';
  static const String _prefixRef = 'ZPI2026-';

  /// Load the last stored invoice number.
  static Future<int> getLastInvoiceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyInv) ?? _defaultNumber;
  }

  /// Whether the current invoice number was already used in a report.
  static Future<bool> isInvoiceConsumed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyInvConsumed) ?? false;
  }

  /// Persist the invoice number and mark it as NOT consumed (new baseline).
  static Future<void> saveInvoiceNumber(int number, {bool consumed = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyInv, number);
    await prefs.setBool(_keyInvConsumed, consumed);
  }

  /// Mark the current invoice number as used.
  static Future<void> markInvoiceConsumed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyInvConsumed, true);
  }

  /// Load the last stored reference number.
  static Future<int> getLastReferenceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyRef) ?? _defaultNumber;
  }

  /// Whether the current reference number was already used in a report.
  static Future<bool> isReferenceConsumed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRefConsumed) ?? false;
  }

  /// Persist the reference number and mark it as NOT consumed (new baseline).
  static Future<void> saveReferenceNumber(int number, {bool consumed = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRef, number);
    await prefs.setBool(_keyRefConsumed, consumed);
  }

  /// Mark the current reference number as used.
  static Future<void> markReferenceConsumed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRefConsumed, true);
  }

  /// Format a number into the full invoice string, e.g. `2026-INV00748`.
  static String formatFull(int number) {
    final padded = number.toString().padLeft(5, '0');
    return '$_prefixInv$padded';
  }

  /// Format a number into the full reference string, e.g. `ZPI2026-00748`.
  static String formatRef(int number) {
    final padded = number.toString().padLeft(5, '0');
    return '$_prefixRef$padded';
  }

  /// Extract the numeric suffix from any string ending in digits or containing INV.
  /// E.g. `2025-INV00748` → 793, `ZPI2026-00700` → 700.
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
