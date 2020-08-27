
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/userdata.dart';
import 'package:support_agent/core/services/api.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/services/bot_service.dart';
import 'package:support_agent/core/services/xmpp_service.dart';

import '../../locator.dart';
import 'base_model.dart';

class SettingsModel extends BaseModel{
 AuthenticationService _authService = locator<AuthenticationService>();
 BotService _botService = locator<BotService>();
 Api _api = locator<Api>();
 XmppService _xmppService = locator<XmppService>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();


 User _currentUser;
 User get currentUser => _currentUser;
 String _defaultBot;
 String get defaultBot => _defaultBot;
 bool pushNotification = false;

 initSettings() async{
    setState(ViewState.Busy);
     
  _defaultBot = _botService.defaultBot != null ? _botService.defaultBot.botName : "";
  _currentUser = _authService.currentUserData.user; 
  pushNotification =  await _isSetAllowOfflineTicket();
  setState(ViewState.Idle);
 }


  
logout(BuildContext context) async {

    _xmppService.cleanup();
    await _authService.logout();
    Navigator.pushNamedAndRemoveUntil(
        context, '/', (Route<dynamic> route) => false);
  }

  changeDefaultBot(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(
        context, 'bot_selection', (Route<dynamic> route) => false);
  }

   pushNotificationStatus(String status)async {
     await _api.setNotificationPreference(
        _authService.currentUserData.accessToken, _botService.defaultBot.userName, status);
     final SharedPreferences prefs = await _prefs;
     await prefs.setBool("allowOfflineTicket", status == "ONLINE" ? true : false);
     setState(ViewState.Busy);
     pushNotification = status == "ONLINE" ? true : false;
     setState(ViewState.Idle);
  }

  Future<bool> _isSetAllowOfflineTicket() async {
  final SharedPreferences prefs = await _prefs;
  bool allowOfflineTicket = prefs.getBool('allowOfflineTicket') ?? false;
  return allowOfflineTicket;
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("No"),
      onPressed: () {pushNotificationStatus("OFFLINE");Navigator.of(context).pop();},
    );
    Widget continueButton = FlatButton(
      child: Text("Sure"),
      onPressed: () {pushNotificationStatus("ONLINE");Navigator.of(context).pop();},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Notification Settings"),
      content: Text(
          "Would you like to allow ticket creation when not using the app?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

