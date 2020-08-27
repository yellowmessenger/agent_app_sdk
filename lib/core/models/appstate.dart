import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  AppLifecycleState _appState = AppLifecycleState.resumed;

  AppLifecycleState get appState => _appState;

  void setState(AppLifecycleState appState) {
    print(" form Appstate: $appState");
    _appState = appState;
    notifyListeners();
  }
}
