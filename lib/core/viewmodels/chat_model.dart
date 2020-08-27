import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/message_type.dart';
import 'package:support_agent/core/models/messages.dart';
import 'package:support_agent/core/models/send_message.dart';
import 'package:support_agent/core/models/template.dart';
import 'package:support_agent/core/models/ticket_settings.dart';
import 'package:support_agent/core/models/tickets.dart';
import 'package:support_agent/core/services/api.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/services/bot_service.dart';
import 'package:support_agent/core/services/common.dart';
import 'package:support_agent/core/services/custom_details.dart';
import 'package:support_agent/core/services/ticket_service.dart';
import 'package:support_agent/core/services/xmpp_service.dart';
import 'package:support_agent/ui/shared/color.dart';

import '../../locator.dart';
import 'base_model.dart';

class ChatModel extends BaseModel {
  Api _api = locator<Api>();

  AuthenticationService _authService =
      locator<AuthenticationService>(); //For Auth Key
  BotService _botService = locator<BotService>(); // For current Bot
  TicketService _ticketService = locator<TicketService>();

  XmppService _xmppService = locator<XmppService>();
  CustomDataService _customDataService = locator<CustomDataService>();
  Ticket _ticket;
  Ticket get currentTicket => _ticket;
  List<Message> _messages;
  List<Message> get messages => _messages;
  StreamSubscription messageEvents;
  bool _typing = false;
  bool get typing => _typing;
  final _chatMessageController = TextEditingController();
  TextEditingController get chatMessageController => _chatMessageController;
  Timer _debounce;
  String query = "";
  int _debouncetime = 1500;
  CustomFields customFields;
  Map<String, dynamic> customFieldsWithNames;
  List<CannedResponse> cannedResponses = List<CannedResponse>();
  List<CannedResponse> filtered = List<CannedResponse>();

  Future initChat(Ticket ticket, BuildContext context) async {
    setState(ViewState.Busy);
    _ticket = ticket;
    //API call.
    String authKey = _authService.currentUserData.accessToken;
    String botId = _botService.defaultBot.userName;
    String uid = ticket.uid;
    String ticketID = ticket.ticketId;
    _chatMessageController.addListener(_onMessageChanged);

    var messages = await _api.getChatMessages(authKey, uid, botId, ticketID);
    if (messages != null) {
      _messages = messages.data;

      _messages.sort((a, b) {
        var adate = a.created;
        var bdate = b.created;
        return adate.compareTo(bdate);
      });
    } else {
      _messages = List<Message>();
    }
    messageEvents =
        _xmppService.chatStreamController.stream.listen(_updateMessageList);
    // _configureSelectNotificationSubject(context);
    getSettings();
    getTemplate();

    setState(ViewState.Idle);
    messagePolling();
    return true;
  }

  messagePolling() {
    String authKey = _authService.currentUserData.accessToken;
    String botId = _botService.defaultBot.userName;
    String uid = _ticket.uid;
    String ticketID = _ticket.ticketId;
    Timer.periodic(Duration(seconds: 10), (Timer t) async {
      var messages = await _api.getChatMessages(authKey, uid, botId, ticketID);
      if (messages != null) {
        // print("getting new messages");
        messages.data.sort((a, b) {
          var adate = a.created;
          var bdate = b.created;
          return adate.compareTo(bdate);
        });

        setState(ViewState.Busy);
        _messages = messages.data;
        setState(ViewState.Idle);
      }
    });
  }

  @override
  void dispose() {
    messageEvents.cancel();
    _ticketService.setCurrentTicketId("");
    super.dispose();
  }

  _updateMessageList(String data) {
    MessageFormat incoming;
    if (data != "Stream Connected")
      try {
        incoming = MessageFormat.fromJson(jsonDecode(data));
        if (incoming.type == "sender" &&
            incoming.ticketId == _ticket.ticketId) {
          setState(ViewState.Busy);
          if (incoming.data['typing'] == null &&
              incoming.data['message'] != null &&
              _messages[_messages.length - 1].message !=
                  incoming.data['message']) {
            _messages.add(Message(
                message: incoming.data['message'],
                messageType: "USER",
                messageFormat: "text"));
          } else if (incoming.data['typing'] == null &&
              incoming.data['image'] != null) {
            _messages.add(Message(
                message: incoming.data['image'],
                messageType: "USER",
                messageFormat: "image"));
          } else if (incoming.data['typing'] == null &&
              incoming.data['file'] != null) {
            _messages.add(Message(
                message: incoming.data['file'],
                messageType: "USER",
                messageFormat: "file"));
          } else {
            showTyping(incoming.data['typing']);
          }
        } else if (incoming.type == "sender" &&
            incoming.ticketId != _ticket.ticketId) {
          if (incoming.data['typing'] == null &&
              incoming.data['message'] != null) {
            // sendNotification(incoming.contact.name, incoming.data['message'],
            // payload: incoming.ticketId);
          }
        }
      } catch (e) {
        // print(e);
      }
    setState(ViewState.Idle);
  }

  _onMessageChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: _debouncetime), () {
      sendMessage(msg: _chatMessageController.text, typing: false);
    });
  }

  showTyping(bool typing) {
    setState(ViewState.Busy);
    _typing = typing;
    setState(ViewState.Idle);
  }

  sendMessage({String msg, bool typing}) async {
    SendMessage myMessage = SendMessage(
        message: "",
        messageType: "AGENT",
        agentId: "you",
        uid: _ticket.uid,
        source: _ticket.source,
        created: DateTime.now().toIso8601String(),
        ticketId: _ticket.ticketId,
        type: "object");
    String message, type;
    if (typing != null) {
      message = "{\"typing\":${typing.toString()}}";
      type = "object";
    } else {
      Map messageJson = {"message": msg};
      // message = "{\"message\":\"${json.encode(msg)}\"}";
      message = jsonEncode(messageJson);
      type = "message";
    }
    myMessage.message = message;
    myMessage.type = type;
    if (type == "object" || msg != "") {
      await _api.sendMessage(_authService.currentUserData.accessToken,
          _botService.defaultBot.userName, myMessage);
      if (typing == null) {
        setState(ViewState.Busy);
        chatMessageController.clear();
        _messages.add(Message(
            message: msg,
            messageType: "AGENT",
            messageFormat: "text",
            created: DateTime.now()));
        setState(ViewState.Idle);
      }
    }
  }

  closeTicket(BuildContext context) async {
    // refactor later
    int customRequiredCount = 0;
    if (customFields != null) {
      customFields.fields.forEach((key, value) {
        if (value.requiredToCloseTicket) customRequiredCount++;
      });
    }
    if (customRequiredCount == 0) {
      _showConfirmDialog(context,
          title: "Are you Sure?",
          child: Text(
            "This ticket will be marked as closed.",
          ), action: () {
        Navigator.pop(context, 1);
        String authKey = _authService.currentUserData.accessToken;
        String botId = _botService.defaultBot.userName;
        String ticketId = _ticket.ticketId;

        _api
            .closeTicket(authKey, botId, ticketId)
            .then((value) => Navigator.pop(context, 1));
      });
    } else {
      await _customDataService.getCustomData();

      _showConfirmDialog(context,
          title: "Please fill the following",
          child: showCustomFields(), action: () {
        Navigator.pop(context, 1);
        _showConfirmDialog(context,
            title: "Are you Sure?",
            child: Text(
              "This ticket will be marked as closed.",
            ), action: () {
          Navigator.pop(context, 1);
          String authKey = _authService.currentUserData.accessToken;
          String botId = _botService.defaultBot.userName;
          String ticketId = _ticket.ticketId;

          _api
              .closeTicket(authKey, botId, ticketId)
              .then((value) => Navigator.pop(context, 1));
        });
      });
    }
  }

  showCustomFields() {
    if (customFields.fields.length == 0) {
      return null;
    }

    List<Widget> customFieldsView = List<Widget>();
    customFields.fields.forEach((key, value) {
      if (value.requiredToCloseTicket)
        customFieldsView.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  capitalize(value.name),
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w500,
                      color: TextColorMedium,
                      fontSize: 16),
                ),
                SizedBox(height: 6),
                TextFormField(
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Text is empty';
                    }
                    return null;
                  },
                  initialValue: currentTicket.customFieldsValues != null
                      ? currentTicket.customFieldsValues.fields[key]
                      : _customDataService.customData != null &&
                              _customDataService.customData.containsKey(
                                  _botService.defaultBot.userName) &&
                              _customDataService
                                  .customData[_botService.defaultBot.userName]
                                  .containsKey(_ticket.ticketId)
                          ? _customDataService
                                  .customData[_botService.defaultBot.userName]
                              [_ticket.ticketId][key]
                          : "",
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    hintText: value.description,
                    labelText: value.description,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    hintStyle: GoogleFonts.roboto(
                        fontWeight: FontWeight.w400,
                        fontSize: 18.0,
                        color: TextColorLight),
                  ),
                  onFieldSubmitted: (text) {
                    updateCustomFields(key, text);
                    setState(ViewState.Busy);
                    currentTicket.customFieldsValues.fields[key] = text;
                    setState(ViewState.Idle);
                  },
                ),
              ],
            ),
          ),
        );
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: customFieldsView,
    );
  }

  updateCustomFields(String fieldKey, String fieldValue) async {
    var update = await _api.updateCustomFields(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName,
        currentTicket.ticketId,
        {fieldKey: fieldValue});
    print(update);
  }

  transferTicket() async {
    String authKey = _authService.currentUserData.accessToken;
    String botId = _botService.defaultBot.userName;
    String ticketId = _ticket.ticketId;

    // var tResponse = await _api.transferTicket(authKey, botId, ticketId);
    // if(closeResponse != null){
    //   print(closeResponse);
    // }
  }

  uploadImage(String path, BuildContext context) async {
    _showAlertDialog(context);
    var res;
    print(path);
    await _api
        .uploadImage(_authService.currentUserData.accessToken,
            _botService.defaultBot.userName, path)
        .then((v) {
      res = v;
      Navigator.of(context).pop();
    });
    SendMessage myMessage = SendMessage(
        message: "{\"image\":\"$res\"}",
        messageType: "AGENT",
        agentId: "you",
        uid: _ticket.uid,
        source: _ticket.source,
        created: DateTime.now().toIso8601String(),
        ticketId: _ticket.ticketId,
        type: "object");

    var response = await _api.sendMessage(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName,
        myMessage);
    // print(response);
    setState(ViewState.Busy);
    _messages.add(Message(
        message: res,
        messageType: "AGENT",
        messageFormat: "image",
        created: DateTime.now()));
    setState(ViewState.Idle);
  }

  uploadFile(String path, BuildContext context) async {
    _showAlertDialog(context,
        title: "Uploading file", child: Image.asset("images/upload.gif"));
    var res;
    await _api
        .uploadImage(_authService.currentUserData.accessToken,
            _botService.defaultBot.userName, path)
        .then((v) {
      res = v;
      Navigator.of(context).pop();
    });
    // print(res);
    SendMessage myMessage = SendMessage(
        message: "{\"file\":\"$res\"}",
        messageType: "AGENT",
        agentId: "you",
        uid: _ticket.uid,
        source: _ticket.source,
        created: DateTime.now().toIso8601String(),
        ticketId: _ticket.ticketId,
        type: "object");

    var response = await _api.sendMessage(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName,
        myMessage);
    // print(response);
    setState(ViewState.Busy);
    _messages.add(Message(
        message: res,
        messageType: "AGENT",
        messageFormat: "file",
        created: DateTime.now()));
    setState(ViewState.Idle);
  }

  getSettings() async {
    var settings = await _api.getSettings(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName);
    setState(ViewState.Busy);
    customFields = settings.data.settings.customFields;
    if (customFields != null)
      customFieldsWithNames = generateUniqueCustomFieldNames(customFields);
    setState(ViewState.Idle);
  }

  changeItems(List<CannedResponse> temp) {
    setState(ViewState.Busy);
    filtered = temp;
    setState(ViewState.Idle);
  }

  getTemplate() async {
    var template = await _api.getTemplate(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName);
    setState(ViewState.Busy);
    cannedResponses = template.data;
    filtered = cannedResponses;
    setState(ViewState.Idle);
  }

  _showAlertDialog(BuildContext context, {String title, Widget child}) {
    AlertDialog alert = AlertDialog(
      title: Text(title ?? "Please wait..."),
      content: child ?? SizedBox.shrink(),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showConfirmDialog(BuildContext context,
      {String title, Widget child, Function() action}) {
    AlertDialog alert = AlertDialog(
      title: Text(title ?? "Please wait..."),
      actions: <Widget>[
        FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Cancel",
              style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500, color: Danger, fontSize: 16),
            )),
        FlatButton(onPressed: action, child: Text("Confirm"))
      ],
      content: child ?? SizedBox.shrink(),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  String mapValues(String text) {
    RegExp regExp = new RegExp(r"{{([\:\/\-\\\,\.a-zA-Z0-9\s])*}}");

    var matches = regExp.allMatches(text);

    matches.forEach((element) {
      switch (element.group(0)) {
        case "{{agent.name}}":
          text = text.replaceAll(
              element.group(0), _authService.currentUserData.user.name);
          break;
        case "{{agent.email}}":
          text = text.replaceAll(
              element.group(0), _authService.currentUserData.user.email);
          break;
        case "{{agent.username}}":
          text = text.replaceAll(
              element.group(0), _authService.currentUserData.username);
          break;
        case "{{bot.botDesc}}":
          text =
              text.replaceAll(element.group(0), _botService.defaultBot.botDesc);
          break;
        case "{{bot.botName}}":
          text =
              text.replaceAll(element.group(0), _botService.defaultBot.botName);
          break;
        case "{{bot.botTitle}}":
          text = text.replaceAll(
              element.group(0), _botService.defaultBot.botTitle);
          break;
        case "{{profile.name}}":
          text = text.replaceAll(element.group(0), _ticket.agentProfile.name);
          break;
        case "{{ticket.comments}}":
          text = text.replaceAll(element.group(0), _ticket.comments[0]);
          break;
        case "{{ticket.contact.email}}":
          text = text.replaceAll(element.group(0), _ticket.contact.email);
          break;
        case "{{ticket.contact.name}}":
          text = text.replaceAll(element.group(0), _ticket.contact.name);
          break;
        case "{{ticket.contact.phone}}":
          text = text.replaceAll(element.group(0), _ticket.contact.phone);
          break;
        case "{{ticket.issue}}":
          text = text.replaceAll(element.group(0), _ticket.issue);
          break;
        case "{{ticket.ticketId}}":
          text = text.replaceAll(element.group(0), _ticket.ticketId);
          break;
        default:
          RegExp regex =
              RegExp(r"{{ticket.custom.([\:\/\-\\\,\.a-zA-Z0-9\s])*}}");
          var matches = regExp.allMatches(text);
          matches.forEach((item) {
            var str = item
                .group(0)
                .replaceAll("}}", "")
                .replaceAll("{{", "")
                .split(".")[2];
            text = text.replaceAll(
                item.group(0),
                currentTicket.customFieldsValues
                        .fields[customFieldsWithNames["nameMap"][str]] ??
                    "");
          });
      }
    });
    return text;
  }

  Map<String, dynamic> generateUniqueCustomFieldNames(
      CustomFields customFields) {
    Map customFieldMap = {};
    Map keyToGeneratedNameMap = {};
    List customFieldNames = [];

    customFields.fields.forEach((key, customField) {
      var camelCaseName = toCamelCase(customField.name);
      var generatedName = camelCaseName;
      if (customFieldMap[camelCaseName] != null) {
        var currentLength = customFieldMap[camelCaseName].length;
        var nextName = '$camelCaseName${(currentLength + 1)}';
        generatedName = nextName;
        customFieldMap[camelCaseName].push(nextName);
        customFieldNames.add(generatedName);
      } else {
        customFieldMap[camelCaseName] = camelCaseName;
      }
      customFieldNames.add(generatedName);
      keyToGeneratedNameMap[generatedName] = key;
    });

    return {
      "nameMap": keyToGeneratedNameMap,
      "fields": customFieldNames,
    };
  }
}
