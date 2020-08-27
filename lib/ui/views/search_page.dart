import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/chat_args.dart';
import 'package:support_agent/core/viewmodels/search_model.dart';
import 'package:support_agent/ui/shared/color.dart';
import 'package:support_agent/ui/views/base_view.dart';
import 'package:support_agent/ui/widgets/loading_content.dart';
import 'package:support_agent/ui/widgets/no_data.dart';
import 'package:timeago/timeago.dart' as timeago;


class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return BaseView<SearchModel>(
        onModelReady: (model) async => await model.initSearch(),
        builder: (context, model, child) => SliverList(
                delegate: SliverChildListDelegate([
              model.state == ViewState.Busy || model.oldTickets.length == 0
                  ? Container()
                  :                     
              model.state == ViewState.Busy
                  ? LoadingContent()
                  : model.oldTickets.length == 0
                      ? NoData()
                      : MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView.separated(
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (_, i) {
                                return ListTile(
                                  title: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 16),
                                    child: Text(
                                        model.filteredTicketList[i].contact
                                            .name,
                                        style: GoogleFonts.roboto(
                                            fontSize: 15,
                                            color: TextColorMedium,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                  subtitle: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 16),
                                    child: Text(
                                        model.filteredTicketList[i].issue ?? "",
                                        style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            color: TextColorLight)),
                                  ),
                                  trailing: Text(
                                      timeago.format(DateTime.parse(model
                                          .filteredTicketList[i]
                                          .timestamp)),
                                      style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          color: TextColorLight)),
                                  onTap: () => Navigator.pushNamed(
                                    context, 'chat_page',
                                    arguments: ChatScreenArguments(model.filteredTicketList[i], true))
                                );
                              },
                              separatorBuilder: (context, index) => Divider(
                                    indent: 0,
                                  ),
                              itemCount: model.filteredTicketList.length),
                        ),
            ])));
  }

}
