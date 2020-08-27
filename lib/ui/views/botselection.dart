import 'package:flutter/material.dart';
import 'package:support_agent/core/viewmodels/bot_selection_model.dart';

import 'base_view.dart';

class BotSelectionPage extends StatefulWidget {
  BotSelectionPage({Key key}) : super(key: key);

  @override
  _BotSelectionPageState createState() => _BotSelectionPageState();
}

class _BotSelectionPageState extends State<BotSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return BaseView<BotSelectionModel>(
        onModelReady: (model) async => await model.getBots(context),
        builder: (context, model, child) => Container(
              color: Colors.white,
            ));
  }
}

/* TODO
1. To add staging/prod/sandbox flag
 */
