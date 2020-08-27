import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:support_agent/core/models/messages.dart';
import 'package:support_agent/core/services/common.dart';
import 'package:support_agent/ui/shared/color.dart';
import 'package:timeago/timeago.dart' as timeago;

List<Widget> MessageLayout(List<Message> message, double width) {
  List<Widget> messageLayout = List<Widget>();
  message.forEach((v) {
    switch (v.messageFormat) {
      case "text":
        String msg;
        if (v.message[0] == "{" && v.message[v.message.length - 1] == "}") {
          try {
            Map<String, dynamic> currentMsg = json.decode(v.message);
            msg = currentMsg['message'] ?? "";
          } catch (e) {}
        } else {
          msg = v.message;
        }
        messageLayout.add(
          MessageFormatting(
            messageType: v.messageType,
            width: width,
            data: Text(msg ?? "",
                style: GoogleFonts.roboto(
                    fontSize: 15,
                    color: v.messageType == "USER"
                        ? Colors.white
                        : TextColorDark)),
            media: false,
            timestamp: v.created != null
                ? v.created.toString()
                : DateTime.now().toString(),
          ),
        );

        break;
      case "image":
        String url;
        if (v.message[0] == "{" && v.message[v.message.length - 1] == "}") {
          try {
            Map<String, dynamic> currentMsg = json.decode(v.message);
            url = currentMsg['image'] ?? "";
          } catch (e) {}
        } else {
          url = v.message;
        }

        if (url != null)
          messageLayout.add(MessageFormatting(
            messageType: v.messageType,
            width: width,
            data:
                InkWell(onTap: () => launchURL(url), child: Image.network(url)),
            media: true,
            timestamp: v.created.toString(),
          ));
        if (v.caption != null)
          messageLayout.add(
            MessageFormatting(
              messageType: v.messageType,
              width: width,
              data: Text(v.caption,
                  style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: v.messageType == "USER"
                          ? Colors.white
                          : TextColorDark)),
              media: false,
              timestamp: v.created != null
                  ? v.created.toString()
                  : DateTime.now().toString(),
            ),
          );

        break;
      case "file":
        String url;

        if (v.message[0] == "{" && v.message[v.message.length - 1] == "}") {
          try {
            Map<String, dynamic> currentMsg = json.decode(v.message);
            url = currentMsg['file'] ?? "";
          } catch (e) {}
        } else {
          url = v.message;
        }
        messageLayout.add(MessageFormatting(
          messageType: v.messageType,
          width: width,
          data: InkWell(
            onTap: () => launchURL(url),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.attach_file,
                  color: v.messageType == "USER" ? Colors.white : AccentBlue,
                ),
                Text("Attachment",
                    style: GoogleFonts.roboto(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: v.messageType == "USER"
                            ? Colors.white
                            : AccentBlue)),
              ],
            ),
          ),
          media: false,
          timestamp: v.created.toString(),
        ));
        break;
      case "other":
      // print(v.message);
    }
  });

  return messageLayout;
}

class MessageFormatting extends StatelessWidget {
  const MessageFormatting({
    Key key,
    @required this.data,
    @required this.messageType,
    @required this.width,
    @required this.timestamp,
    this.media,
  }) : super(key: key);

  final Widget data;
  final String messageType;
  final double width;
  final bool media;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: messageType == "USER"
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                padding: EdgeInsets.symmetric(
                    vertical: 2, horizontal: (media ? 1 : 10)),
                decoration: BoxDecoration(
                  color: messageType == "USER"
                      ? AccentBlue
                      : Colors.black38.withAlpha(10),
                  // color: Colors.black38.withAlpha(10),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                constraints: BoxConstraints(
                    maxWidth: width * 0.8, minWidth: width * 0.2),
                child: Padding(
                  padding: EdgeInsets.all(media ? 1 : 8),
                  child: data,
                )),
            Text(
                dateFromat(DateTime.parse(timestamp).toLocal()) == "date"
                    ? DateFormat.MMMd()
                            .format(DateTime.parse(timestamp).toLocal()) +
                        ", " +
                        DateFormat.jm()
                            .format(DateTime.parse(timestamp).toLocal())
                    : dateFromat(DateTime.parse(timestamp).toLocal()) == "time"
                        ? DateFormat.jm()
                            .format(DateTime.parse(timestamp).toLocal())
                        : timeago.format(DateTime.parse(timestamp)),
                style:
                    GoogleFonts.roboto(fontSize: 12, color: TextColorMedium)),
          ],
        ));
  }

  dateFromat(DateTime messageDate) {
    DateTime now = DateTime.now();
    if (now.difference(messageDate).inMinutes < 5)
      return "ago";
    else if (DateTime(messageDate.year, messageDate.month, messageDate.day)
            .difference(DateTime(now.year, now.month, now.day))
            .inDays <
        0)
      return "date";
    else
      return "time";
  }
}
