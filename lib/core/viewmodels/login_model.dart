import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:support_agent/core/models/config.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/viewmodels/base_model.dart';

import '../../locator.dart';

class LoginModel extends BaseModel {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  Configurations config = locator<Configurations>();
  static const platform =
      const MethodChannel('com.yellowmessenger.support_agent/data');

  String errorMessage;

  initLogin(BuildContext context) async {
    await _getConfig();
    bool authResponse = await login();
    if (authResponse) {
      Navigator.pushNamedAndRemoveUntil(
          context, 'bot_selection', (Route<dynamic> route) => false);
    } else {
      debugPrint("Login unsuccessful. Closing Plugin");
      await platform.invokeMethod("close-module");
    }
  }

  _getConfig() async {
    var data = await platform.invokeMethod("getConfig");

    final jData = jsonDecode(data);
    print(jData);
    var username = jData['username'];
    var password = jData['password'];
    var botId = jData['botId'];

    config
        .setState({"username": username, "password": password, "botId": botId});
  }

  Future<bool> login() async {
    if (config.config["username"] != null &&
        config.config["password"] != null) {
      var success = await _authenticationService.login(
          config.config["username"], config.config["password"]);
      if (success["error"] == false) {
        return true;
      } else {
        errorMessage = success['error'];
        debugPrint("Login unsuccessful: $errorMessage");
        await platform.invokeMethod("send-notification", {
          "payload": {"error": errorMessage}
        });

        return false;
      }
    } else
      return false;
  }
}
