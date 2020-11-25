import 'package:flutter/material.dart';
import 'package:support_agent/core/services/xmpp_service.dart';

import '../../locator.dart';

class AppState extends ChangeNotifier {
  AppLifecycleState _appState = AppLifecycleState.resumed;
  XmppService _xmppService = locator<XmppService>();

  _xmppConnection() async {
    await _xmppService.initializeXmpp();
  }

  AppLifecycleState get appState => _appState;
  void setState(AppLifecycleState appState) {
    print(" form Appstate: $appState");
    _appState = appState;
    if (_appState == AppLifecycleState.paused)
      _xmppService.closeCurrentConnection();
    else if (_appState == AppLifecycleState.resumed) _xmppConnection();
    notifyListeners();
  }
}
