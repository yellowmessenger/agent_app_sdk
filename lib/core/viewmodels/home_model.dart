import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_agent/core/enums/agentpresense.dart';

import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/all_bots.dart';
import 'package:support_agent/core/models/appstate.dart';
import 'package:support_agent/core/models/chat_args.dart';
import 'package:support_agent/core/models/message_type.dart';
import 'package:support_agent/core/models/navigationitem.dart';
import 'package:support_agent/core/models/notifications.dart';
import 'package:support_agent/core/models/tickets.dart';
import 'package:support_agent/core/models/userdata.dart';
import 'package:support_agent/core/services/api.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/services/bot_service.dart';
import 'package:support_agent/core/services/common.dart';
import 'package:support_agent/core/services/connectivity.dart';
import 'package:support_agent/core/services/notification_service.dart';
import 'package:support_agent/core/services/ticket_service.dart';
import 'package:support_agent/core/services/xmpp_creds.dart';
import 'package:support_agent/core/services/xmpp_service.dart';
import 'package:support_agent/ui/widgets/mytickets.dart';
import '../../locator.dart';
import 'base_model.dart';

class HomeModel extends BaseModel {
  Api _api = locator<Api>();
  AuthenticationService _authService = locator<AuthenticationService>();
  BotService _botService = locator<BotService>();
  XmppService _xmppService = locator<XmppService>();
  Notifications _notifications = locator<Notifications>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  XmppCredsService _xmppCredsService = locator<XmppCredsService>();
  TicketService _ticketService = locator<TicketService>();
  BuildContext ctx;
  bool _xmppReady = false;
  bool get xmppReady => _xmppReady;
  bool offlineTicketAllowed;
  set xmppReady(bool status) {
    _xmppReady = status;
  }

  static const platform =
      const MethodChannel('com.yellowmessenger.support_agent/data');
  StreamSubscription _connectionChangeStream;

  bool isOffline = false;

  BotMappings _currentBot;
  BotMappings get currentBot => _currentBot;
  StreamSubscription messageEvents;
  User _currentUser;
  User get currentUser => _currentUser;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool presence = false;
  AgentPresenceState agentPresence = AgentPresenceState.Offline;
  AppState _appState = locator<AppState>();

  int currentIndex = 0;
  final List<NavigationItem> navigationItems = [
    NavigationItem(
        icon: Icons.local_activity,
        title: "My Tickets",
        navPage: MyTicketsPage()),
  ];

  initHome(BuildContext context) async {
    setState(ViewState.Busy);
    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    xmppReady = false;
    _currentBot = _botService.defaultBot;
    _configureSelectNotificationSubject(context);
    _currentUser = _authService.currentUserData.user;

    await _xmppConnection();

    if (!_xmppService.chatStreamController.isPaused)
      messageEvents =
          _xmppService.chatStreamController.stream.listen(_updateUI);

    bool isInitializing = await platform.invokeMethod("isInitializeSDK");
    if (!isInitializing)
      Navigator.pushNamedAndRemoveUntil(
          context, 'home', (Route<dynamic> route) => false);
    else {
      debugPrint("SDK Initialized");
      await platform.invokeMethod("close-module");
    }

    var agentResponse = await _api.getAgents(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName);
    if (agentResponse != null) {
      for (var agent in agentResponse.agentItems) {
        if (agent.agentProfile.username == _currentUser.username) {
          presence = agent.status != "available" ? false : true;
          agentPresence = agent.status != "available"
              ? agent.status == "offline"
                  ? AgentPresenceState.Offline
                  : AgentPresenceState.Busy
              : AgentPresenceState.Available;
        }
      }
    }

    // Presence polling
    checkPresence();
    // bool isSetAllowOfflineTicket = await _isSetAllowOfflineTicket();
    pushNotificationStatus("ONLINE");

    // if (!isSetAllowOfflineTicket) {
    //   showAlertDialog(context);
    // }

    setState(ViewState.Idle);
  }

  _xmppConnection() async {
    await _xmppService.initializeXmpp();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(ViewState.Busy);
    isOffline = !hasConnection;
    if (isOffline) {
      xmppReady = !isOffline;
      _xmppService.closeCurrentConnection();
    } else {
      goOnline();
    }

    setState(ViewState.Idle);
  }

  checkPresence() {
    Timer.periodic(Duration(seconds: 30), (Timer t) async {
      setNotification();
      if (xmppReady) {
        var agentResponse = await _api.getAgents(
            _authService.currentUserData.accessToken,
            _botService.defaultBot.userName);

        if (agentResponse != null) {
          for (var agent in agentResponse.agentItems) {
            if (agent.agentProfile.username == _currentUser.username) {
              setState(ViewState.Busy);
              agentPresence = agent.status != "available"
                  ? agent.status == "offline"
                      ? AgentPresenceState.Offline
                      : AgentPresenceState.Busy
                  : AgentPresenceState.Available;
              setState(ViewState.Idle);
              if (agentPresence == AgentPresenceState.Offline &&
                  !_xmppService.chatStreamSubscription.isPaused)
                await _xmppConnection();
            }
          }
        }
      }
    });
  }

  void _configureSelectNotificationSubject(BuildContext context) {
    selectNotificationSubject.stream.listen((String payload) async {
      Ticket ticketRef;
      if (payload != null) {
        Ticket ticketRef = _ticketService.searchById(payload);
      }
      if (ticketRef != null) {
        if (_ticketService.currentTicketId != null)
          await Navigator.popAndPushNamed(context, 'chat_page',
              arguments: ChatScreenArguments(ticketRef, false));
        else
          await Navigator.pushNamed(context, 'chat_page',
              arguments: ChatScreenArguments(ticketRef, false));
      }
    });
  }

  _updateUI(String data) {
    setState(ViewState.Busy);
    MessageFormat incoming;

    if (data != "Stream Connected") {
      if (data[0] == "{" && data[data.length - 1] == "}") {
        try {
          Map<String, dynamic> incomingEvents = jsonDecode(data);
          incoming = MessageFormat.fromJson(jsonDecode(data));
          if (incomingEvents.containsKey("connected")) {
            xmppReady = incomingEvents["connected"];
            agentPresence = !xmppReady
                ? AgentPresenceState.Offline
                : AgentPresenceState.Available;
          }
          if (incomingEvents.containsKey("authenticated")) {
            xmppReady = incomingEvents["authenticated"];
            agentPresence = !xmppReady
                ? AgentPresenceState.Offline
                : AgentPresenceState.Available;
          }
        } catch (e) {}
      }
      try {
        if (incoming.type == "support" &&
            incoming.messageType == "BOT" &&
            incoming.data['event'] == null) {
          sendNotification("New Ticket", incoming.ticketId,
              payload: incoming.toJson());
        } else if (incoming.type == "sender") {
          if (incoming.data['typing'] == null &&
              incoming.data['event'] == null) {
            // checking if chat page is closed....
            // print(_appState.appState);
            if (_ticketService.currentTicketId == null ||
                _appState.appState == AppLifecycleState.paused) {
              sendNotification(incoming.contact.name, incoming.data['message'],
                  payload: incoming.toJson());
            } else if (_ticketService.currentTicketId != incoming.ticketId)
              sendNotification(incoming.contact.name, incoming.data['message'],
                  payload: incoming.toJson());
          }
        }
      } catch (e) {}
    }
    setState(ViewState.Idle);
  }

  void onTabTapped(int index) {
    setState(ViewState.Busy);
    currentIndex = index;
    setState(ViewState.Idle);
  }

  setNotification() async {
    int notificationCount = await _api.getAssignedTicketCount(
        _authService.currentUserData.accessToken,
        _currentBot.userName,
        _currentUser.username);

    _notifications.notificationCount = notificationCount;
    setState(ViewState.Busy);
    navigationItems[0].notifications = notificationCount;
    setState(ViewState.Idle);
  }

  gotoSettings() {
    setState(ViewState.Busy);
    currentIndex = 0;
    setState(ViewState.Idle);
  }

  pushNotificationStatus(String status) async {
    await _api.setNotificationPreference(
        _authService.currentUserData.accessToken, _currentBot.userName, status);
    SharedPreferences prefs = await _prefs;
    await prefs.setBool(
        "allowOfflineTicket", status == "ONLINE" ? true : false);
    await _isSetAllowOfflineTicket();
  }

  _isSetAllowOfflineTicket() async {
    SharedPreferences prefs = await _prefs;
    var allKeys = prefs.getKeys();

    bool allowOfflineTicket = true;
    // allKeys.contains('allowOfflineTicket') ? true : false;

    setState(ViewState.Busy);
    offlineTicketAllowed = allowOfflineTicket;
    setState(ViewState.Idle);

    return allowOfflineTicket;
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("No"),
      onPressed: () {
        pushNotificationStatus("OFFLINE");
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Sure"),
      onPressed: () {
        pushNotificationStatus("ONLINE");
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Notification Settings"),
      content: Text(
          "Would you like to allow ticket creation when not using the app?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // showBatteryDialog(BuildContext context) {
  //   // set up the button
  //   Widget continueButton = FlatButton(
  //     child: Text("Sure"),
  //     onPressed: () {
  //       BatteryOptimization.openBatteryOptimizationSettings();
  //       Navigator.of(context).pop();
  //     },
  //   );

  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: Text("Battery Optimization Settings"),
  //     content: Text(
  //         "Please turn off battery optimization for this app to ensure better performance."),
  //     actions: [
  //       continueButton,
  //     ],
  //   );

  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

  void changePresence(String status) async {
    var response = await _api.changePresence(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName,
        status,
        _xmppCredsService.xmppCreds.username);

    if (response != null) {
      setState(ViewState.Busy);
      agentPresence = status != "available"
          ? status == "offline"
              ? AgentPresenceState.Offline
              : AgentPresenceState.Busy
          : AgentPresenceState.Available;
      setState(ViewState.Idle);
    }
  }

  void goOffline() {
    setState(ViewState.Busy);
    agentPresence = AgentPresenceState.Offline;
    setState(ViewState.Idle);
    _xmppService.closeCurrentConnection();
  }

  void goOnline() {
    _xmppConnection();
  }

  void retryConnection() {
    _xmppConnection();
  }

  dispose() {}
}
