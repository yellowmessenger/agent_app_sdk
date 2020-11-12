import 'dart:async';
import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_agent/core/models/all_bots.dart';
import 'package:support_agent/core/models/userdata.dart';
import 'package:support_agent/core/models/xmpp_user.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/services/bot_service.dart';
import 'package:support_agent/core/services/xmpp_creds.dart';
import 'package:support_agent/core/viewmodels/base_model.dart';

import '../../locator.dart';

class LandingModel extends BaseModel {
  AnimationController animationController;
  Animation<double> animation;
  final AuthenticationService _authService = locator<AuthenticationService>();
  final BotService _botService = locator<BotService>();
  final XmppCredsService _xmppCredsService = locator<XmppCredsService>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<String> getHomePage() async {
    final SharedPreferences prefs = await _prefs;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      _authService.logout();
//      if (_authService.currentUserData == null) {
//        UserData currentUser;
//        try {
//          currentUser =
//              UserData.fromJson(jsonDecode(prefs.getString('currentUser')));
//        } catch (e) {}
//
//        _authService.populateCurrentUser(currentUser);
//        Crashlytics.instance.setUserEmail(currentUser.user.email);
//        Crashlytics.instance.setUserName(currentUser.user.username);
//        Crashlytics.instance.setUserIdentifier(currentUser.user.username);
//      }
      if (_botService.defaultBot == null) {
        BotMappings defaultBot;
        try {
          defaultBot =
              BotMappings.fromJson(jsonDecode(prefs.getString('defaultBot')));
          if (defaultBot == null) return 'bot_selection';
          await _botService.setDefault(defaultBot);
          Crashlytics.instance.setString("botId", defaultBot.userName);
        } catch (e) {}
      }

      if (_xmppCredsService.xmppCreds == null) {
        XmppCredsModel creds;
        try {
          creds =
              XmppCredsModel.fromJson(jsonDecode(prefs.getString('xmppCreds')));
          if (creds == null) return 'bot_selection';
          await _xmppCredsService.setDefault(creds);
        } catch (e) {}
      }

      return 'login';
    } else {
      Crashlytics.instance.setUserEmail('support@yellowmessenger.com');
      Crashlytics.instance.setUserName('Annonymous');
      Crashlytics.instance.setUserIdentifier('#01');
      return 'login';
    }
  }

  gotoHome(BuildContext context) async {
    Navigator.pushReplacementNamed(context, await getHomePage());
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
