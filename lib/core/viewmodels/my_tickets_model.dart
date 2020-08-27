import 'dart:async';
import 'dart:convert';
import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/message_type.dart';
import 'package:support_agent/core/models/tickets.dart';
import 'package:support_agent/core/services/api.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/services/bot_service.dart';
import 'package:support_agent/core/services/ticket_service.dart';
import 'package:support_agent/core/services/xmpp_service.dart';
import '../../locator.dart';
import 'base_model.dart';

class MyTicketsModel extends BaseModel {
  Api _api = locator<Api>();

  AuthenticationService _authService =
      locator<AuthenticationService>(); //For Auth Key
  BotService _botService = locator<BotService>(); // For current Bot
  XmppService _xmppService = locator<XmppService>();
  TicketService _ticketService = locator<TicketService>();

  StreamSubscription<String> myTicketsEvents;

  String something = "";

  List<Ticket> _tickets = List<Ticket>();
  List<Ticket> get tickets => _tickets;
  List<Ticket> _filteredTicketList = [];
  List<Ticket> get filteredTicketList => _filteredTicketList;

  Future initMyTickets() async {
    setState(ViewState.Busy);
    String authKey = _authService.currentUserData.accessToken;
    String userName = _authService.currentUserData.username;
    String botId = _botService.defaultBot.userName;
    var tickets = await _api.getMyTickets(authKey, userName, botId);
    if (tickets != null) {
      _tickets = tickets;
      _filteredTicketList = _tickets;
    }
    myTicketsEvents =
        _xmppService.chatStreamController.stream.listen(_updateUI);
    setState(ViewState.Idle);
    ticketPolling();
  }

  _updateUI(String data) {
    setState(ViewState.Busy);
    MessageFormat incoming;
    if (data != "Stream Connected")
      try {
        incoming = MessageFormat.fromJson(jsonDecode(data));
        if (incoming.type == "support" && incoming.messageType == "BOT") {
          updateTickets();
        } else if (incoming.type == "sender") {
          _filteredTicketList
              .singleWhere((element) => element.ticketId == incoming.ticketId)
              .responded = false;
        }
      } catch (e) {
        // print(e);
      }
    setState(ViewState.Idle);
  }

  updateTickets() async {
    setState(ViewState.Busy);
    String authKey = _authService.currentUserData.accessToken;
    String userName = _authService.currentUserData.username;
    String botId = _botService.defaultBot.userName;
    var tickets = await _api.getMyTickets(authKey, userName, botId);
    if (tickets != null) {
      _tickets = tickets;
      _filteredTicketList = _tickets;
    }
    setState(ViewState.Idle);
  }

  ticketPolling() {
    String authKey = _authService.currentUserData.accessToken;
    String userName = _authService.currentUserData.username;
    String botId = _botService.defaultBot.userName;
    Timer.periodic(Duration(seconds: 20), (Timer t) async {
      var tickets = await _api.getMyTickets(authKey, userName, botId);
      if (tickets != null) {
        setState(ViewState.Busy);
        _tickets = tickets;
        _filteredTicketList = _tickets;
        setState(ViewState.Idle);
      }
    });
  }

  searchLogic(String keyword) {
    setState(ViewState.Searching);
    if (keyword == "") {
      _filteredTicketList = _tickets;
    } else {
      List<Ticket> tmpList = List<Ticket>();
      for (int i = 0; i < _tickets.length; i++) {
        if (_tickets[i]
            .contact
            .name
            .toLowerCase()
            .replaceAll(" ", "")
            .contains(keyword.toLowerCase().replaceAll(" ", ""))) {
          tmpList.add(_tickets[i]);
        }
      }

      _filteredTicketList = tmpList;
    }
    setState(ViewState.Idle);
  }

  void setTicketId(String ticketId) {
    _ticketService.setCurrentTicketId(ticketId);
  }
}
