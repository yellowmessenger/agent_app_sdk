import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

String getInitials(String name) {
  String initials = '';
  if (name.length == 0) return initials;
  List<String> names = name.split(' ');
  initials = names[0].substring(0, 1).toUpperCase();

  if (names.length > 1 && names[names.length - 1] != '') {
    initials += names[names.length - 1].substring(0, 1).toUpperCase();
  }
  return initials;
}

String capitalize(String s) =>
    s == "" ? "" : s[0].toUpperCase() + s.substring(1).toLowerCase();

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

sendNotification(String title, String body, {String payload}) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.yellowmessenger.partner', 'Yellow Partner', 'Support agent app.',
      importance: Importance.max, priority: Priority.high, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, title, body, platformChannelSpecifics);
  // .show(0, title, body, platformChannelSpecifics, payload: payload ?? "");
}

String toCamelCase(String str) {
  String s = str
      .replaceAllMapped(
          RegExp(
              r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
          (Match m) =>
              "${m[0][0].toUpperCase()}${m[0].substring(1).toLowerCase()}")
      .replaceAll(RegExp(r'(_|-|\s)+'), '');
  return s[0].toLowerCase() + s.substring(1);
}
