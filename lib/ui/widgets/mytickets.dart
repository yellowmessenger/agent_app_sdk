import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/chat_args.dart';
import 'package:support_agent/core/models/tickets.dart';
import 'package:support_agent/core/viewmodels/my_tickets_model.dart';
import 'package:support_agent/ui/shared/color.dart';
import 'package:support_agent/ui/views/base_view.dart';
import 'package:support_agent/ui/widgets/loading_content.dart';
import 'package:support_agent/ui/widgets/no_data.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyTicketsPage extends StatefulWidget {
  @override
  _MyTicketsPageState createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  _navigateAndDisplaySelection(
      BuildContext context, Ticket ticket, MyTicketsModel model) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.pushNamed(context, 'chat_page',
        arguments: ChatScreenArguments(ticket, false));
    await model.initMyTickets();
    model.setTicketId("");
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<MyTicketsModel>(
        onModelReady: (model) async => await model.initMyTickets(),
        builder: (context, model, child) => SliverList(
            delegate: model.state == ViewState.Busy
                ? SliverChildListDelegate([LoadingContent()])
                : model.tickets.length == 0
                    ? SliverChildListDelegate([NoData()])
                    : SliverChildBuilderDelegate(
                        (BuildContext context, int itemIndex) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                title: !model.tickets[itemIndex].responded
                                    ? Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: Row(
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                height: 10,
                                                width: 10,
                                                decoration: BoxDecoration(
                                                    color: AccentBlue,
                                                    shape: BoxShape.circle),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8),
                                              child: Text(
                                                  model.tickets[itemIndex]
                                                          .contact.name ??
                                                      "",
                                                  style: GoogleFonts.roboto(
                                                      fontSize: 15,
                                                      color: AccentBlue,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            )
                                          ],
                                        ),
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16),
                                        child: Text(
                                            model.tickets[itemIndex].contact
                                                .name,
                                            style: GoogleFonts.roboto(
                                                fontSize: 15,
                                                color: TextColorMedium,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                subtitle: Padding(
                                  padding: !model.tickets[itemIndex].responded
                                      ? const EdgeInsets.only(left: 18)
                                      : const EdgeInsets.only(left: 16),
                                  child: Text(
                                      model.tickets[itemIndex].issue ?? "",
                                      style: GoogleFonts.roboto(
                                          fontSize: 14, color: TextColorLight)),
                                ),
                                trailing: Text(
                                    timeago.format(DateTime.parse(
                                            model.tickets[itemIndex].updated ??
                                                model.tickets[itemIndex]
                                                    .timestamp)) ??
                                        "",
                                    style: GoogleFonts.roboto(
                                        fontSize: 12,
                                        color:
                                            !model.tickets[itemIndex].responded
                                                ? AccentBlue
                                                : TextColorLight)),
                                onTap: () {
                                  model.setTicketId(
                                      model.tickets[itemIndex].ticketId);
                                  _navigateAndDisplaySelection(
                                      context, model.tickets[itemIndex], model);
                                },
                              ),
                              Divider()
                            ],
                          );
                        },
                        semanticIndexCallback: (Widget widget, int localIndex) {
                          if (localIndex.isEven) {
                            return localIndex ~/ 2;
                          }
                          return null;
                        },
                        childCount: model.tickets.length,
                        addSemanticIndexes: true,
                      )));
  }
}
