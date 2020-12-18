import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support_agent/core/enums/agentpresense.dart';
import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/viewmodels/home_model.dart';

import 'package:support_agent/ui/shared/color.dart';
import 'package:support_agent/ui/widgets/loading_content.dart';

import 'base_view.dart';

class HomePage extends StatelessWidget {
  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeModel>(
      onModelDispose: (model) => model.dispose(),
      onModelReady: (model) async => await model.initHome(context),
      builder: (context, model, child) => Scaffold(
          backgroundColor: Colors.white,
          body: model.state == ViewState.Busy
              ? LoadingContent()
              : Stack(children: [
                  CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        pinned: true,
                        floating: false,
                        expandedHeight: 80,
                        flexibleSpace: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                width: 250,
                                child: FlexibleSpaceBar(
                                  title: Text(
                                    model.navigationItems[model.currentIndex]
                                        .title,
                                    style: GoogleFonts.roboto(
                                        color: TextColorLight,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 25,
                                        letterSpacing: 0.9),
                                  ),
                                  centerTitle: false,
                                  titlePadding: const EdgeInsets.only(left: 0),
                                ),
                              ),
                              Spacer(),
                              model.navigationItems[model.currentIndex].title !=
                                      "Settings"
                                  ? model.xmppReady
                                      ? Stack(children: <Widget>[
                                          InkWell(
                                              child: Container(
                                                  width: 50.0,
                                                  height: 50.0, // border width
                                                  decoration: new BoxDecoration(
                                                      // color: TextColorLight, // border color
                                                      shape: BoxShape.circle,
                                                      color:
                                                          Colors.transparent),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    backgroundImage:
                                                        Image.asset(
                                                      "images/avatar.png",
                                                      width: 60,
                                                      height: 60,
                                                      fit: BoxFit.cover,
                                                    ).image,
                                                  )),
                                              onTap: () =>
                                                  containerForSheet<String>(
                                                    context: context,
                                                    child: CupertinoActionSheet(
                                                      title: Text("Set Status"),
                                                      actions: <Widget>[
                                                        CupertinoActionSheetAction(
                                                          isDefaultAction: model
                                                                  .agentPresence ==
                                                              AgentPresenceState
                                                                  .Available,
                                                          onPressed: () {
                                                            model.goOnline();
                                                            model.changePresence(
                                                                "available");
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Row(
                                                            children: <Widget>[
                                                              Container(
                                                                height: 10,
                                                                width: 10,
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            20),
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        Success,
                                                                    shape: BoxShape
                                                                        .circle),
                                                              ),
                                                              Text("Available"),
                                                            ],
                                                          ),
                                                        ),
                                                        CupertinoActionSheetAction(
                                                          isDefaultAction: model
                                                                  .agentPresence ==
                                                              AgentPresenceState
                                                                  .Busy,
                                                          onPressed: () {
                                                            model.goOnline();
                                                            model
                                                                .changePresence(
                                                                    "dnd");
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Row(
                                                            children: <Widget>[
                                                              Container(
                                                                height: 10,
                                                                width: 10,
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            20),
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        Danger,
                                                                    shape: BoxShape
                                                                        .circle),
                                                              ),
                                                              Text("Busy"),
                                                            ],
                                                          ),
                                                        ),
                                                        CupertinoActionSheetAction(
                                                          onPressed: () {
                                                            // model.changePresence(
                                                            //     "offline");
                                                            model.goOffline();
                                                            model
                                                                .pushNotificationStatus(
                                                                    "OFFLINE");
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Row(
                                                            children: <Widget>[
                                                              Container(
                                                                height: 10,
                                                                width: 10,
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            20),
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        TextColorMedium,
                                                                    shape: BoxShape
                                                                        .circle),
                                                              ),
                                                              Text("Sign Off"),
                                                            ],
                                                          ),
                                                        ),
                                                        CupertinoActionSheetAction(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            model
                                                                .showAlertDialog(
                                                                    context);
                                                          },
                                                          child: Row(
                                                            children: <Widget>[
                                                              Container(
                                                                height: 10,
                                                                width: 10,
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            20),
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        TextColorMedium,
                                                                    shape: BoxShape
                                                                        .circle),
                                                              ),
                                                              Text(
                                                                  "App Availability: ${model.offlineTicketAllowed != null ? model.offlineTicketAllowed ? 'On' : 'Off' : 'Off'}"),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                      cancelButton:
                                                          CupertinoActionSheetAction(
                                                        child: const Text(
                                                            'Cancel'),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          Navigator.pop(context,
                                                              'Cancel');
                                                        },
                                                      ),
                                                    ),
                                                  )),
                                          Positioned(
                                            right: 0,
                                            child: Container(
                                              height: 10,
                                              width: 10,
                                              decoration: BoxDecoration(
                                                  color: model.agentPresence ==
                                                          AgentPresenceState
                                                              .Offline
                                                      ? TextColorMedium
                                                      : model.agentPresence ==
                                                              AgentPresenceState
                                                                  .Available
                                                          ? Success
                                                          : Danger,
                                                  shape: BoxShape.circle),
                                            ),
                                          ),
                                        ])
                                      : InkWell(
                                          onTap: () => model.retryConnection(),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                  width: 50.0,
                                                  height: 50.0, // border width
                                                  decoration: new BoxDecoration(
                                                      // color: TextColorLight, // border color
                                                      shape: BoxShape.circle,
                                                      color:
                                                          Colors.transparent),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    backgroundImage:
                                                        Image.asset(
                                                      "images/no-connection.png",
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    ).image,
                                                  )),
                                            ],
                                          ),
                                        )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        sliver:
                            model.navigationItems[model.currentIndex].navPage,
                      ),
                    ],
                  ),
                  Positioned(
                    top: 30,
                    left: 20,
                    child: Container(
                      child: Text("YM Partner SDK v1.0.4",
                          style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: TextColorLight,
                              fontStyle: FontStyle.italic)),
                    ),
                  ),
                ])
          // bottomNavigationBar: BottomNavigationBar(
          //     unselectedItemColor: TextColorLight,
          //     selectedItemColor: AccentBlue,
          //     onTap: model.onTabTapped,
          //     currentIndex: model.currentIndex,
          //     items: _getBottomNavigationItems(model, context)),
          ),
    );
  }

  List<BottomNavigationBarItem> _getBottomNavigationItems(
      HomeModel model, BuildContext context) {
    List<BottomNavigationBarItem> navOptions = [];
    for (var navItem in model.navigationItems) {
      navOptions.add(
        BottomNavigationBarItem(
          icon: Stack(
            children: <Widget>[
              Icon(
                navItem.icon,
                size: 32,
              ),
              Positioned(
                right: navItem.notifications == 0 ? 50 : 0,
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Danger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      navItem.notifications == 0
                          ? ""
                          : "${navItem.notifications}",
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            ],
          ),
          title: Text(
            navItem.title,
            style: GoogleFonts.roboto(
                fontSize: 15, letterSpacing: 0.45, fontWeight: FontWeight.w400),
          ),
        ),
      );
    }
    return navOptions;
  }
}
