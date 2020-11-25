import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/actions.dart';
import 'package:support_agent/core/models/collaborators.dart';
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
import 'package:support_agent/ui/widgets/customfields.dart';
import 'package:support_agent/ui/widgets/message_layout.dart';

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

  AgentProfile agentProfile;
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
  TicketSettings ticketSettings;
  CustomFields customFields;
  Map<String, dynamic> customFieldsWithNames;
  List<CannedResponse> cannedResponses = List<CannedResponse>();
  List<CannedResponse> filtered = List<CannedResponse>();
  List<ActionResponses> actionResponses = List<ActionResponses>();
  List<ActionResponses> filteredActions = List<ActionResponses>();
  bool actionPending = false;
  ActionResponses selectedAction;
  Map actionParms = Map();
  List<CollaboratorProfile> collaborators = List<CollaboratorProfile>();
  List<String> sentMessageIds = List<String>();

  Future initChat(Ticket ticket, BuildContext context) async {
    setState(ViewState.Busy);
    _ticket = ticket;
    //API call.
    String authKey = _authService.currentUserData.accessToken;
    String botId = _botService.defaultBot.userName;
    String uid = ticket.uid;
    String ticketID = ticket.ticketId;

    _chatMessageController.addListener(_onMessageChanged);

    var fetchCollabs = await _api.getCollaboratorsList(authKey, botId);
    collaborators = fetchCollabs.data;

    _ticket = await _api.getTicketInfo(authKey, ticketID, botId);

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
    getSettings();
    getActions();
    getTemplate();

    setState(ViewState.Idle);
    // messagePolling();
    return true;
  }

  updateCollaborators(List<String> collabs) async {
    var result = await _api.updateCollaboratorsList(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName,
        _ticket.ticketId,
        collabs);

    _ticket = await _api.getTicketInfo(_authService.currentUserData.accessToken,
        _ticket.ticketId, _botService.defaultBot.userName);
  }

  List<Collaborators> getCurrentCollabs() {
    for (var item in _ticket.collaborators) {
      print(item.name);
    }
    return _ticket.collaborators;
  }

  getActions() async {
    var actions = await _api.getActions(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName);
    setState(ViewState.Busy);
    actionResponses = actions.data;
    filteredActions = actionResponses;
    setState(ViewState.Idle);
  }

  setAction(ActionResponses action) {
    setState(ViewState.Busy);
    actionPending = true;
    selectedAction = action;
    setState(ViewState.Idle);
  }

  sendAction() async {
    Map data = {
      "uid": _ticket.uid,
      "source": _ticket.source,
      "data": {'action': selectedAction.name, 'params': actionParms}
    };

    var actionSent = await _api.sendActions(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName,
        data);
    print(actionSent);
    setState(ViewState.Busy);
    if (actionSent['data'] != null &&
        actionSent['data']['messageArray'] != null)
      _messages.add(Message(
          message: actionSent['data']['messageArray'].length != 0
              ? actionSent['data']['messageArray'][0]['message']
              : "",
          messageType: "AGENT",
          messageFormat: "unsent",
          created: DateTime.now()));

    _ticket = await _api.getTicketInfo(_authService.currentUserData.accessToken,
        _ticket.ticketId, _botService.defaultBot.userName);
    setState(ViewState.Idle);
  }

  Timer timer;
  messagePolling() {
    String authKey = _authService.currentUserData.accessToken;
    String botId = _botService.defaultBot.userName;
    String uid = _ticket.uid;
    String ticketID = _ticket.ticketId;
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) async {
      var messages = await _api.getChatMessages(authKey, uid, botId, ticketID);
      if (messages != null) {
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

  void disposeAll() {
    messageEvents.cancel();
    _ticketService.setCurrentTicketId("");
  }

  void deleteActionMessage() {
    setState(ViewState.Busy);
    _messages.removeWhere((element) => element.messageFormat == "unsent");
    _chatMessageController.clear();
    actionPending = false;
    setState(ViewState.Idle);
  }

  void _populateActionParms() {
    actionParms.clear();

    var paramText =
        chatMessageController.text.replaceFirst(selectedAction.name, '');
    final pattern = RegExp('\\s+');
    paramText = paramText.replaceAll(pattern, " ").trim();
    var paramsArray = paramText.split(' ');
    setState(ViewState.Busy);
    for (var i = 0; i < selectedAction.steps.length; i++) {
      actionParms[selectedAction.steps[i].slug] =
          paramsArray.length != i ? paramsArray[i] : "";
    }
    setState(ViewState.Idle);
  }

  showActionPrompt(BuildContext context) async {
    _showConfirmDialog(context,
        title: "Agent Action Parameters for ${selectedAction.name}",
        child: showActionFields(), action: () {
      Navigator.pop(context, 1);
      sendAction().then((value) => chatMessageController.clear());
    });
  }

  showActionFields() {
    if (selectedAction.steps.length == 0) {
      return null;
    }

    List<Widget> actionFieldsView = List<Widget>();
    actionParms.forEach((key, value) {
      actionFieldsView.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                capitalize(key),
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
                initialValue: value,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  hintText: key,
                  labelText: key,
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
                onChanged: (text) {
                  // updateCustomFields(key, text);
                  setState(ViewState.Busy);
                  actionParms[key] = text;
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
      children: actionFieldsView,
    );
  }

  _updateMessageList(String data) {
    print(data);
    MessageFormat incoming;
    if (data != "Stream Connected")
      try {
        incoming = MessageFormat.fromJson(jsonDecode(data));

        if (incoming.ticketId == _ticket.ticketId) {
          setState(ViewState.Busy);
          if (incoming.data['typing'] == null &&
                  incoming.data["event"] == null &&
                  incoming.data['message'] != null
              // && _messages[_messages.length - 1].message !=
              //     incoming.data['message']
              ) {
            if (incoming.agentId != null &&
                incoming.agentId == _authService.currentUserData.user.email &&
                !sentMessageIds.contains(incoming.data["_id"])) {
              sentMessageIds.add(incoming.data["_id"]);
              _messages.add(Message(
                  sender: incoming.agentId,
                  message: incoming.data['message'],
                  messageType: incoming.messageType,
                  messageFormat: "text",
                  replyTo: incoming.data['replyTo'] ?? null));
            } else if (incoming.agentId == null ||
                incoming.agentId != _authService.currentUserData.user.email) {
              _messages.add(Message(
                  sender: incoming.agentId,
                  message: incoming.data['message'],
                  messageType: incoming.messageType,
                  messageFormat: "text",
                  replyTo: incoming.data['replyTo'] ?? null));
            }
          } else if (incoming.data["event"] != null) {
            //to set events
            if (incoming.data["event"]["code"] == "bot-message-notification") {
              if (incoming.data["event"]["data"]["message"] != null) {
                _messages.add(Message(
                    message: incoming.data["event"]["data"]["message"],
                    messageType: incoming.messageType ?? "BOT",
                    messageFormat: "text",
                    replyTo: null));
              } else if (incoming.data["event"]['data']['image'] != null) {
                _messages.add(Message(
                    sender: incoming.agentId,
                    message: incoming.data["event"]['data']['image'],
                    messageType: incoming.messageType,
                    messageFormat: "image",
                    caption: incoming.data["event"]['data']['options'] != null
                        ? incoming.data["event"]['data']['options']["caption"]
                        : incoming.data["event"]['data']['caption'] ?? null,
                    replyTo: incoming.data['replyTo'] ?? null));
              } else if (incoming.data["event"]['data']['file'] != null) {
                _messages.add(Message(
                    sender: incoming.agentId,
                    message: incoming.data["event"]['data']['file'],
                    messageType: incoming.messageType,
                    messageFormat: "file",
                    replyTo: incoming.data['replyTo'] ?? null));
              } else if (incoming.data["event"]['data']['video'] != null) {
                _messages.add(Message(
                    sender: incoming.agentId,
                    message: incoming.data["event"]['data']['video'],
                    messageType: incoming.messageType,
                    messageFormat: "video",
                    caption: incoming.data["event"]['data']['options'] != null
                        ? incoming.data["event"]['data']['options']["caption"]
                        : incoming.data["event"]['data']['caption'] ?? null,
                    replyTo: incoming.data['replyTo'] ?? null));
              }
            } else {
              _messages.add(Message(
                  message: incoming.data["event"]["data"]["message"],
                  messageType: incoming.messageType ?? "BOT",
                  messageFormat: "event",
                  replyTo: null));
            }
          } else if (incoming.data['image'] != null) {
            _messages.add(Message(
                sender: incoming.agentId,
                message: incoming.data['image'],
                messageType: incoming.messageType,
                messageFormat: "image",
                replyTo: incoming.data['replyTo'] ?? null));
          } else if (incoming.data['file'] != null) {
            _messages.add(Message(
                sender: incoming.agentId,
                message: incoming.data['file'],
                messageType: incoming.messageType,
                messageFormat: "file",
                replyTo: incoming.data['replyTo'] ?? null));
          } else if (incoming.data['video'] != null) {
            _messages.add(Message(
                sender: incoming.agentId,
                message: incoming.data['video'],
                messageType: incoming.messageType,
                messageFormat: "video",
                replyTo: incoming.data['replyTo'] ?? null));
          } else {
            showTyping(incoming.data['typing']);
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
      if (!actionPending) {
        sendMessage(msg: _chatMessageController.text, typing: false);
      }
    });
  }

  showTyping(bool typing) {
    setState(ViewState.Busy);
    _typing = typing;
    setState(ViewState.Idle);
  }

  sendMessage({
    String msg,
    bool typing,
  }) async {
    if (actionPending) {
      _populateActionParms();
    } else {
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
        var messageResponse = await _api.sendMessage(
            _authService.currentUserData.accessToken,
            _botService.defaultBot.userName,
            myMessage);
        print("priyank: " + messageResponse.toString());
        if (typing == null &&
            messageResponse != null &&
            messageResponse["success"]) {
          setState(ViewState.Busy);
          chatMessageController.clear();
          var messageId = messageResponse["data"]["_id"];
          print(messageId);
          if (!sentMessageIds.contains(messageId)) {
            sentMessageIds.add(messageId);
            _messages.add(Message(
                sender: _authService.currentUserData.user.email,
                message: msg,
                messageType: "AGENT",
                messageFormat: "text",
                created: DateTime.now()));
          }
          setState(ViewState.Idle);
        }
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

        _api.closeTicket(authKey, botId, ticketId).then((value) {
          _customDataService.setDefault({
            botId: {ticketId: null}
          });
          Navigator.pop(context, 1);
        });
      });
    } else {
      await _customDataService.getCustomData();

      _showCustomFieldsDialog(context,
          title: "Please fill the following",
          child: showCustomFields(context), action: () {
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

  showCustomFields(BuildContext context) {
    if (customFields.fields.length == 0) {
      return null;
    }

    List<Widget> customFieldsView = List<Widget>();
    customFields.fields.forEach((fieldKey, value) {
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
                value.type == "checkboxes"
                    ? CheckBoxCustomWidget(value, this, fieldKey)
                    : value.type == "date"
                        ? DateCustomFieldWidget(value, this, fieldKey)
                        : value.type == "tags"
                            ? TagsCustomFieldWidget(value, this, fieldKey)
                            : TextFormField(
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Text is empty';
                                  }
                                  return null;
                                },
                                initialValue: currentTicket.customFieldsValues != null
                                    ? currentTicket
                                        .customFieldsValues.fields[fieldKey]
                                    : _customDataService.customData != null &&
                                            _customDataService.customData
                                                .containsKey(_botService
                                                    .defaultBot.userName) &&
                                            _customDataService.customData[
                                                    _botService
                                                        .defaultBot.userName]
                                                .containsKey(_ticket.ticketId)
                                        ? _customDataService
                                                .customData[_botService.defaultBot.userName]
                                            [_ticket.ticketId][fieldKey]
                                        : "",
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  hintText: value.description,
                                  labelText: value.description,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  hintStyle: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18.0,
                                      color: TextColorLight),
                                ),
                                onChanged: (text) {
                                  updateCustomFields(fieldKey, text);
                                  setState(ViewState.Busy);
                                  currentTicket.customFieldsValues
                                      .fields[fieldKey] = text;
                                  setState(ViewState.Idle);
                                },
                              ),
              ],
            ),
          ),
        );
    });
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: customFieldsView),
        ),
      ),
    );
  }

  updateCustomFields(String fieldKey, dynamic fieldValue) async {
    await _api.updateCustomFields(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName,
        currentTicket.ticketId,
        {fieldKey: fieldValue});
    // print(update);
  }

  transferTicket() async {
    // String authKey = _authService.currentUserData.accessToken;
    // String botId = _botService.defaultBot.userName;
    // String ticketId = _ticket.ticketId;

    // var tResponse = await _api.transferTicket(authKey, botId, ticketId);
    // if(closeResponse != null){
    //   print(closeResponse);
    // }
  }

  uploadImage(String path, BuildContext context) async {
    _showAlertDialog(context);
    var res;
    // print(path);
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
    ticketSettings = settings;

    var ticketInfo = await _api.getTicketInfo(
        _authService.currentUserData.accessToken,
        _ticket.ticketId,
        _botService.defaultBot.userName);

    agentProfile = ticketInfo.agentProfile;

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

  _showCustomFieldsDialog(BuildContext context,
      {String title, Widget child, Function() action}) {
    Widget alert = Container(
        color: Colors.white,
        child: Column(children: <Widget>[
          AppBar(
            title: Text(title ?? "Please wait..."),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: child ?? SizedBox.shrink(),
          ),
          Divider(),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          color: Danger,
                          fontSize: 16),
                    )),
                FlatButton(
                    onPressed: action,
                    child: Text(
                      "Confirm",
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          color: AccentBlue,
                          fontSize: 16),
                    ))
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

  replyToAction(String replyTo, BuildContext context) async {
    var replyMessage = await _api.getReplyMessage(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName,
        replyTo);
    var replyMessageResponse = Message.fromJson(replyMessage["data"]);
    String msg;
    if (replyMessageResponse.message[0] == "{" &&
        replyMessageResponse.message[replyMessageResponse.message.length - 1] ==
            "}") {
      try {
        Map<String, dynamic> currentMsg =
            json.decode(replyMessageResponse.message);
        msg = currentMsg['message'] ?? "";
      } catch (e) {}
    } else {
      msg = replyMessageResponse.message;
    }
    _showAlertDialog(
      context,
      title:
          "Original message was sent by ${capitalize(replyMessageResponse.messageType)}",
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AccentBlue,
              width: 4.0,
            ),
          ),
        ),
        child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: MessageLayout([replyMessageResponse],
                      MediaQuery.of(context).size.width, this, context),
                )) ??
            SizedBox.shrink(),
      ),
    );
  }
}
