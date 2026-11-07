import 'package:intl/intl.dart';

class DateFormatter {
  // "2 hours ago", "1 day ago"
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    return DateFormat('MMM d, yyyy').format(date);
  }

  // "Oct 18, 2026 at 10:24 AM"
  static String full(DateTime date) {
    return DateFormat("MMM d, yyyy 'at' h:mm a").format(date);
  }

  // "Oct 18, 9:45 AM"
  static String short(DateTime date) {
    return DateFormat('MMM d, h:mm a').format(date);
  }
}
