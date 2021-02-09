import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:support_agent/core/models/messages.dart';
import 'package:support_agent/core/services/common.dart';
import 'package:support_agent/core/viewmodels/chat_model.dart';
import 'package:support_agent/ui/shared/color.dart';
import 'package:support_agent/ui/widgets/videoplayerformat.dart';
import 'package:timeago/timeago.dart' as timeago;

List<Widget> MessageLayout(List<Message> message, double width, ChatModel model,
    BuildContext context) {
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
            sender: v.sender,
            messageType: v.messageType,
            replyTo: v.replyTo,
            replyToAction: () => model.replyToAction(v.replyTo, context),
            width: width,
            data: Text(msg ?? "",
                style: GoogleFonts.roboto(
                    fontSize: 15,
                    color: v.messageType == "USER" || v.messageType == null
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
            sender: v.sender,
            messageType: v.messageType,
            replyTo: v.replyTo,
            width: width,
            data: InkWell(
                onTap: () {
                  Widget alert = Container(
                      color: Colors.white,
                      child: Column(children: <Widget>[
                        AppBar(
                          title: Text(v.caption ?? ""),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height - 200,
                          child: PhotoView(
                              backgroundDecoration:
                                  BoxDecoration(color: Colors.white),
                              imageProvider: Image.network(url).image),
                        ),
                        Divider(),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              FlatButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    "Close",
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w500,
                                        color: Danger,
                                        fontSize: 16),
                                  )),
                            ],
                          ),
                        ),
                      ]));

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Material(child: alert);
                    },
                  );
                },
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Image.network(url))),
            media: true,
            timestamp: v.created != null
                ? v.created.toString()
                : DateTime.now().toString(),
          ));
        if (v.caption != null)
          messageLayout.add(
            MessageFormatting(
              messageType: v.messageType,
              replyTo: v.replyTo,
              width: width,
              data: Text(v.caption,
                  style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: v.messageType == "USER" || v.messageType == null
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
          sender: v.sender,
          messageType: v.messageType,
          replyTo: v.replyTo,
          width: width,
          data: InkWell(
            onTap: () => launchURL(url),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.attach_file,
                  color: v.messageType == "USER" || v.messageType == null
                      ? Colors.white
                      : AccentBlue,
                ),
                Text("Attachment",
                    style: GoogleFonts.roboto(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: v.messageType == "USER" || v.messageType == null
                            ? Colors.white
                            : AccentBlue)),
              ],
            ),
          ),
          media: false,
          timestamp: v.created != null
              ? v.created.toString()
              : DateTime.now().toString(),
        ));
        break;
      case "video":
        String url;

        if (v.message[0] == "{" && v.message[v.message.length - 1] == "}") {
          try {
            Map<String, dynamic> currentMsg = json.decode(v.message);
            url = currentMsg['video'] ?? "";
          } catch (e) {}
        } else {
          url = v.message;
        }
        messageLayout.add(MessageFormatting(
          sender: v.sender,
          messageType: v.messageType,
          replyTo: v.replyTo,
          width: width,
          data: InkWell(
            onTap: () => launchURL(url),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Icon(
                //   Icons.attach_file,
                //   color: v.messageType == "USER" ? Colors.white : AccentBlue,
                // ),
                // Text("Attachment",
                //     style: GoogleFonts.roboto(
                //         fontSize: 15,
                //         fontWeight: FontWeight.w700,
                //         color: v.messageType == "USER"
                //             ? Colors.white
                //             : AccentBlue)),
                VideoPlayerFormat(
                  url: url,
                  messageType: v.messageType,
                )
              ],
            ),
          ),
          media: false,
          timestamp: v.created != null
              ? v.created.toString()
              : DateTime.now().toString(),
        ));
        break;
      case "unsent":
        messageLayout.add(Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(color: Colors.grey)),
          child: Column(
            children: <Widget>[
              MessageFormatting(
                messageType: v.messageType,
                replyTo: v.replyTo,
                width: width,
                data: Text(v.message ?? "",
                    style: GoogleFonts.roboto(
                        fontSize: 15,
                        color: v.messageType == "USER" || v.messageType == null
                            ? Colors.white
                            : TextColorDark)),
                media: false,
                timestamp: v.created != null
                    ? v.created.toString()
                    : DateTime.now().toString(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    iconSize: 28,
                    onPressed: () {
                      model.deleteActionMessage();
                      model.sendMessage(msg: v.message);
                    },
                    icon: Icon(
                      Icons.send,
                      color: AccentBlue,
                    ),
                  ),
                  IconButton(
                    iconSize: 28,
                    onPressed: () => model.deleteActionMessage(),
                    icon: Icon(
                      Icons.cancel,
                      color: Danger,
                    ),
                  )
                ],
              )
            ],
          ),
        ));
        break;
      case "event":
        messageLayout.add(Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Column(
              children: <Widget>[
                Text(v.message ?? "",
                    style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: TextColorMedium)),
                Text(
                    v.created != null
                        ? dateFromat(v.created.toLocal()) == "date"
                            ? DateFormat.MMMd().format(v.created.toLocal()) +
                                ", " +
                                DateFormat.jm().format(v.created.toLocal())
                            : dateFromat(v.created.toLocal()) == "time"
                                ? DateFormat.jm().format(v.created.toLocal())
                                : timeago.format(v.created.toLocal())
                        : timeago.format(DateTime.now()),
                    style: GoogleFonts.roboto(
                        fontSize: 12, color: TextColorMedium))
              ],
            ),
          ),
        ));
        break;
      case "other":
      // print(v.message);
    }
  });

  return messageLayout;
}

class MessageFormatting extends StatelessWidget {
  const MessageFormatting(
      {Key key,
      @required this.data,
      @required this.messageType,
      @required this.width,
      @required this.timestamp,
      this.media,
      this.replyTo,
      this.replyToAction,
      this.sender})
      : super(key: key);

  final Widget data;
  final String messageType;
  final double width;
  final bool media;
  final String timestamp;
  final String replyTo;
  final String sender;
  final Function replyToAction;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: messageType == "USER" || messageType == null
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                padding: EdgeInsets.symmetric(
                    vertical: 2, horizontal: (media ? 2 : 10)),
                decoration: BoxDecoration(
                  color: messageType == "USER" || messageType == null
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (replyTo != null)
                        GestureDetector(
                          onTap: replyToAction,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.reply,
                                color: Colors.white,
                                size: 16,
                              ),
                              Text(" Show original message",
                                  style: GoogleFonts.roboto(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      data,
                    ],
                  ),
                )),
            // To hide sender's email
            // if (sender != null)
            //   Text(sender,
            //       style: GoogleFonts.roboto(
            //           fontSize: 12,
            //           color: TextColorMedium,
            //           fontWeight: FontWeight.bold)),
            Text(
                timestamp == null
                    ? ""
                    : dateFromat(DateTime.parse(timestamp).toLocal()) == "date"
                        ? DateFormat.MMMd()
                                .format(DateTime.parse(timestamp).toLocal()) +
                            ", " +
                            DateFormat.jm()
                                .format(DateTime.parse(timestamp).toLocal())
                        : dateFromat(DateTime.parse(timestamp).toLocal()) ==
                                "time"
                            ? DateFormat.jm()
                                .format(DateTime.parse(timestamp).toLocal())
                            : timeago.format(DateTime.parse(timestamp)),
                style:
                    GoogleFonts.roboto(fontSize: 12, color: TextColorMedium)),
          ],
        ));
  }
}

dateFromat(DateTime messageDate) {
  DateTime now = DateTime.now();
  if (messageDate == null) messageDate = DateTime.now();
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
