import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:support_agent/core/models/notifications.dart';
import 'package:support_agent/core/viewmodels/base_model.dart';
import 'package:support_agent/core/models/appstate.dart';

import '../../locator.dart';

class BaseView<T extends BaseModel> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget child) builder;
  final Function(T) onModelReady;

  BaseView({this.builder, this.onModelReady});

  @override
  _BaseViewState<T> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseModel> extends State<BaseView<T>> {
  T model = locator<T>();
  Notifications notifications = locator<Notifications>();

  @override
  void initState() {
    super.initState();
    if (widget.onModelReady != null) {
      widget.onModelReady(model);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<T>.value(
        value: model,
      ),
      ChangeNotifierProvider.value(value: notifications),
    ], child: Consumer<T>(builder: widget.builder));
  }
}
