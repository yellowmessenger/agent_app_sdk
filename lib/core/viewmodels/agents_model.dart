import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/agents.dart';
import 'package:support_agent/core/services/api.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/services/bot_service.dart';
import '../../locator.dart';
import 'base_model.dart';

class AgentsModel extends BaseModel {
  Api _api = locator<Api>();

  AuthenticationService _authService =
      locator<AuthenticationService>(); //For Auth Key
  BotService _botService = locator<BotService>(); // For current Bot

  Agents _agents = Agents();
  Agents get getAllAgents => _agents;
  // List<Ticket> get oldTickets => _oldTickets;
  // List<Ticket> _filteredTicketList = [];
  // List<Ticket> get filteredTicketList => _filteredTicketList;

  Future initAgents() async{
    setState(ViewState.Busy);
    String authKey = _authService.currentUserData.accessToken;
    String botId = _botService.defaultBot.userName;
    var availableAgents = await _api.getAgents(authKey, botId);
    if(availableAgents != null){
      _agents = availableAgents;
    }
    for (var item in _agents.agentItems) {
      // print(item.agentId);
    }
    setState(ViewState.Idle);
    return true;
  }

  searchLogic(String keyword) {
    setState(ViewState.Searching);
    setState(ViewState.Idle);
  }
}
