import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:support_agent/core/models/actions.dart';
import 'package:support_agent/core/models/agents.dart';
import 'package:support_agent/core/models/all_bots.dart';
import 'package:support_agent/core/models/bot_status.dart';
import 'package:support_agent/core/models/bot_user_profile.dart';
import 'package:support_agent/core/models/collaborators.dart';
import 'package:support_agent/core/models/common.dart';
import 'package:support_agent/core/models/contact.dart';
import 'package:support_agent/core/models/group.dart';
import 'package:support_agent/core/models/messages.dart';
import 'package:support_agent/core/models/mimetypes.dart';
import 'package:support_agent/core/models/resolved_list.dart';
import 'package:support_agent/core/models/send_message.dart';
import 'package:support_agent/core/models/template.dart';
import 'package:support_agent/core/models/ticket_count.dart';
import 'package:support_agent/core/models/ticket_settings.dart';
import 'package:support_agent/core/models/tickets.dart';
import 'package:support_agent/core/models/xmpp_user.dart';
import 'package:http_parser/http_parser.dart';

/// The service responsible for networking requests
class Api {
  static const API_URL = 'https://app.yellowmessenger.com/api';

  var client = new http.Client();

  Future<Map<String, dynamic>> getUserProfile(
      String userName, String password) async {
    Map data = {
      'username': userName,
      'password': password,
      'type': "account",
      'referrer': "mobileApp"
    };
    String body = json.encode(data);

    var response = await client.post(
      '$API_URL/sso/v2login',
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    if (json.decode(response.body)["error"] == null) {
      return json.decode(response.body);
      // return UserData.fromJson(json.decode(response.body));
    } else {
      log(json.decode(response.body));
      return json.decode(response.body);
    }
  }

  Future<List<AllBots>> getAllBots(String authKey) async {
    List<AllBots> allBots = List<AllBots>();
    var responseSandbox = await client.get(
        '$API_URL/sso/bot?offset=0&botType=sandbox&subscriptionId=1',
        headers: {'x-auth-token': '$authKey'});
    if (responseSandbox.statusCode == 200) {
      allBots.add(AllBots.fromJson(json.decode(responseSandbox.body)));
    }
    var responseStaging = await client.get(
        '$API_URL/sso/bot?offset=0&botType=staging&subscriptionId=1',
        headers: {'x-auth-token': '$authKey'});
    if (responseStaging.statusCode == 200) {
      allBots.add(AllBots.fromJson(json.decode(responseStaging.body)));
    }
    var responseProduction = await client.get(
        '$API_URL/sso/bot?offset=0&botType=production&subscriptionId=1',
        headers: {'x-auth-token': '$authKey'});
    if (responseProduction.statusCode == 200) {
      allBots.add(AllBots.fromJson(json.decode(responseProduction.body)));
    }

    return allBots;
  }

  Future<Group> getGroups(String authKey, String botId) async {
    var response = await client.get('$API_URL/agents/tickets/groups?bot=$botId',
        headers: {'x-auth-token': '$authKey'});
    if (response.statusCode == 200) {
      print(response.body);
      return Group.fromJson(json.decode(response.body));
    }
  }

  Future<int> getOpenTicketCount(String authKey, String botId) async {
    int count = 0;
    var response = await client.get(
        '$API_URL/agents/tickets/get_queued_ticket_count?bot=$botId',
        headers: {'x-auth-token': '$authKey'});
    if (response.statusCode == 200) {
      count = TicketCount.fromJson(json.decode(response.body)).data.count;
    }
    return count;
  }

  Future<int> getAssignedTicketCount(
      String authKey, String botId, String userName) async {
    Map openedTicketsBody = {
      'filter': {
        'statuses': ["assigned", "open"],
        'agents': ["$userName"],
        'limit': 200,
        'offset': 0
      }
    };
    String body = json.encode(openedTicketsBody);

    var response = await client.post(
        '$API_URL/agents/tickets/filtered?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      return TicketList.fromJson(json.decode(response.body)).ticketList.length;
    } else
      return 0;
  }

  Future<List<Ticket>> getArchiveTickets(
      String authKey, String botId, int limit, int offset) async {
    Map data = {
      'filter': {
        'limit': limit,
        'offset': offset,
        'statuses': ["assigned", "resolved", "queued", "open"]
      }
    };
    String archiveBody = json.encode(data);

    var response = await client.post(
        '$API_URL/agents/tickets/filtered_search?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: archiveBody);

    if (response.statusCode == 200) {
      return TicketList.fromJson(json.decode(response.body)).ticketList;
    }
  }

  Future<List<Ticket>> searchTickets(
      String authKey, String botId, String searchText) async {
    Map data = {
      'filter': {"searchText": searchText}
    };
    String archiveBody = json.encode(data);

    var response = await client.post(
        '$API_URL/agents/tickets/filtered_search?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: archiveBody);

    if (response.statusCode == 200) {
      return TicketList.fromJson(json.decode(response.body)).ticketList;
    }
  }

  //
  Future<dynamic> updateTicketNote(
      String authKey, String botId, String ticketId, String note) async {
    Map customFieldsBody = {"ticketId": ticketId, "note": note};

    String body = json.encode(customFieldsBody);

    var response = await client.post(
        '$API_URL/agents/tickets/update_ticket_note?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
  }

  Future<dynamic> updateTicketTags(
      String authKey, String botId, String ticketId, List<String> tags) async {
    Map customFieldsBody = {"ticketId": ticketId, "tags": tags};

    String body = json.encode(customFieldsBody);

    var response = await client.post('$API_URL/agents/tickets/tag?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
  }

  Future<dynamic> updateContactDetails(String authKey, String botId,
      String ticketId, ContactDetails contactDetails) async {
    Map customFieldsBody = {
      "ticketId": ticketId,
      "contactDetails": {
        "name": contactDetails.name,
        "phone": contactDetails.phone,
        "email": contactDetails.email
      }
    };

    String body = json.encode(customFieldsBody);

    var response = await client.post(
        '$API_URL/agents/tickets/update_contact?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
  }

  Future<Template> getTemplate(String authKey, String botId) async {
    var response = await client.get('$API_URL/agents/data/templates?bot=$botId',
        headers: {'x-auth-token': '$authKey'});
    if (response.statusCode == 200) {
      return Template.fromJson(json.decode(response.body));
    }
  }

  Future<TicketSettings> getSettings(String authKey, String botId) async {
    var response = await client.get('$API_URL/agents/settings?bot=$botId',
        headers: {'x-auth-token': '$authKey'});
    if (response.statusCode == 200) {
      // print(response.body);
      return TicketSettings.fromJson(json.decode(response.body));
    }
  }

  Future<Ticket> getTicketInfo(
      String authKey, String ticketId, String botId) async {
    var response = await client.get(
        '$API_URL/agents/tickets/ticket/$ticketId?bot=$botId',
        headers: {'x-auth-token': '$authKey'});
    if (response.statusCode == 200) {
      var ticketData = SingleTicket.fromJson(json.decode(response.body));
      return ticketData.ticket;
    }
  }

  Future<dynamic> updateCustomFields(String authKey, String botId,
      String ticketId, Map<String, dynamic> customFields) async {
    Map customFieldsBody = {"ticketId": ticketId, "customFields": customFields};

    String body = json.encode(customFieldsBody);
    print(body);

    var response = await client.post(
        '$API_URL/agents/tickets/update_custom_fields?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      print("form update api" + response.body);
      return json.decode(response.body);
    }
  }

  Future<List<Ticket>> getMyTickets(
      String authKey, String userName, String botId) async {
    Map openedTicketsBody = {
      'filter': {
        'statuses': ["assigned", "open"],
        'agents': ["$userName"],
        'limit': 200,
        'offset': 0
      }
    };
    String body = json.encode(openedTicketsBody);

    var response = await client.post(
        '$API_URL/agents/tickets/filtered?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      return TicketList.fromJson(json.decode(response.body)).ticketList;
    }
  }

  Future closeTicket(String authKey, String botId, String ticketId) async {
    Map data = {
      'ticketId': ticketId,
      'comments': [],
      'customFields': {},
    };
    String body = json.encode(data);
    var response = await client.post(
      '$API_URL/agents/tickets/resolve?bot=$botId',
      headers: {"Content-Type": "application/json", 'x-auth-token': '$authKey'},
      body: body,
    );
    if (json.decode(response.body)["success"] != null &&
        json.decode(response.body)["success"])
      return json.decode(response.body);
    else
      return null;
  }

  Future reassignTicket(
      String authKey, String botId, String ticketId, String username,
      {bool addCollab = false}) async {
    Map data = {
      'ticketId': ticketId,
      'agentId': username,
      'customFields': {},
      "keepCollaborator": addCollab
    };
    String body = json.encode(data);
    print(body);
    var response = await client.post(
      '$API_URL/agents/tickets/reassign?bot=$botId',
      headers: {"Content-Type": "application/json", 'x-auth-token': '$authKey'},
      body: body,
    );
    if (json.decode(response.body)["success"] != null &&
        json.decode(response.body)["success"])
      return json.decode(response.body);
    else
      return null;
  }

  Future<Agents> getAgents(String authKey, String botId) async {
    var response = await client.get(
        '$API_URL/agents/reps/getAgentAvailabilities?bot=$botId&timezone=Asia/Calcutta',
        headers: {'x-auth-token': '$authKey'});
    if (response.statusCode == 200) {
      return Agents.fromJson(json.decode(response.body));
    }
  }

  Future reassignTicketToGroup(
      String authKey, String botId, String ticketId, String groupCode) async {
    Map data = {
      'ticketId': ticketId,
      'groupCode': groupCode,
    };
    String body = json.encode(data);
    var response = await client.post(
      '$API_URL/agents/tickets/reassign_to_group?bot=$botId',
      headers: {"Content-Type": "application/json", 'x-auth-token': '$authKey'},
      body: body,
    );
    if (json.decode(response.body)["success"] != null &&
        json.decode(response.body)["success"])
      return json.decode(response.body);
    else
      return null;
  }

  Future<CollaboratorModel> getCollaboratorsList(
      String authKey, String botId) async {
    var response = await client.get('$API_URL/sso/bot/agents?bot=$botId',
        headers: {'x-auth-token': '$authKey'});
    if (response.statusCode == 200) {
      return CollaboratorModel.fromJson(json.decode(response.body));
    }
  }

  Future updateCollaboratorsList(String authKey, String botId, String ticketId,
      List<String> collaborators) async {
    Map data = {
      'ticketId': ticketId,
      "collaborators": collaborators,
    };
    String body = json.encode(data);
    var response = await client.post(
      '$API_URL/agents/tickets/update_collaborators?bot=$botId',
      headers: {"Content-Type": "application/json", 'x-auth-token': '$authKey'},
      body: body,
    );
    if (json.decode(response.body)["success"] != null &&
        json.decode(response.body)["success"])
      return json.decode(response.body);
    else
      return null;
  }

  Future<dynamic> setNotificationPreference(
      String authKey, String botId, String presence) async {
    Map data = {"status": presence};
    String body = json.encode(data);
    // print('$API_URL/agents/reps/changeAgentAppAvailability?bot=$botId');
    var response = await client.post(
        '$API_URL/agents/reps/changeAgentAppAvailability?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // print(response.body);
    }
  }

  Future<String> uploadImage(
      String authKey, String botId, String filename) async {
    RegExp regExp = new RegExp(
      r"\.\w{3,4}($|\?)",
      caseSensitive: false,
      multiLine: false,
    );
    var contentType =
        mimeMap[regExp.stringMatch(filename).toString()].split("/");

    var request = http.MultipartRequest('POST',
        Uri.parse('$API_URL/chat/upload-file-secured?bot=$botId&json=true'));
    request.headers['x-auth-token'] = authKey;
    request.files.add(await http.MultipartFile.fromPath('file', filename,
        contentType: MediaType(contentType[0], contentType[1])));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) return json.decode(response.body)['url'];
  }

  Future<dynamic> changePresence(String authKey, String botId, String presence,
      String xmppUsername) async {
    Map data = {"xmppUsername": xmppUsername, "status": presence};
    String body = json.encode(data);
    // print('$API_URL/agents/reps/changePresenceStatus?bot=$botId');

    var response = await client.post(
        '$API_URL/agents/reps/changePresenceStatus?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      // print(response.body);
      return json.decode(response.body);
    }
  }

  Future<dynamic> sendFirebaseToken(
      String authKey, String botId, String token) async {
    Map data = {
      'token': token,
    };
    String body = json.encode(data);

    var response = await client.post(
        '$API_URL/agents/notification/register/agent?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
  }

  Future<Messages> getChatMessages(
      String authKey, String uid, String botId, String ticketId) async {
    var response = await client.get(
        '$API_URL/agents/data/messages?bot=$botId&uid=$uid&limit=100&ticketId=$ticketId',
        headers: {'x-auth-token': '$authKey'});
    print(response.body);
    if (response.statusCode == 200) {
      return Messages.fromJson(json.decode(response.body));
    }
  }

  Future<dynamic> getReplyMessage(
      String authKey, String botId, String messageId) async {
    String body = jsonEncode({"replyToId": messageId, "source": "whatsapp"});

    var response = await client.post(
        '$API_URL/agents/data/getReplyToMessage?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      print(response.body);
      return json.decode(response.body);
    }
  }

  Future<XmppUserModel> getCredentials(
      String authKey, String botId, int userRole) async {
    var response = await client.get(
        '$API_URL/sso/bot/get_credentials?bot_username=$botId&getAdminCreds=$userRole',
        headers: {'x-auth-token': '$authKey'});
    if (response.statusCode == 200) {
      // print(response.body);
      return XmppUserModel.fromJson(json.decode(response.body));
    }
  }

  Future<dynamic> sendMessage(
      String authKey, String botId, SendMessage msg) async {
    String body = jsonEncode(msg.toJson());
    print(body);

    var response = await client.post('$API_URL/agents/data/send?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
  }

  Future<BotStatus> getBotStatus(
      String authKey, String botId, String uId, String source) async {
    var response = await client.get(
        '$API_URL/agents/user/status?bot=$botId&uid=$uId&source=$source',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        });

    if (response.statusCode == 200) {
      return BotStatus.fromJson(json.decode(response.body));
    }
  }

  Future<BotUser> getTicketUserProfile(
      String authKey, String botId, String uId, String source) async {
    var response = await client.get(
        '$API_URL/agents/user/profile?bot=$botId&uid=$uId&source=$source',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        });

    if (response.statusCode == 200) {
      return BotUser.fromJson(json.decode(response.body));
    }
  }

  Future<List<String>> getTags(String authKey, String botId) async {
    var response = await client.get('$API_URL/agents/settings/tags?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        });

    if (response.statusCode == 200) {
      return json.decode(response.body)["data"].cast<String>();
    }
  }

  Future<CommonApiModel> getCurrentUsersStats(
      String authKey, String botId) async {
    var response = await client.get(
        '$API_URL/agents/user/get_connected_user_count?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        });

    if (response.statusCode == 200) {
      return CommonApiModel.fromJson(json.decode(response.body));
    }
  }

  Future<CommonApiModel> getActiveTicketStats(
      String authKey, String botId) async {
    var response = await client.get(
        '$API_URL/agents/tickets/get_open_ticket_count?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        });

    if (response.statusCode == 200) {
      return CommonApiModel.fromJson(json.decode(response.body));
    }
  }

  Future<CommonApiModel> getAgentAvailabilityStats(
      String authKey, String botId) async {
    var response = await client.get(
        '$API_URL/agents/reps/getAgentAvailabilities?bot=$botId&timezone=Asia/Calcutta',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        });

    if (response.statusCode == 200) {
      return CommonApiModel.fromJson(json.decode(response.body));
    }
  }

  //Get Summary
  Future<HourlyStatsResponse> getSummary(
      String authKey, String botId, Map<String, dynamic> filters) async {
    String body = jsonEncode(filters);

    var response = await client.post(
        '$API_URL/agents/ticketAnalytics/get_summary?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      return HourlyStatsResponse.fromJson(json.decode(response.body));
    }
  }

  Future<AgentActions> getActions(String authKey, String botId) async {
    var response = await client.get(
        '$API_URL/agents/actions/agentActions?bot=$botId',
        headers: {'x-auth-token': '$authKey'});
    if (response.statusCode == 200) {
      return AgentActions.fromJson(json.decode(response.body));
    }
  }

  Future<dynamic> sendActions(String authKey, String botId, Map action) async {
    String body = jsonEncode(action);

    var response = await client.post(
        '$API_URL/agents/actions/runAgentActions?bot=$botId',
        headers: {
          'x-auth-token': '$authKey',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
  }
}
