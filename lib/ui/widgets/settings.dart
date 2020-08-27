import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:launch_review/launch_review.dart';
import 'package:support_agent/core/models/userdata.dart';
import 'package:support_agent/core/viewmodels/settings_model.dart';
import 'package:support_agent/ui/shared/color.dart';
import 'package:support_agent/ui/views/base_view.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<SettingsModel>(
      onModelReady: (model) async => await model.initSettings(),
      builder: (context, model, child) => SliverList(
          delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: _buildProfileSection(user: model.currentUser),
        ),
        buildSettingOptionsWithSubtitle(
            icon: Icons.face,
            title: "Change default bot",
            subtitle: "[Working with: ${model.defaultBot}]",
            onPressed: () => model.changeDefaultBot(context)),
        // buildSettingOptions(
        //     icon: Icons.settings_applications,
        //     title: "Support settings",
        //     onPressed: null),
        buildSettingOptions(
            icon: Icons.supervised_user_circle,
            title: "Agents",
            onPressed: () => Navigator.pushNamed(context, 'agents')),
        buildSettingOptionsWithSubtitle(
            icon: Icons.notifications_active,
            title:
                "Push Notifications [${model.pushNotification != null ? model.pushNotification ? 'On' : 'Off' : 'Off'}]",
            subtitle: "Allow ticket creation when not using app.",
            onPressed: () => model.showAlertDialog(context)),
        Divider(),
        buildSettingOptions(
            icon: Icons.feedback,
            title: "Leave a feedback",
            onPressed: () => LaunchReview.launch(
                androidAppId: "com.yellowmessenger.supportagent")),
        buildSettingOptions(
            icon: Icons.bug_report,
            title: "Report a bug",
            // onPressed: null,
            onPressed: () {
              Crashlytics.instance.crash();
            },
            color: Danger),

        Divider(),
        buildSettingOptions(
            icon: Icons.exit_to_app,
            title: "Logout",
            onPressed: () => model.logout(context),
            color: Danger),
        Divider(),
      ])),
    );
  }

  Container _buildProfileSection({@required User user}) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      height: 100,
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              leading: ClipOval(
                  child:
                      // user.proPic != null && user.proPic != ""
                      // ? Image.network(
                      //     user.proPic,
                      //     width: 60,
                      //     height: 60,
                      //     fit: BoxFit.cover,
                      //   )
                      // :
                      Image.asset(
                "images/avatar.png",
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      child: Text(
                    user.name,
                    style: GoogleFonts.roboto(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  )),

                  // User's status
                  // Padding(
                  //   padding: const EdgeInsets.only(right: 8.0),
                  //   child: Container(
                  //     height: 10,
                  //     width: 10,
                  //     decoration:
                  //         BoxDecoration(color: Success, shape: BoxShape.circle),
                  //   ),
                  // ),
                  // Text("Online")
                ],
              ),
              subtitle: Text(user.email),
            ),
          ],
        ),
      ),
    );
  }

  ListTile buildSettingOptionsWithSubtitle(
      {@required IconData icon,
      @required String title,
      @required Function onPressed,
      Color color,
      String subtitle}) {
    return ListTile(
      leading: Container(
        width: 40.0,
        height: 40.0,
        decoration: new BoxDecoration(
          color: color != null
              ? color.withOpacity(0.3)
              : AccentBlue.withOpacity(0.3), // border color
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color ?? AccentBlue,
        ),
      ),
      title: Text(title,
          style: GoogleFonts.roboto(
              fontSize: 16,
              color: TextColorMedium,
              fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right),
      onTap: onPressed,
    );
  }

  ListTile buildSettingOptions(
      {@required IconData icon,
      @required String title,
      @required Function onPressed,
      Color color}) {
    return ListTile(
      leading: Container(
        width: 40.0,
        height: 40.0,
        decoration: new BoxDecoration(
          color: color != null
              ? color.withOpacity(0.3)
              : AccentBlue.withOpacity(0.3), // border color
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color ?? AccentBlue,
        ),
      ),
      title: Text(title,
          style: GoogleFonts.roboto(
              fontSize: 16,
              color: TextColorMedium,
              fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.chevron_right),
      onTap: onPressed,
    );
  }
}
