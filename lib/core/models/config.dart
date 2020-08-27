import 'package:flutter/material.dart';

class Configurations extends ChangeNotifier {
  Map _config = {"username": "", "password": "", "botId": ""};

  Map get config => _config;

  void setState(Map config) {
    print(" form Appstate: $config");
    _config = config;
    notifyListeners();
  }
}
