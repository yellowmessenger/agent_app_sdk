import 'dart:async';

import 'package:flutter/services.dart';

class XmppRock {
  factory XmppRock() {
    if (_singleton == null) {
      _singleton = XmppRock._();
    }
    return _singleton;
  }

  XmppRock._();

  static XmppRock _singleton;

  static const EventChannel _eventChannel =
      const EventChannel('com.yellowmessenger.xmpp/stream');
  static const MethodChannel _methodChannel =
      const MethodChannel('com.yellowmessenger.xmpp/methods');
  static Stream<String> _xmppStream;
  static bool _ready;

  static Future<String> sendMessage(String msg) async {
    final String reply = await _methodChannel
        .invokeMethod('sendData', <String, dynamic>{'msg': msg});
    return reply;
  }

  static void close() async {
    final reply = await _methodChannel.invokeMethod('closeConnection');
  }

  static Future<dynamic> initialize(
      {String fullJid, String password, int port}) async {
    return await _methodChannel
        .invokeMethod('initializeXMPP', <String, dynamic>{
      'fullJid': fullJid,
      'password': password,
      'port': port,
    });
  }

  static Stream<String> get xmppStream {
    if (_xmppStream != null) {
      _xmppStream = null;
    }
    _xmppStream =
        _eventChannel.receiveBroadcastStream().map<String>((value) => value);

    return _xmppStream;
  }
}
