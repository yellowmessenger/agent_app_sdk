import 'package:flutter/material.dart';
import 'package:support_agent/core/services/common.dart';

class AllBots {
  bool success;
  String message;
  Data data;

  AllBots({this.success, this.message, this.data});

  AllBots.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  List<BotMappings> botMappings;
  int botCount;

  Data({this.botMappings, this.botCount});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['botMappings'] != null) {
      botMappings = new List<BotMappings>();
      json['botMappings'].forEach((v) {
        botMappings.add(new BotMappings.fromJson(v));
      });
    }
    botCount = json['botCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.botMappings != null) {
      data['botMappings'] = this.botMappings.map((v) => v.toJson()).toList();
    }
    data['botCount'] = this.botCount;
    return data;
  }
}

class BotMappings {
  String sId;
  String bot;
  String userName;
  String botName;
  String botDesc;
  String botIcon;
  String botTitle;
  bool v2;

  BotMappings(
      {this.sId,
      this.bot,
      this.userName,
      this.botName,
      this.botDesc,
      this.botIcon,
      this.botTitle,
      this.v2});

  BotMappings.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    bot = json['bot'];
    userName = json['userName'];
    botName = json['botName'];
    botDesc = json['botDesc'];
    botIcon = json['botIcon'];
    botTitle = json['botTitle'];
    v2 = json['v2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['bot'] = this.bot;
    data['userName'] = this.userName;
    data['botName'] = this.botName;
    data['botDesc'] = this.botDesc;
    data['botIcon'] = this.botIcon;
    data['botTitle'] = this.botTitle;
    data['v2'] = this.v2;
    return data;
  }
  Widget getBotWidget() {
    if (this.botIcon != null && this.botIcon != '') {
      return Container(
        width: 40.0,
        height: 40.0, // border width
        decoration: new BoxDecoration(
          // color: TextColorLight, // border color
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage(this.botIcon),
        ),
      );
    } else {
      return Container(
        width: 32.0,
        height: 32.0,
        padding: const EdgeInsets.all(2.0), // borde width
        decoration: new BoxDecoration(
          color: const Color(0xFFFFFFFF), // border color
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          backgroundColor: Colors.blue.shade900,
          child: Text(getInitials(this.botName)),
        ),
      );
    }
  }
}