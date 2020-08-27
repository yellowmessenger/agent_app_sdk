import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/agents.dart';
import 'package:support_agent/core/models/group.dart';
import 'package:support_agent/core/services/api.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/services/bot_service.dart';
import '../../locator.dart';
import 'base_model.dart';

class TransferTicketModel extends BaseModel {
  Api _api = locator<Api>();

  AuthenticationService _authService =
      locator<AuthenticationService>(); //For Auth Key
  BotService _botService = locator<BotService>(); // For current Bot
  String authKey = "";
  String botId = "";

  Agents _agents = Agents();
  Agents get getAllAgents => _agents;

  Group _groups = Group();
  Group get getGroups => _groups;

  // List<Ticket> get oldTickets => _oldTickets;
  // List<Ticket> _filteredTicketList = [];
  // List<Ticket> get filteredTicketList => _filteredTicketList;

  Future initAgents() async {
    setState(ViewState.Busy);
    authKey = _authService.currentUserData.accessToken;
    botId = _botService.defaultBot.userName;
    var availableAgents = await _api.getAgents(authKey, botId);
    var availableGroups = await _api.getGroups(authKey, botId);
    if (availableGroups != null) {
      _groups = availableGroups;
      for (var item in _groups.data) {
        print(item.name);
      }
    }
    if (availableAgents != null) {
      _agents = availableAgents;
    }
    setState(ViewState.Idle);
    return true;
  }

  searchLogic(String keyword) {
    setState(ViewState.Searching);
    setState(ViewState.Idle);
  }
}
