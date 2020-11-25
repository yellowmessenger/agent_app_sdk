import 'package:flutter/material.dart';

class Redirect extends StatefulWidget {
  Redirect({Key key}) : super(key: key);

  @override
  _RedirectState createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text("welcome to redirection page."),
        ),
      ),
    );
  }
}
