import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Num Extensions
///
/// Provides convenient number formatting and manipulation.
extension NumExtensions on num {
  /// Format as currency (e.g., "$1,234.56")
  String toCurrency({String symbol = '\$', int decimalDigits = 2}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  /// Format with commas (e.g., "1,234,567")
  String get withCommas {
    final formatter = NumberFormat('#,###');
    return formatter.format(this);
  }

  /// Format as compact (e.g., "1.2K", "3.4M")
  String get compact {
    final formatter = NumberFormat.compact();
    return formatter.format(this);
  }

  /// Format as percentage (e.g., "45%")
  String toPercentage({int decimalDigits = 0}) {
    return '${toStringAsFixed(decimalDigits)}%';
  }

  /// Add spacing to widget (SizedBox)
  SizedBox get verticalSpace => SizedBox(height: toDouble());

  /// Add horizontal spacing to widget (SizedBox)
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
}
