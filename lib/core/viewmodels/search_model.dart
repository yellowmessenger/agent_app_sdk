import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/tickets.dart';
import 'package:support_agent/core/services/api.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/services/bot_service.dart';
import '../../locator.dart';
import 'base_model.dart';

class SearchModel extends BaseModel {
  Api _api = locator<Api>();

  AuthenticationService _authService =
      locator<AuthenticationService>(); //For Auth Key
  BotService _botService = locator<BotService>(); // For current Bot

  List<Ticket> _oldTickets = List<Ticket>();
  List<Ticket> get oldTickets => _oldTickets;
  List<Ticket> _filteredTicketList = [];
  List<Ticket> get filteredTicketList => _filteredTicketList;

  Future initSearch() async{
    setState(ViewState.Busy);
    // String authKey = _authService.currentUserData.accessToken;
    // String botId = _botService.defaultBot.userName;
    // setState(ViewState.Busy);
    // var archiveTickets = await _api.getArchiveTickets(authKey,botId);
    // if (archiveTickets != null) {
    //   _oldTickets = archiveTickets;
    // _filteredTicketList = _oldTickets;
    // }
    setState(ViewState.Idle);
    return true;
  }

  searchLogic(String keyword) {
    setState(ViewState.Searching);
    if (keyword == "") {
      _filteredTicketList = _oldTickets;
    } else {
      List<Ticket> tmpList = List<Ticket>();
      for (int i = 0; i < _oldTickets.length; i++) {
        if (_oldTickets[i]
            .contact
            .name
            .toLowerCase()
            .replaceAll(" ", "")
            .contains(keyword.toLowerCase().replaceAll(" ", ""))) {
          tmpList.add(_oldTickets[i]);
        }
      }

      _filteredTicketList = tmpList;
    }
    setState(ViewState.Idle);
  }
}
