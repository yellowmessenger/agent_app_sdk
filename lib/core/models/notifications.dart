import 'package:flutter/material.dart';

class Notifications extends ChangeNotifier {
  int _notificationCount = 0;
  int get notificationCount => _notificationCount;
  set notificationCount(int count) {
    _notificationCount = count;
    notifyListeners();
  }
}
