import 'package:flutter/material.dart';
import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/tickets.dart';
import 'package:support_agent/core/viewmodels/transfer_ticket_model.dart';
import 'package:support_agent/ui/views/base_view.dart';
import 'package:support_agent/ui/widgets/agentList.dart';
import 'package:support_agent/ui/widgets/groupList.dart';
import 'package:support_agent/ui/widgets/loading_content.dart';
import 'package:support_agent/ui/widgets/no_data.dart';

class TransferTicket extends StatelessWidget {
  final Ticket ticket;
  TransferTicket({this.ticket});
  @override
  Widget build(BuildContext context) {
    return BaseView<TransferTicketModel>(
        onModelReady: (model) async => await model.initAgents(),
        builder: (context, model, child) => DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: Text("Transfer Ticket"),
                  bottom: TabBar(
                    tabs: [
                      Tab(text: "Agents"),
                      Tab(text: "Groups"),
                    ],
                  ),
                ),
                body: model.state == ViewState.Busy
                    ? LoadingContent()
                    : model.getAllAgents.agentItems.length == 0
                        ? NoData()
                        : TabBarView(
                          children :<Widget>[
                              AgentList(model.getAllAgents.agentItems,
                              ticketId: ticket.ticketId),
                              GroupList(model.getGroups.data,
                              ticketId: ticket.ticketId),
                              
                          ]
                        ),
              ),
            ));
  }
}
