import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart' hide Router;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:support_agent/core/models/userdata.dart';
import 'package:support_agent/core/services/notification_service.dart';
import 'package:support_agent/ui/router.dart';
import 'package:support_agent/ui/shared/color.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/models/appstate.dart';
import 'core/services/authentication_service.dart';
import 'locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Crashlytics.instance.enableInDevMode = true;

  bool optIn = true;
  if (optIn) {
    FlutterError.onError = Crashlytics.instance.recordFlutterError;
    // if (kReleaseMode) exit(1);
    runZoned(() {
      setupLocator();
      runApp(MyApp());
    }, onError: Crashlytics.instance.recordError);
  } else {
    runZoned(() {
      setupLocator();
      runApp(MyApp());
    });
  }
  ;
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

NotificationAppLaunchDetails notificationAppLaunchDetails;

setupNotifications() async {
  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  final initializationSettingsAndroid = AndroidInitializationSettings(
      'notification_icon'); //@mipmap/launcher_icon app_icon.png
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification:
              (int id, String title, String body, String payload) async {
            didReceiveLocalNotificationSubject.add(ReceivedNotification(
                id: id, title: title, body: body, payload: payload));
          });
  const MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false);
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    selectNotificationSubject.add(payload);
  });
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String username, password, botId;
  AppState appState = locator<AppState>();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      // appState = state;
      print("from main: $state");
      if (state == AppLifecycleState.detached) {
        print("Closing App");
      }
      appState.setState(state);
    });
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _homeScreenText = "Waiting for token...";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setupNotifications();

    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
      print(_homeScreenText);
    });
    _requestPermissions();
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserData>(
      create: (BuildContext context) =>
          locator<AuthenticationService>().userController.stream,
      child: ChangeNotifierProvider<AppState>(
        create: (context) => appState,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Support Agent App',
          theme: ThemeData(
              textTheme:
                  GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
              primaryColor: AccentBlue),
          initialRoute: 'login',
          onGenerateRoute: Router.generateRoute,
        ),
      ),
    );
  }
}
