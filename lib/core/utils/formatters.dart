import 'package:intl/intl.dart';

/// Date and number formatters
class Formatters {
  Formatters._();

  static final DateFormat dateShort = DateFormat('MMM d, yyyy');
  static final DateFormat dateLong = DateFormat('MMMM d, yyyy');
  static final DateFormat dateTime12h = DateFormat('MMM d, h:mm a');
  static final DateFormat time12h = DateFormat('h:mm a');
  static final DateFormat timeDate = DateFormat('h:mm a, MMM d');
  static final DateFormat monthYear = DateFormat('MMMM yyyy');
  static final DateFormat dayMonth = DateFormat('d MMM');

  static String formatAge(DateTime dob) {
    final now = DateTime.now();
    final diff = now.difference(dob);
    final months = (diff.inDays / 30.44).floor();
    final years = (months / 12).floor();
    final remainingMonths = months % 12;

    if (years > 0) {
      return '$years yr${years > 1 ? 's' : ''} $remainingMonths mo';
    }
    if (months > 0) {
      return '$months month${months > 1 ? 's' : ''}';
    }
    final weeks = (diff.inDays / 7).floor();
    if (weeks > 0) {
      return '$weeks week${weeks > 1 ? 's' : ''}';
    }
    return '${diff.inDays} day${diff.inDays != 1 ? 's' : ''}';
  }

  static String formatAgeInMonths(DateTime dob) {
    final now = DateTime.now();
    final months = (now.difference(dob).inDays / 30.44).floor();
    return '$months';
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  static String formatDecimal(double value, {int decimals = 1}) {
    return value.toStringAsFixed(decimals);
  }

  static String formatPercentile(double zScore) {
    // Convert z-score to percentile using approximation
    final percentile = _zScoreToPercentile(zScore);
    return '${percentile.toStringAsFixed(0)}th';
  }

  static double _zScoreToPercentile(double z) {
    // Approximation of the normal CDF
    if (z < -6.5) return 0.0;
    if (z > 6.5) return 100.0;

    double factK = 1;
    double sum = 0;
    double term = 1;
    double a = z;
    const double phi = 0.3989422804014327;

    for (int i = 0; term.abs() > 1e-10; i++) {
      final denom = (2 * i + 1).toDouble();
      term = a / denom;
      sum += term;
      a *= -z * z / ((i + 1) * 2);
      factK++;
      if (factK > 100) break;
    }

    return ((0.5 + sum * phi) * 100).clamp(0, 100);
  }

  static String relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return dateShort.format(dateTime);
  }
}
