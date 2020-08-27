import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/chat_args.dart';
import 'package:support_agent/core/viewmodels/archives_model.dart';
import 'package:support_agent/ui/shared/color.dart';
import 'package:support_agent/ui/views/base_view.dart';
import 'package:support_agent/ui/widgets/loading_content.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'no_data.dart';

class ArchivePage extends StatefulWidget {
  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  @override
  Widget build(BuildContext context) {
    return BaseView<ArchiveModel>(
        onModelReady: (model) async => await model.initArchive(),
        builder: (context, model, child) => SliverList(
                delegate: SliverChildListDelegate([
              model.state == ViewState.Busy || model.oldTickets.length == 0
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: getSearchBar(model),
                    ),
                    //Filter Button
              // model.state == ViewState.Busy || model.oldTickets.length == 0
              //     ? Container()
              //     : Padding(
              //         padding: const EdgeInsets.only(right: 20),
              //         child: Align(
              //           alignment: Alignment.centerRight,
              //           child: Container(
              //             width: 115,
              //             child: OutlineButton(
              //               onPressed: () {},
              //               child: Row(
              //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                 children: <Widget>[
              //                   Text("Filter",
              //                       style: GoogleFonts.roboto(
              //                           fontSize: 12, color: AccentBlue)),
              //                   Icon(
              //                     Icons.keyboard_arrow_down,
              //                     color: AccentBlue,
              //                   )
              //                 ],
              //               ),
              //               borderSide: BorderSide(color: AccentBlue),
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(5),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
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

  //Custom Functions
  Widget getSearchBar(ArchiveModel model) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.black38.withAlpha(10),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
                decoration: InputDecoration(
                  hintText: "Search with ticket No., email, phone, description",
                  hintStyle: GoogleFonts.roboto(
                      color: Colors.black.withAlpha(120), fontSize: 14),
                  border: InputBorder.none,
                ),
                onChanged: (String keyword) {
                  model.searchLogic(keyword);
                }),
          ),
          Icon(
            Icons.search,
            color: Colors.black.withAlpha(120),
          )
        ],
      ),
    );
  }
}
