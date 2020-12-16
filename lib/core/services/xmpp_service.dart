import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

import 'package:support_agent/core/models/xmpp_user.dart';
import 'package:support_agent/core/services/connectivity.dart';
import 'package:support_agent/core/services/xmpp_creds.dart';
import 'package:xmpp_rock/xmpp_rock.dart';

import '../../locator.dart';

class XmppService {
  XmppCredsService _xmppCredsService = locator<XmppCredsService>();
  StreamSubscription _chatStreamSubscription;
  StreamController<String> _chatStreamController =
      StreamController<String>.broadcast();
  StreamController<String> get chatStreamController => _chatStreamController;
  StreamSubscription get chatStreamSubscription => _chatStreamSubscription;

  initializeXmpp() async {
    XmppCredsModel xmppUser = _xmppCredsService.xmppCreds;
    _enableXmpp();
    try {
      XmppRock.close();
      print("${xmppUser.username}@xmpp.yellowmssngr.com");

      var res = await XmppRock.initialize(
          fullJid: "${xmppUser.username}@xmpp.yellowmssngr.com",
          password: xmppUser.password,
          port: 443);

      return res;
      // print(xmppUser.username);
    } on PlatformException {
      // print("Xmpp initialization failed...");
    }
  }

  sendPresence(String status) {}

  _enableXmpp() {
    if (_chatStreamSubscription == null || !_chatStreamSubscription.isPaused) {
      print("creating new");
      _chatStreamSubscription = XmppRock.xmppStream.listen(_updateUI);
    } else {
      print("resuming");
      _chatStreamSubscription.resume();
    }
  }

  _updateUI(String data) {
    // print(data);
    if (data[0] == "{" && data[data.length - 1] == "}") {
      try {
        Map<String, dynamic> incomingEvents = jsonDecode(data);
        if (incomingEvents.containsKey("connected")) {
          log("connection event");
          bool xmppReady = incomingEvents["connected"];
          log("connection $xmppReady");
          if (!xmppReady) {
            ConnectionStatusSingleton.getInstance().checkConnection();
          }
        }
      } catch (e) {}
    }

    _chatStreamController.sink.add(data);
  }

  closeCurrentConnection() {
    _chatStreamSubscription.pause();
    _chatStreamController.sink.add("pauseStream");
    print("pausing");

    print("closing connection");
    try {
      XmppRock.close();
    } catch (e) {}
  }

  cleanup() {
    print("closing connection");
    _chatStreamSubscription.pause();
    // _chatStreamController.close();
    try {
      XmppRock.close();
    } catch (e) {}
  }
}
