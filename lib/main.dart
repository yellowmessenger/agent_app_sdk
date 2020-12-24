import 'dart:async';
import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart' hide Router;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:support_agent/core/models/config.dart';
import 'package:support_agent/core/models/userdata.dart';
import 'package:support_agent/core/services/common.dart';
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

  // // Without Crashlytics
  // setupLocator();
  // runApp(MyApp());
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    print(notification);
  }

  // Or do other work.
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

NotificationAppLaunchDetails notificationAppLaunchDetails;

setupNotifications() async {
  // NotificationService _notificationService = locator<NotificationService>();

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
  Configurations config = locator<Configurations>();
  static const platform =
      const MethodChannel('com.yellowmessenger.support_agent/data');

//  _MyAppState() {
//    // platform.setMethodCallHandler(_receiveFromHost);
//    _getConfig();
//  }
  _getConfig() async {
    var data = await platform.invokeMethod("getConfig");

    final jData = jsonDecode(data);
    print(jData);
    setState(() {
      username = jData['username'];
      password = jData['password'];
      botId = jData['botId'];
    });
    config
        .setState({"username": username, "password": password, "botId": botId});
  }

  Future<void> _receiveFromHost(MethodCall call) async {
    String username, password, botId;

    try {
      print(call.method);

      if (call.method == "getConfig") {
        final String data = call.arguments;
        print(call.arguments);
        final jData = jsonDecode(data);

        username = jData['username'];
        password = jData['password'];
        botId = jData['botId'];
      }
    } on PlatformException catch (e) {
      //platform may not able to send proper data.
    }

    // setState(() {
    //   _first = f;
    //   _second = s;
    // });
  }

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
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: false));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      // print("Settings registered: $settings");
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print(jsonEncode(message));

        sendNotification(
            message['notification']['title'], message['notification']['body']);
      },
      onLaunch: (Map<String, dynamic> message) async {
        // print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        // print("onResume: $message");
      },
    );
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
          initialRoute: '/',
          onGenerateRoute: Router.generateRoute,
        ),
      ),
    );
  }
}
