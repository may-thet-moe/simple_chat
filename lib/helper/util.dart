import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Util {
  static String getMessageTime(
      {required String time, required BuildContext context}) {
    final int timestamp = int.tryParse(time) ?? -1;
    if (timestamp == -1) return 'not available date';

    DateTime now = DateTime.now();
    DateTime lastSent = DateTime.fromMillisecondsSinceEpoch(timestamp);

    Duration difference = now.difference(lastSent);

    if (difference.inMinutes < 1) {
      return "just now";
    } else if (difference.inDays == 1) {
      return DateFormat('h:mm a').format(lastSent);
    } else if (now.month == lastSent.month) {
      return DateFormat('d h:mm a').format(lastSent);
    } else if (now.year == lastSent.year) {
      return DateFormat('d MMM').format(lastSent);
    }else {
      return DateFormat('d MMM yyyy').format(lastSent); // "21 Dec 2023"
    }
  }

  static String getLastActiveTime(
      {required String lastActive, required BuildContext context}) {
    final int timestamp = int.tryParse(lastActive) ?? -1;
    if (timestamp == -1) return 'last seen not available';

    DateTime now = DateTime.now();
    DateTime lastSeen = DateTime.fromMillisecondsSinceEpoch(timestamp);

    Duration difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return "Last seen just now";
    } else if (difference.inHours < 1) {
      return "Last seen ${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "Last seen ${difference.inHours} hrs ago";
    } else if (difference.inDays == 1) {
      return "Last seen yesterday at ${DateFormat('h:mm a').format(lastSeen)}";
    } else if (difference.inDays < 7) {
      return "Last seen ${DateFormat('EEEE, h:mm a').format(lastSeen)}"; // "Last seen Monday, 3:45 PM"
    } else if (now.year == lastSeen.year) {
      return "Last seen on ${DateFormat('d MMM').format(lastSeen)}"; // "Last seen on 1 Feb"
    } else {
      return "Last seen on ${DateFormat('d MMM yyyy').format(lastSeen)}"; // "Last seen on 21 Dec 2023"
    }
  }
}
