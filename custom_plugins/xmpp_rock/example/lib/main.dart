import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:xmpp_rock/xmpp_rock.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _xmppReady = false;
  bool _authenticated;
  Stream<String> _xmppStream;
  StreamSubscription sub;
  StreamController<String> _ctrl = StreamController<String>.broadcast();
//  StreamSubscription<String> _chatStream = StreamSubscription<String>();
  @override
  void initState() {
    super.initState();
  }

  // String uid = "";
  // String password = "";

//   flutter: user_1603256907680@xmpp.yellowmssngr.com
// flutter: fNPPbwQc2fzo

  String uid = "user_1594396759145@xmpp.yellowmssngr.com";
  String password = "JfJblF7iPpKo";

  Future<void> initXmpp() async {
    if (!mounted) return;

    try {
      await XmppRock.initialize(fullJid: uid, password: password, port: 443);
    } on PlatformException {
      setState(() {
        _xmppReady = false;
      });
    }

    if (sub == null || !sub.isPaused) {
      setState(() {
        _xmppStream = XmppRock.xmppStream;
        _ctrl.addStream(_xmppStream);
      });
      sub = _ctrl.stream.listen(_update);
    } else
      sub.resume();
  }

  disconnect() {
    setState(() {
      // sub.cancel();
      sub.pause();
      _ctrl.stream.drain();
      _ctrl = StreamController<String>.broadcast();
      _xmppReady = false;
      items = [];
    });

    XmppRock.close();
  }

  List<String> items = List();

  _update(data) {
    print(data);
    if (data[0] == "{" && data[data.length - 1] == "}") {
      Map<String, dynamic> incoming = jsonDecode(data);
      if (incoming.containsKey("connected")) {
        setState(() {
          _xmppReady = incoming["connected"];
        });
      }

      if (incoming.containsKey("authenticated")) {
        setState(() {
          _authenticated = incoming["authenticated"];
        });
      }
    }
    setState(() {
      items.add(data);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    sub.cancel();
    XmppRock.close();
    super.dispose();
  }

  ScrollController _scrollController = ScrollController();

  _scrollToBottom() {
    if (_scrollController.hasClients)
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  updateCredentials({String userid, String pass}) {
    print("Updating Creds: $userid : $pass");
    if (userid == "")
      setState(() {
        password = pass;
      });
    else
      setState(() {
        uid = userid;
      });

    print("Updated Creds: $uid : $password");
  }

  _controlForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextFormField(
              initialValue: "",
              readOnly: _xmppReady,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                hintText: "Enter jid",
                labelText: "XMPP Username",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                filled: true,
                suffixText: "@xmpp.yellowmssngr.com",
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                hintStyle:
                    TextStyle(fontWeight: FontWeight.w400, fontSize: 16.0),
              ),
              onChanged: (text) => updateCredentials(
                  userid: text + "@xmpp.yellowmssngr.com", pass: ""),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextFormField(
              initialValue: "",
              readOnly: _xmppReady,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                hintText: "Enter password",
                labelText: "XMPP password",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                hintStyle:
                    TextStyle(fontWeight: FontWeight.w400, fontSize: 16.0),
              ),
              onChanged: (text) => updateCredentials(userid: "", pass: text),
            ),
          ),
          _authenticated != null && !_authenticated
              ? Text("Wrong credentials", style: TextStyle(color: Colors.red))
              : SizedBox.shrink(),
          RaisedButton(
              disabledColor: Colors.grey,
              color: _xmppReady
                  ? Colors.red.withOpacity(0.7)
                  : Colors.green.withOpacity(0.6),
              onPressed: areCredsEmpty()
                  ? null
                  : () => _xmppReady ? disconnect() : initXmpp(),
              child: Text(
                _xmppReady ? "Disconnect" : "Connect",
                style: TextStyle(fontSize: 16, color: Colors.white),
              )),
        ],
      ),
    );
  }

  bool areCredsEmpty() {
    return uid == "" || password == "";
  }

  _streamList() {
    return Expanded(
      child: ListView.separated(
          shrinkWrap: true,
          itemCount: items.length,
          controller: _scrollController,
          // reverse: true,
          separatorBuilder: (context, index) => Divider(
                color: Colors.black,
              ),
          itemBuilder: (context, index) {
            String msg = "Unknown Message";
            bool isMessage = false;
            if (items[index][0] == "{" &&
                items[index][items[index].length - 1] == "}") {
              Map<String, dynamic> incoming = jsonDecode(items[index]);
              if (incoming["event"] != null) {
                msg = incoming["event"];
              } else if (incoming["type"] != null &&
                  incoming["type"] == "ticket-created") {
                msg = incoming["type"];
              } else if (incoming["type"] != null &&
                  incoming["type"] == "sender" &&
                  incoming["data"]["message"] != null) {
                msg = incoming["data"]["message"];
                isMessage = true;
              } else if (incoming["type"] != null &&
                  incoming["type"] == "sender" &&
                  incoming["data"]["event"] != null) {
                msg = incoming["data"]["event"]["code"];
              } else if (incoming["type"] != null &&
                  incoming["type"] == "support" &&
                  incoming["data"]["event"] != null) {
                msg = incoming["data"]["event"]["code"];
              } else if (incoming["type"] != null &&
                  incoming["type"] == "sender" &&
                  incoming["data"]["typing"] != null) {
                msg = "Typing: " + incoming["data"]["typing"].toString();
              }
            } else
              msg = items[index];

            return ExpansionTile(
              title: Text(
                msg ?? "",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16.0),
              ),
              children: <Widget>[
                ListTile(
                  title: Text(items[index]),
                )
              ],
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Image.asset("assets/xmpp_tester.png"),
          ),
        ),
        backgroundColor: Colors.amber,
        title: const Text('XMPP Connection Tester'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Control Center', style: TextStyle(fontSize: 20)),
                Chip(
                    backgroundColor: !_xmppReady
                        ? Colors.red.withOpacity(0.7)
                        : Colors.green.withOpacity(0.6),
                    label: Text(_xmppReady ? "Connected" : "Disconnected"))
              ],
            ),
            _controlForm(),
            Divider(),
            Text('Stream Response', style: TextStyle(fontSize: 20)),
            items.length > 0 ? _streamList() : Text("No Data."),
          ],
        ),
      ),
    );
  }
}
