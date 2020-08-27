import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support_agent/core/models/group.dart';
import 'package:support_agent/core/services/api.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/services/bot_service.dart';
import 'package:support_agent/core/services/common.dart';
import 'package:support_agent/locator.dart';
import 'package:support_agent/ui/shared/color.dart';

class GroupList extends StatelessWidget {
  final List<GroupData> groupItems;
  final String ticketId;

  const GroupList(this.groupItems, {this.ticketId});

  @override
  Widget build(BuildContext context) {
    AuthenticationService _authService =
        locator<AuthenticationService>(); //For Auth Key
    BotService _botService = locator<BotService>(); // For current Bot
    String authKey = _authService.currentUserData.accessToken;
    String botId = _botService.defaultBot.userName;

    return ListView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: groupItems.length,
        itemBuilder: (_, i) {
          return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade900,
                child: Text(getInitials(groupItems[i].name)),
              ),
              title: Row(
                children: <Widget>[
                  Text(groupItems[i].name,
                      style: GoogleFonts.roboto(
                          fontSize: 15,
                          color: TextColorMedium,
                          fontWeight: FontWeight.w500)),
                  Spacer(),
                ],
              ),
              subtitle: Text(
                  "${groupItems[i].onlineCount.toString()} users online",
                  style:
                      GoogleFonts.roboto(fontSize: 14, color: TextColorLight)),
              trailing: OutlineButton(
                onPressed: ticketId != null && groupItems[i].onlineCount > 0
                    ? () {

                      
                        AlertDialog alert = AlertDialog(
                          title: Text("Do you want to reassign this ticket?"),
                          actions: <Widget>[
                            FlatButton(
                                onPressed: () {
                                  Navigator.pop(context, 1);

                                  reassignTicket(ticketId, groupItems[i].code,
                                          authKey, botId)
                                      .then((value) {
                                    Navigator.pop(context, 1);
                                    Navigator.pop(context, 1);
                                  });
                                },
                                child: Text("Yes"))
                          ],
                          content: Text(
                            "This ticket will be transferred to ${groupItems[i].code}.",
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
                textColor: groupItems[i].code == "available"
                    ? ticketId != null ? AccentBlue : Success
                    : TextColorMedium,
                child: Text(capitalize(
                    ticketId != null ? "Transfer" : groupItems[i].code)),
              ));
        });
  }

  reassignTicket(
      String ticketId, String groupCode, String authKey, String botId) async {
    Api _api = locator<Api>();
    var reassignResponse =
        await _api.reassignTicketToGroup(authKey, botId, ticketId, groupCode);
    if (reassignResponse != null) {
      return true;
    } else
      return false;
  }
}
