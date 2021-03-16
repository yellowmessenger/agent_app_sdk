import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/all_bots.dart';
import 'package:support_agent/core/models/config.dart';
import 'package:support_agent/core/models/userdata.dart';
import 'package:support_agent/core/models/xmpp_user.dart';
import 'package:support_agent/core/services/api.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/services/bot_service.dart';
import 'package:support_agent/core/services/xmpp_creds.dart';

import '../../locator.dart';
import 'base_model.dart';

class BotSelectionModel extends BaseModel {
  Api _api = locator<Api>();
  AuthenticationService _authService = locator<AuthenticationService>();
  BotService _botService = locator<BotService>();
  Configurations config = locator<Configurations>();
  XmppCredsService _xmppCredsService = locator<XmppCredsService>();
  List<BotMappings> _allBots = List<BotMappings>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static const platform =
      const MethodChannel('com.yellowmessenger.support_agent/data');

  BotMappings _defaultBot;
  List<BotMappings> _filteredBotList = List<BotMappings>();

  BotMappings get defaultBot => _defaultBot;
  set defaultBot(BotMappings selectedBot) => _defaultBot;
  List<BotMappings> get allBots => allBots;
  set allBots(List<BotMappings> allBots) => allBots;
  List<BotMappings> get filteredBotList => _filteredBotList;
  set filteredBotList(List<BotMappings> filteredBotList) => _filteredBotList;
  List<String> _botTypes = List<String>();
  List<String> _filteredBotTypes = List<String>();
  List<String> get filteredBotType => _filteredBotTypes;

  Future getBots(BuildContext context) async {
    _defaultBot = _botService.defaultBot;
    var botId = config.config["botId"];

    final SharedPreferences prefs = await _prefs;
    await prefs.remove("allowOfflineTicket");
    List<Roles> userRoles;
    userRoles = _authService.currentUserData.user.roles;
    String authKey = _authService.currentUserData.accessToken;
    setState(ViewState.Busy);
    var bots = await _api.getAllBots(authKey);
    if (bots != null) {
      List<String> allowedBots = List<String>();
      List<String> allowedBotRoless = [
        'ROLE_BOT_SUPER_ADMIN',
        'ROLE_BOT_ADMIN',
        'ROLE_BOT_ECHO_ADMIN',
        'ROLE_BOT_AGENT',
        'ROLE_BOT_DEVELOPER'
      ];
      for (var item in userRoles) {
        if (allowedBotRoless.contains(item.role)) {}
        allowedBots.add(item.owner);
      }

      for (var bot in bots[0].data.botMappings) {
        if (allowedBots.contains(bot.userName)) {
          _allBots.add(bot);
          _botTypes.add("Sandbox");
        }
      }

      for (var bot in bots[1].data.botMappings) {
        if (allowedBots.contains(bot.userName)) {
          _allBots.add(bot);
          _botTypes.add("Staging");
        }
      }

      for (var bot in bots[2].data.botMappings) {
        if (allowedBots.contains(bot.userName)) {
          _allBots.add(bot);
          _botTypes.add("Production");
        }
      }
    }

    await setDefaultBot(
        _allBots.firstWhere((element) => element.userName == botId), context);

    setState(ViewState.Idle);
  }

  setDefaultBot(BotMappings selectedBot, BuildContext context) async {
    setState(ViewState.Busy);
    await _botService.setDefault(selectedBot);
    _defaultBot = selectedBot;
    var credsResponse = await _api.getCredentials(
        _authService.currentUserData.accessToken, selectedBot.userName, 0);
    if (credsResponse != null) {
      XmppCredsModel creds = credsResponse.data;
      await _xmppCredsService.setDefault(creds);
    }
    bool isInitializing = await platform.invokeMethod("isInitializeSDK");
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    _firebaseMessaging.getToken().then((String token) async {
      assert(token != null);
      var authToken = _authService.currentUserData.accessToken;
      var currentBot = _botService.defaultBot.userName;
      await _api.sendFirebaseToken(authToken, currentBot, token);
    });

    setState(ViewState.Idle);
    if (!isInitializing)
      Navigator.pushNamedAndRemoveUntil(
          context, 'home', (Route<dynamic> route) => false);
    else {
      debugPrint("SDK Initialized");
      await platform.invokeMethod("close-module");
    }
  }
}
