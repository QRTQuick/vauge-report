String timeAgo(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Unknown';
  }

  final now = DateTime.now().toUtc();
  final date = dateTime.toUtc();
  final difference = now.difference(date);

  if (difference.inSeconds < 45) {
    return 'Just now';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  }

  final weeks = (difference.inDays / 7).floor();
  if (weeks < 5) {
    return '${weeks}w ago';
  }

  final months = (difference.inDays / 30).floor();
  if (months < 12) {
    return '${months}mo ago';
  }

  final years = (difference.inDays / 365).floor();
  return '${years}y ago';
}
