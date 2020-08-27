import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:xmpp_rock/xmpp_rock.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _xmppReady = false;
  Stream<String> _xmppStream;
  StreamSubscription sub;
  StreamController<String> _ctrl = StreamController<String>.broadcast();
//  StreamSubscription<String> _chatStream = StreamSubscription<String>();
  @override
  void initState() {
    super.initState();
    initXmpp();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initXmpp() async {
    bool xmppReady;
    //user_1584534561143@xmpp.yellowmssngr.com : KbizuZEdQAfF
    try {
      xmppReady = await XmppRock.initialize(
          fullJid: "user_1594396759145@xmpp.yellowmssngr.com",
          password: "JfJblF7iPpKo",
          port: 443);
    } on PlatformException {
      xmppReady = false;
      // print("Xmpp initialization failed...");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _xmppReady = xmppReady;
      _xmppStream = XmppRock.xmppStream;
      _ctrl.addStream(_xmppStream);
    });
    _enableStream();
  }

  _enableStream() {
    sub = _ctrl.stream.listen(_update);
  }

  _update(data) {
    // print(data);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    sub.cancel();
    XmppRock.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String data = "";
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Xmpp Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            Text('Xmpp State.: $_xmppReady\n'),
            Text('Stream Response'),
            StreamBuilder(
                stream: _ctrl.stream,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    data = data + snapshot.data + "\n";
                    return Text('Incoming message $data');
                  }
                  return Text('NO DATA');
                })
          ],
        ),
      ),
    );
  }
}
