import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/template.dart';
import 'package:support_agent/core/models/tickets.dart';
import 'package:support_agent/core/services/common.dart';
import 'package:support_agent/core/viewmodels/chat_model.dart';
import 'package:support_agent/ui/shared/color.dart';
import 'package:support_agent/ui/views/base_view.dart';
import 'package:support_agent/ui/widgets/message_layout.dart';

class ChatPage extends StatelessWidget {
  final Ticket ticket;
  final bool isArchive;
  ChatPage({Key key, this.ticket, this.isArchive}) : super(key: key);

  void choiceAction(String choice, BuildContext context, ChatModel model) {
    if (choice == "Transfer ticket") {
      Navigator.pushNamed(context, 'transfer', arguments: model.currentTicket);
    } else if (choice == "Close ticket") {
      model.closeTicket(context);
    } else if (choice == "Ticket info") {
      Navigator.pushNamed(context, 'ticket_info',
          arguments: model.currentTicket);
    }
  }

  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BaseView<ChatModel>(
        onModelReady: (model) async => await model.initChat(ticket, context),
        builder: (context, model, child) => Scaffold(
            appBar: AppBar(
                backgroundColor: AccentBlue,
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      child:
                          Text(getInitials(model.currentTicket.contact.name)),
                      backgroundColor: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(model.currentTicket.contact.name ?? ""),
                          Text(
                            isArchive
                                ? "This ticket has been closed."
                                : model.typing != null
                                    ? model.typing ? "typing..." : "Online"
                                    : "",
                            style: GoogleFonts.roboto(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                centerTitle: false,
                actions: <Widget>[
                  isArchive
                      ? IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'ticket_info',
                                arguments: model.currentTicket);
                          },
                          icon: Icon(Icons.info),
                        )
                      : PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert),
                          onSelected: (choice) =>
                              choiceAction(choice, context, model),
                          itemBuilder: (BuildContext context) {
                            return Constants.choices.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                        )
                ]),
            body: model.state == ViewState.Busy
                ? Center(
                    child: Text(
                        "Please wait while we are loading conversations..."),
                  )
                : model.messages.length == 0
                    ? Center(
                        child: Text("There was an error..."),
                      )
                    : Column(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: GestureDetector(
                              onTap: () => _focusNode.unfocus(),
                              child: SingleChildScrollView(
                                  reverse: true,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    child: Column(
                                        children: MessageLayout(model.messages,
                                            MediaQuery.of(context).size.width)),
                                  )),
                            ),
                          ),
                          isArchive
                              ? Container(
                                  margin: EdgeInsets.all(20),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Divider(),
                                      ),
                                      Text(
                                        "Ticket Ended",
                                        style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: TextColorLight),
                                      ),
                                      Expanded(
                                        child: Divider(),
                                      ),
                                    ],
                                  ),
                                )
                              : Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          IconButton(
                                              icon: Icon(Icons.add),
                                              color: AccentBlue,
                                              onPressed: () {
                                                containerForSheet<String>(
                                                  context: context,
                                                  child: CupertinoActionSheet(
                                                    title:
                                                        Text("Add attachment"),
                                                    actions: <Widget>[
                                                      CupertinoActionSheetAction(
                                                        onPressed: () async {
                                                          var imgFile = await ImagePicker
                                                                  .pickImage(
                                                                      source: ImageSource
                                                                          .camera)
                                                              .catchError(
                                                                  (err) =>
                                                                      print(
                                                                          err));
                                                          Navigator.of(context)
                                                              .pop();
                                                          await model
                                                              .uploadImage(
                                                                  imgFile.path,
                                                                  context);
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons.camera_alt,
                                                              size: 24,
                                                              color: AccentBlue,
                                                            ),
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                            Text(
                                                              "Camera",
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                      fontSize:
                                                                          20,
                                                                      color:
                                                                          AccentBlue),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      CupertinoActionSheetAction(
                                                        onPressed: () async {
                                                          var imgFile = await ImagePicker
                                                                  .pickImage(
                                                                      source: ImageSource
                                                                          .gallery)
                                                              .catchError(
                                                                  (err) =>
                                                                      print(
                                                                          err));
                                                          Navigator.of(context)
                                                              .pop();
                                                          await model
                                                              .uploadImage(
                                                                  imgFile.path,
                                                                  context);
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons.image,
                                                              size: 24,
                                                              color: AccentBlue,
                                                            ),
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                            Text(
                                                              "Photo & Video Library",
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                      fontSize:
                                                                          20,
                                                                      color:
                                                                          AccentBlue),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      CupertinoActionSheetAction(
                                                        onPressed: () async {
                                                          File file =
                                                              await FilePicker
                                                                  .getFile();
                                                          await model
                                                              .uploadFile(
                                                                  file.path,
                                                                  context);

                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons.description,
                                                              size: 24,
                                                              color: AccentBlue,
                                                            ),
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                            Text(
                                                              "Document",
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                      fontSize:
                                                                          20,
                                                                      color:
                                                                          AccentBlue),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                    cancelButton:
                                                        CupertinoActionSheetAction(
                                                      child:
                                                          const Text('Cancel'),
                                                      isDefaultAction: true,
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context, 'Cancel');
                                                      },
                                                    ),
                                                  ),
                                                );
                                              }),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: TextField(
                                                  controller: model
                                                      .chatMessageController,
                                                  focusNode: _focusNode,
                                                  maxLines: 3,
                                                  minLines: 1,
                                                  // textInputAction:
                                                  //     TextInputAction.done,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "Type your message...",
                                                    hintStyle:
                                                        GoogleFonts.roboto(
                                                            color: Colors.black
                                                                .withAlpha(120),
                                                            fontSize: 14),
                                                  ),
                                                  onChanged: (text) {
                                                    if (text[0] == "#")
                                                      _openCannedResponses(
                                                          context, model);
                                                    else
                                                      model.sendMessage(
                                                          msg: text,
                                                          typing: true);
                                                  }),
                                            ),
                                          ),
                                          IconButton(
                                            iconSize: 28,
                                            onPressed: () => model.sendMessage(
                                                msg: model.chatMessageController
                                                        .text ??
                                                    ""),
                                            icon: Icon(
                                              Icons.send,
                                              color: AccentBlue,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                        ],
                      )));
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    );
  }

  void _openCannedResponses(context, ChatModel model) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext ctx) {
          return SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: CannedResponseArea(model: model)));
        });
  }

  searchCanned(keyword) {}
}

class CannedResponseArea extends StatefulWidget {
  const CannedResponseArea({
    Key key,
    @required this.model,
  }) : super(key: key);
  final ChatModel model;

  @override
  _CannedResponseAreaState createState() => _CannedResponseAreaState();
}

class _CannedResponseAreaState extends State<CannedResponseArea> {
  List<CannedResponse> filtered = List<CannedResponse>();
  @override
  void initState() {
    super.initState();
    filtered = widget.model.cannedResponses;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> responses = List<Widget>();
    responses.add(Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 20,
      ),
    ));

    filtered.forEach((element) {
      if (element.text != null) {
        responses.add(Center(
          child: Container(
            height: 30,
            width: MediaQuery.of(context).size.width - 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(element.tag + " : ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                Flexible(
                  child: InkWell(
                    onTap: () {
                      widget.model.chatMessageController.text =
                          widget.model.mapValues(element.text);
                      // widget.model.sendMessage(
                      //     msg: widget.model.chatMessageController.text,
                      //     typing: false);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      element.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
      }
    });

    var typeArea = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: TextField(
                // controller: model.chatMessageController,
                autofocus: true,
                decoration: InputDecoration(
                  prefix: Text("#"),
                  hintText: "Short Code",
                  hintStyle: GoogleFonts.roboto(
                      color: Colors.black.withAlpha(120), fontSize: 14),
                ),
                onChanged: (text) {
                  if (text == "#") {
                    filtered = widget.model.cannedResponses;
                  } else {
                    List<CannedResponse> tmpList = List<CannedResponse>();
                    for (int i = 0;
                        i < widget.model.cannedResponses.length;
                        i++) {
                      if (widget.model.cannedResponses[i].tag
                          .toLowerCase()
                          .replaceAll(" ", "")
                          .contains(text.toLowerCase().replaceAll(" ", ""))) {
                        tmpList.add(widget.model.cannedResponses[i]);
                      }
                    }
                    setState(() {
                      filtered = tmpList;
                    });
                    // filtered = tmpList;
                  }
                } //filter responses,
                ),
          ),
          IconButton(
            iconSize: 30,
            icon: Icon(
              Icons.close,
              color: AccentBlue,
            ),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );

    return Container(
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
        ),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: responses,
            ),
            typeArea
          ],
        ));
  }
}

class Constants {
  static const List<String> choices = <String>[
    "Ticket info",
    "Transfer ticket",
    "Close ticket"
  ];
}

class ConstantsArchives {
  static const List<String> choices = <String>[
    "Ticket info",
  ];
}
