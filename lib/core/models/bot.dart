import 'package:flutter/material.dart';
import 'package:support_agent/core/services/common.dart';

class Bot {
  String botId, imageUrl, botName, botDescription;
  Bot({this.botId, this.imageUrl, this.botName, this.botDescription});

  Widget getBotWidget() {
    if (this.imageUrl != null && this.imageUrl != '') {
      return Hero(
        tag: this.imageUrl,
        child: Container(
          width: 40.0,
          height: 40.0, // border width
          decoration: new BoxDecoration(
            // color: TextColorLight, // border color
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(this.imageUrl),
          ),
        ),
      );
    } else {
      return Hero(
        tag: this.botName,
        child: Container(
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
        ),
      );
    }
  }
}
