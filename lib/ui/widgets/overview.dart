import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/viewmodels/overview_model.dart';
import 'package:support_agent/ui/shared/color.dart';
import 'package:support_agent/ui/views/base_view.dart';
import 'package:support_agent/ui/widgets/charts.dart';
import 'package:support_agent/ui/widgets/loading_content.dart';

class OverviewPage extends StatefulWidget {
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  @override
  Widget build(BuildContext context) {
    return BaseView<OverViewModel>(
        onModelReady: (model) async => await model.initOverview(),
        builder: (context, model, child) => SliverList(
              delegate: SliverChildListDelegate([
                model.state == ViewState.Busy
                    ? LoadingContent()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, bottom: 10),
                              child: Text(
                                "Today",
                                style: GoogleFonts.roboto(
                                    color: TextColorDark,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 24,
                                    letterSpacing: 0.9),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: _buildCards([
                                StatsCardItem(
                                  title: "Online Visitors",
                                  value: model.onlineUsers,
                                  description: "Users currently online",
                                ),
                                StatsCardItem(
                                    title: "Agent Availability",
                                    value: model.allAvailableAgents,
                                    description:
                                        "Availability status of currently logged in agents",
                                    extra: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.group,
                                          color: Success,
                                        ),
                                        Text(model.onlineAgents,
                                            style: GoogleFonts.roboto(
                                                color: Success)),
                                        SizedBox(width: 20),
                                        Icon(
                                          Icons.group,
                                          color: Danger,
                                        ),
                                        Text(model.busyAgents,
                                            style: GoogleFonts.roboto(
                                                color: Danger))
                                      ],
                                    )),
                                StatsCardItem(
                                  title: "Active Tickets",
                                  value: model.activeTickets,
                                  description: "Currently active tickets.",
                                ),
                              ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: _buildCards([
                                StatsCardItem(
                                    title: "Resolved Tickets",
                                    description: "Total Resolved Tickets Today",
                                    value: model.getResolvedTicketCount(),
                                    chart: model.state == ViewState.Busy || model.resolutionResponseChart.length == 0
                                        ? null
                                        : _buildChart(SimpleLineChart(
                                            model.resolutionResponseChart,
                                            animate: false,
                                          ))),
                                StatsCardItem(
                                    title: "Avg. Handling Time",
                                    description:
                                        "Today's Average Handling Time",
                                    value:
                                        "",
                                        // "${model.getAvgHandlingTime() ?? '0'} min",
                                    chart: model.state == ViewState.Busy || model.resolutionResponseChart.length == 0
                                        ? null
                                        : _buildChart(SimpleLineChart(
                                            model.avgHandlingTimeChart,
                                            animate: false,
                                          ))),
                                StatsCardItem(
                                    title: "First Response Time",
                                    description: "Today's First Response Time",
                                    value:  "", //"${model.getFirstResponseAvg()} Sec",
                                    chart: model.state == ViewState.Busy || model.resolutionResponseChart.length == 0
                                        ? null
                                        : _buildChart(SimpleLineChart(
                                            model.firstResponseTimeChart,
                                            animate: false,
                                          )))
                              ], hasCard: true),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.only(
                            //       left: 20, bottom: 10, top: 10),
                            //   child: Text(
                            //     "Last seven days",
                            //     style: GoogleFonts.roboto(
                            //         color: TextColorDark,
                            //         fontWeight: FontWeight.w500,
                            //         fontSize: 24,
                            //         letterSpacing: 0.9),
                            //   ),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            //   child: _buildChart(),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(vertical: 10),
                            //   child: _buildCards(itemsLastSevenDays),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.only(
                            //       left: 20, bottom: 10, top: 10),
                            //   child: Text(
                            //     "This month",
                            //     style: GoogleFonts.roboto(
                            //         color: TextColorDark,
                            //         fontWeight: FontWeight.w500,
                            //         fontSize: 24,
                            //         letterSpacing: 0.9),
                            //   ),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(vertical: 10),
                            //   child: _buildCards(itemsThisMonth),
                            // ),
                            SizedBox(height: 20),
                          ]),
              ]),
            ));
  }

  //Custom Functions
  Widget _buildCards(List<StatsCardItem> items, {bool hasCard}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.8;

    return SizedBox(
      height: (hasCard != null && hasCard) ? 280 : 180, // card height
      child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
                indent: 8,
              ),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (_, i) {
            Widget item = _buildCardItem(items[i], i, cardWidth);
            if (i == 0) {
              return Padding(
                child: item,
                padding: EdgeInsets.only(left: 20),
              );
            } else if (i == items.length - 1) {
              return Padding(
                child: item,
                padding: EdgeInsets.symmetric(horizontal: 20),
              );
            }

            return item;
          }),
    );
  }

  Widget _buildCardItem(
      StatsCardItem itemDetails, int itemIndex, double width) {
    return Container(
      width: width,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                  leading: Text(itemDetails.title,
                      style:
                          GoogleFonts.roboto(fontSize: 18, color: AccentBlue))),
              ListTile(
                leading: Text(
                  itemDetails.value,
                  style: GoogleFonts.roboto(fontSize: 32, color: TextColorDark),
                ),
                title:
                    itemDetails.extra != null ? itemDetails.extra : Container(),
              ),
              itemDetails.chart != null
                  ? itemDetails.chart
                  : SizedBox(height: 20),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Text(itemDetails.description,
                      style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: TextColorLight,
                          fontStyle: FontStyle.italic))),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildCardItem(dynamic itemDetails, int itemIndex, double width) {
  //   return Container(
  //     width: width,
  //     child: Card(
  //       elevation: 1,
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             ListTile(
  //                 leading: Text("Card ${itemIndex + 1}",
  //                     style:
  //                         GoogleFonts.roboto(fontSize: 18, color: AccentBlue))),
  //             ListTile(
  //               leading: Text(
  //                 itemDetails,
  //                 style: GoogleFonts.roboto(fontSize: 32, color: TextColorDark),
  //               ),
  //               title: Row(
  //                 children: <Widget>[
  //                   Icon(
  //                     Icons.group,
  //                     color: Success,
  //                   ),
  //                   Text(" 0 in queue",
  //                       style: GoogleFonts.roboto(color: Success))
  //                 ],
  //               ),
  //             ),
  //             SizedBox(height: 20),
  //             Align(
  //                 alignment: Alignment.bottomRight,
  //                 child: Text("Some description about Card ${itemIndex + 1}",
  //                     style: GoogleFonts.roboto(
  //                         fontSize: 12,
  //                         color: TextColorLight,
  //                         fontStyle: FontStyle.italic))),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildChart(SimpleLineChart chart) {
    try {
      return Container(
          width: MediaQuery.of(context).size.width - 40,
          height: 120,
          padding: const EdgeInsets.all(20),
          child: chart);
    } catch (e) {
      // print(e);
    }
  }
}

class StatsCardItem {
  String title, value, iconText, description;
  Widget extra;
  Widget chart;

  StatsCardItem(
      {this.title, this.value, this.extra, this.description, this.chart});
}
