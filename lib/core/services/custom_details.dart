import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDataService {
  getCustomData() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getString('customData') != null)
      _customData = jsonDecode(prefs.getString('customData'));
  }

  Map<String, dynamic> _customData;
  Map<String, dynamic> get customData => _customData;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  setDefault(Map<String, dynamic> data) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('customData', jsonEncode(data));
    _customData = data;
  }
}
