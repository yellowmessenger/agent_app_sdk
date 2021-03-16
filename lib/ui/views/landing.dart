import 'package:flutter/material.dart';
import 'package:support_agent/core/viewmodels/landing_model.dart';

import 'base_view.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return BaseView<LandingModel>(
        onModelReady: (model) async => await model.gotoHome(context),
        builder: (context, model, child) => Container(
              color: Colors.blue,
            ));
  }
}
