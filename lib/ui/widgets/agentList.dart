import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support_agent/core/models/agents.dart';
import 'package:support_agent/core/models/group.dart';
import 'package:support_agent/core/services/api.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/services/bot_service.dart';
import 'package:support_agent/core/services/common.dart';
import 'package:support_agent/locator.dart';
import 'package:support_agent/ui/shared/color.dart';

class AgentList extends StatelessWidget {
  final List<AgentItem> agentItems;
  final List<GroupData> groupItems;
  final String ticketId;

  const AgentList(this.agentItems, {this.groupItems, this.ticketId});

  @override
  Widget build(BuildContext context) {
    AuthenticationService _authService =
        locator<AuthenticationService>(); //For Auth Key
    BotService _botService = locator<BotService>(); // For current Bot
    String authKey = _authService.currentUserData.accessToken;
    String botId = _botService.defaultBot.userName;

    return ListView.separated(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        separatorBuilder: (context, index) {
          if (ticketId != null &&
              agentItems[index].agentProfile.userId !=
                  _authService.currentUserData.user.id)
            return Divider(
              indent: 0,
            );
          else
            return Container();
        },
        itemCount: agentItems.length,
        itemBuilder: (_, i) {
          if (ticketId != null &&
              agentItems[i].agentProfile.userId !=
                  _authService.currentUserData.user.id)
            return ListTile(
                leading: CircleAvatar(
                    child: Image.network(
                        agentItems[i].agentProfile.profilePicture)),
                title: Row(
                  children: <Widget>[
                    Text(agentItems[i].agentProfile.name,
                        style: GoogleFonts.roboto(
                            fontSize: 15,
                            color: TextColorMedium,
                            fontWeight: FontWeight.w500)),
                    Spacer(),
                  ],
                ),
                subtitle: Text(agentItems[i].agentProfile.description,
                    style: GoogleFonts.roboto(
                        fontSize: 14, color: TextColorLight)),
                trailing: OutlineButton(
                  onPressed: ticketId != null &&
                          agentItems[i].status == "available"
                      ? () {
                          AlertDialog alert = AlertDialog(
                            title: Text("Do you want to reassign this ticket?"),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context, 1);

                                    reassignTicket(
                                            ticketId,
                                            agentItems[i].agentProfile.username,
                                            authKey,
                                            botId)
                                        .then((value) {
                                      Navigator.pop(context, 1);
                                      Navigator.pop(context, 1);
                                    });
                                  },
                                  child: Text("Yes"))
                            ],
                            content: Text(
                              "This ticket will be transferred to ${agentItems[i].agentProfile.name}.",
                            ),
                          );
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            },
                          );
                        }
                      : null,
                  textColor: agentItems[i].status == "available"
                      ? ticketId != null ? AccentBlue : Success
                      : TextColorMedium,
                  child: Text(capitalize(
                      ticketId != null ? "Transfer" : agentItems[i].status)),
                ));
          else
            return ListTile(
                leading: CircleAvatar(
                    child: Image.network(
                        agentItems[i].agentProfile.profilePicture)),
                title: Row(
                  children: <Widget>[
                    Text(agentItems[i].agentProfile.name,
                        style: GoogleFonts.roboto(
                            fontSize: 15,
                            color: TextColorMedium,
                            fontWeight: FontWeight.w500)),
                    Spacer(),
                  ],
                ),
                subtitle: Text(agentItems[i].agentProfile.description,
                    style: GoogleFonts.roboto(
                        fontSize: 14, color: TextColorLight)),
                trailing: OutlineButton(
                  onPressed: null,
                  textColor: agentItems[i].status == "available"
                      ? ticketId != null ? AccentBlue : Success
                      : TextColorMedium,
                  child: Text(capitalize(agentItems[i].status)),
                ));
        });
  }

  reassignTicket(
      String ticketId, String agentId, String authKey, String botId) async {
    Api _api = locator<Api>();
    // print("transferring");
    var reassignResponse =
        await _api.reassignTicket(authKey, botId, ticketId, agentId);
    // print("transferred");
  }
}
