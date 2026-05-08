library formatters;

import 'package:intl/intl.dart';
import 'package:mercados/core/constants/app_constants.dart';

// ---------------------------------------------------------------------------
// Private formatters (constructed once, reused)
// ---------------------------------------------------------------------------

NumberFormat _currencyFormatter({String? symbol}) => NumberFormat.currency(
      locale: AppConstants.currencyLocale,
      symbol: '${symbol ?? AppConstants.currencySymbol} ',
      decimalDigits: 2,
    );

final NumberFormat _percentFormatter = NumberFormat.decimalPercentPattern(
  locale: AppConstants.currencyLocale,
  decimalDigits: 1,
);

final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy', 'es_MX');
final DateFormat _timeFormatter = DateFormat('HH:mm', 'es_MX');
final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm', 'es_MX');
final DateFormat _dateTimeLongFormatter =
    DateFormat('dd \'de\' MMMM yyyy, HH:mm', 'es_MX');
final DateFormat _monthYearFormatter = DateFormat('MMMM yyyy', 'es_MX');
final DateFormat _dayOfWeekFormatter = DateFormat('EEEE', 'es_MX');
final DateFormat _iso8601Formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

// ---------------------------------------------------------------------------
// Currency / numeric formatting
// ---------------------------------------------------------------------------

/// Formats [amount] as a currency string using the app locale.
///
/// Example: `formatCurrency(1234.5)` → `"$ 1,234.50"`
String formatCurrency(double amount, {String? symbol}) =>
    _currencyFormatter(symbol: symbol).format(amount);

/// Formats [amount] as a compact currency (e.g. `"$ 1.2K"`, `"$ 3.5M"`).
String formatCurrencyCompact(double amount) {
  if (amount.abs() >= 1000000) {
    return '${AppConstants.currencySymbol} ${(amount / 1000000).toStringAsFixed(1)}M';
  }
  if (amount.abs() >= 1000) {
    return '${AppConstants.currencySymbol} ${(amount / 1000).toStringAsFixed(1)}K';
  }
  return formatCurrency(amount);
}

/// Formats a decimal [ratio] (0–1) as a percentage string.
///
/// Example: `formatPercent(0.165)` → `"16.5%"`
String formatPercent(double ratio) => _percentFormatter.format(ratio);

/// Formats a percentage already expressed as 0–100.
///
/// Example: `formatPercentValue(16.5)` → `"16.5%"`
String formatPercentValue(double value) => formatPercent(value / 100);

/// Formats an integer [quantity] with thousands separators.
///
/// Example: `formatQuantity(12500)` → `"12,500"`
String formatQuantity(int quantity) =>
    NumberFormat('#,##0', 'es_MX').format(quantity);

/// Formats a [double] quantity (e.g. weight in kg) with up to [decimals] places.
String formatNumber(double value, {int decimals = 2}) =>
    NumberFormat('#,##0.${'0' * decimals}', 'es_MX').format(value);

// ---------------------------------------------------------------------------
// Date / time formatting
// ---------------------------------------------------------------------------

/// Formats a [DateTime] as `dd/MM/yyyy`.
///
/// Example: `formatDate(DateTime(2024, 3, 7))` → `"07/03/2024"`
String formatDate(DateTime date) => _dateFormatter.format(date);

/// Formats a [DateTime] as `HH:mm`.
String formatTime(DateTime date) => _timeFormatter.format(date);

/// Formats a [DateTime] as `dd/MM/yyyy HH:mm`.
///
/// Example: `formatDateTime(...)` → `"07/03/2024 14:35"`
String formatDateTime(DateTime date) => _dateTimeFormatter.format(date);

/// Formats a [DateTime] in long human-readable form.
///
/// Example: `"7 de marzo 2024, 14:35"`
String formatDateTimeLong(DateTime date) =>
    _dateTimeLongFormatter.format(date);

/// Returns the month-year string, e.g. `"marzo 2024"`.
String formatMonthYear(DateTime date) => _monthYearFormatter.format(date);

/// Returns the day of week, e.g. `"jueves"`.
String formatDayOfWeek(DateTime date) => _dayOfWeekFormatter.format(date);

/// Returns an ISO-8601 representation without timezone suffix.
String formatIso8601(DateTime date) => _iso8601Formatter.format(date);

/// Returns a relative time label suitable for feeds/lists.
///
/// - Same day: `"HH:mm"`
/// - Yesterday: `"Ayer"`
/// - Within the last 7 days: day of week
/// - Otherwise: `dd/MM/yyyy`
String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = today.difference(target).inDays;

  if (diff == 0) return formatTime(date);
  if (diff == 1) return 'Ayer';
  if (diff < 7) return formatDayOfWeek(date);
  return formatDate(date);
}

// ---------------------------------------------------------------------------
// Barcode / product code
// ---------------------------------------------------------------------------

/// Sanitises a raw barcode string by stripping non-alphanumeric characters and
/// uppercasing the result. Returns an empty string for null/blank input.
///
/// Example: `parseBarcode(' 7501055300427\n')` → `"7501055300427"`
String parseBarcode(String? barcode) {
  if (barcode == null || barcode.trim().isEmpty) return '';
  return barcode.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
}

/// Returns the barcode type based on its numeric length for EAN/UPC codes.
///
/// Returns one of: `'EAN-13'`, `'EAN-8'`, `'UPC-A'`, `'UPC-E'`, `'CODE-128'`,
/// or `'UNKNOWN'`.
String detectBarcodeType(String barcode) {
  final clean = parseBarcode(barcode);
  final isAllDigits = RegExp(r'^\d+$').hasMatch(clean);
  if (!isAllDigits) return 'CODE-128';
  return switch (clean.length) {
    13 => 'EAN-13',
    8 => 'EAN-8',
    12 => 'UPC-A',
    6 => 'UPC-E',
    _ => 'CODE-128',
  };
}

/// Validates an EAN-13 barcode checksum. Returns `true` if valid.
bool validateEan13(String barcode) {
  final clean = parseBarcode(barcode);
  if (clean.length != 13 || !RegExp(r'^\d{13}$').hasMatch(clean)) {
    return false;
  }
  int sum = 0;
  for (int i = 0; i < 12; i++) {
    final digit = int.parse(clean[i]);
    sum += (i.isEven) ? digit : digit * 3;
  }
  final checkDigit = (10 - (sum % 10)) % 10;
  return checkDigit == int.parse(clean[12]);
}

// ---------------------------------------------------------------------------
// Tax / financial calculations
// ---------------------------------------------------------------------------

/// Returns the tax amount for a given [amount] and [taxRate] (expressed as a
/// decimal, e.g. `0.16` for 16 %).
///
/// Example: `calculateTax(100.0, 0.16)` → `16.0`
double calculateTax(double amount, double taxRate) {
  assert(taxRate >= 0 && taxRate <= 1, 'taxRate must be between 0 and 1');
  return _round2(amount * taxRate);
}

/// Returns the tax-inclusive total: [amount] + tax at [taxRate].
double calculateTotalWithTax(double amount, double taxRate) =>
    _round2(amount * (1 + taxRate));

/// Extracts the tax component from a tax-inclusive [total].
double extractTaxFromTotal(double total, double taxRate) =>
    _round2(total - (total / (1 + taxRate)));

/// Calculates the change to return to the customer.
///
/// Returns `0` if [paid] < [total] (i.e. insufficient payment).
///
/// Example: `calculateChange(200.0, 178.50)` → `21.50`
double calculateChange(double paid, double total) {
  final change = paid - total;
  return change < 0 ? 0.0 : _round2(change);
}

/// Returns the discount amount for a given [originalPrice] and [discountRate]
/// (0–1 decimal).
double calculateDiscount(double originalPrice, double discountRate) {
  assert(discountRate >= 0 && discountRate <= 1,
      'discountRate must be between 0 and 1');
  return _round2(originalPrice * discountRate);
}

/// Returns the price after applying [discountRate].
double applyDiscount(double originalPrice, double discountRate) =>
    _round2(originalPrice * (1 - discountRate));

/// Returns the gross profit margin as a decimal (0–1).
///
/// [costPrice] must be > 0. Returns `0` if costPrice is 0.
double calculateMargin(double sellingPrice, double costPrice) {
  if (costPrice == 0) return 0;
  return _round2((sellingPrice - costPrice) / sellingPrice);
}

/// Returns the markup percentage as a decimal.
double calculateMarkup(double sellingPrice, double costPrice) {
  if (costPrice == 0) return 0;
  return _round2((sellingPrice - costPrice) / costPrice);
}

// ---------------------------------------------------------------------------
// Quantity / inventory helpers
// ---------------------------------------------------------------------------

/// Returns a human-readable stock level label.
String stockLevelLabel(int quantity, {int lowThreshold = 10}) {
  if (quantity <= 0) return 'Sin stock';
  if (quantity <= lowThreshold) return 'Stock bajo';
  return 'En stock';
}

/// Formats a weight value with the appropriate unit label.
///
/// Example: `formatWeight(1500, 'g')` → `"1,500 g"`
String formatWeight(double value, String unit) =>
    '${formatNumber(value, decimals: value.truncateToDouble() == value ? 0 : 2)} $unit';

// ---------------------------------------------------------------------------
// String / name helpers
// ---------------------------------------------------------------------------

/// Returns initials from a full name (up to 2 characters).
///
/// Example: `initials('Ana García López')` → `"AG"`
String initials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

/// Capitalises the first letter of each word in [text].
String titleCase(String text) => text
    .toLowerCase()
    .split(' ')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

/// Truncates [text] to [maxLength] characters, appending `'…'` if needed.
String truncate(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}…';
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

/// Rounds [value] to 2 decimal places using standard financial rounding.
double _round2(double value) =>
    (value * 100).roundToDouble() / 100;
