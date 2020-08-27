  
  import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_agent/core/models/all_bots.dart';

class BotService {

  BotMappings _defaultBot;
  BotMappings get defaultBot => _defaultBot;
      Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  setDefault(BotMappings bot) async {
    final SharedPreferences prefs = await _prefs;
      await prefs.setString('defaultBot', jsonEncode(bot.toJson()));
    _defaultBot = bot;
  }
  }
