import 'package:flutter/material.dart';
import 'package:support_agent/core/models/config.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/viewmodels/base_model.dart';

import '../../locator.dart';

class LoginModel extends BaseModel {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  Configurations config = locator<Configurations>();

  String errorMessage;

  initLogin(BuildContext context) async {
    bool authResponse = await login();
    if (authResponse) {
      Navigator.pushNamedAndRemoveUntil(
          context, 'bot_selection', (Route<dynamic> route) => false);
    }
  }

  Future<bool> login() async {
    // change username and password
    var success = await _authenticationService.login(
        config.config["username"], config.config["password"]);
    if (success["error"] == false) {
      return true;
    } else {
      errorMessage = success['error'];
      return false;
    }
  }
}
