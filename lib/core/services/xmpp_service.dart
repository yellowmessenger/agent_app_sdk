import 'dart:async';

import 'package:flutter/services.dart';

import 'package:support_agent/core/models/xmpp_user.dart';
import 'package:support_agent/core/services/xmpp_creds.dart';
import 'package:xmpp_rock/xmpp_rock.dart';

import '../../locator.dart';

class XmppService {
  XmppCredsService _xmppCredsService = locator<XmppCredsService>();
  StreamSubscription _chatStreamSubscription;
  StreamController<String> _chatStreamController =
      StreamController<String>.broadcast();
  StreamController<String> get chatStreamController => _chatStreamController;

  initializeXmpp() async {
    XmppCredsModel xmppUser = _xmppCredsService.xmppCreds;
    try {
      print("${xmppUser.username}@xmpp.yellowmssngr.com");
      print(xmppUser.password);

      var res = await XmppRock.initialize(
          fullJid: "${xmppUser.username}@xmpp.yellowmssngr.com",
          password: xmppUser.password,
          port: 443);
      _enableXmpp();
      return res;
      // print(xmppUser.username);
    } on PlatformException {
      // print("Xmpp initialization failed...");
    }
  }

  sendPresence(String status) {}
  _enableXmpp() {
    if (_chatStreamSubscription == null)
      _chatStreamSubscription = XmppRock.xmppStream.listen(_updateUI);
  }

  _updateUI(String data) {
    _chatStreamController.sink.add(data);
  }

  cleanup() {
    _chatStreamSubscription.cancel();
    _chatStreamController.close();
    try {
      XmppRock.close();
    } catch (e) {}
  }
}
