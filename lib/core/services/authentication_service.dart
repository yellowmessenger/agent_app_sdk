import 'dart:async';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_agent/core/models/userdata.dart';

import '../../locator.dart';
import 'api.dart';

class AuthenticationService {
  Api _api = locator<Api>();
  UserData _currentUserData;
  UserData get currentUserData => _currentUserData;

  StreamController<UserData> userController = StreamController<UserData>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  populateCurrentUser(UserData userData) {
    _currentUserData = userData;
    userController.add(userData);
  }

  Future<Map<String, dynamic>> login(String userName, String password) async {
    final plainText = password;
    final key = Key.fromBase64('wAT8E63Q/bKRkmpfkSH2Gg==');
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final encryptedPassword = encrypter.encrypt(plainText, iv: iv);

    var fetchedUserResponse =
        await _api.getUserProfile(userName, encryptedPassword.base64);
    if (fetchedUserResponse['error'] == null) {
      var fetchedUser = UserData.fromJson(fetchedUserResponse);
      var hasUser = fetchedUser != null;
      if (hasUser) {
        final SharedPreferences prefs = await _prefs;
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('currentUser', jsonEncode(fetchedUser.toJson()));
        populateCurrentUser(fetchedUser);
      }
      return {"error" : hasUser ? false : fetchedUserResponse['error']};
    }
    else{
          print(fetchedUserResponse['error']);
          return  {"error" : fetchedUserResponse['error']};

    }
  }

  logout() async {
    populateCurrentUser(null);
    final SharedPreferences prefs = await _prefs;
    await prefs.remove('currentUser');
    await prefs.remove('defaultBot');
    await prefs.setBool('isLoggedIn', false);
  }
}
