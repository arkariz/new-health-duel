import 'package:intl/intl.dart';

/// DateTime Extensions
///
/// Provides convenient date formatting and manipulation.
extension DateTimeExtensions on DateTime {
  /// Format as "Jan 1, 2024"
  String get formatted => DateFormat('MMM d, y').format(this);

  /// Format as "January 1, 2024"
  String get formattedLong => DateFormat('MMMM d, y').format(this);

  /// Format as "01/01/2024"
  String get formattedShort => DateFormat('MM/dd/yyyy').format(this);

  /// Format as "12:30 PM"
  String get timeFormatted => DateFormat('h:mm a').format(this);

  /// Format as "Jan 1, 2024 12:30 PM"
  String get dateTimeFormatted => DateFormat('MMM d, y h:mm a').format(this);

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Get relative time string (e.g., "2 hours ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Start of day (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// End of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}
