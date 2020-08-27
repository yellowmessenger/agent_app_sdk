  
  import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_agent/core/models/xmpp_user.dart';

class XmppCredsService {

  XmppCredsModel _xmppCreds;
  XmppCredsModel get xmppCreds => _xmppCreds;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  setDefault(XmppCredsModel xmppCreds) async {
    final SharedPreferences prefs = await _prefs;
      await prefs.setString('xmppCreds', jsonEncode(xmppCreds.toJson()));
    _xmppCreds = xmppCreds;
  }
  }
