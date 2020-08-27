import 'package:flutter/material.dart';
import 'package:support_agent/core/viewmodels/login_model.dart';

import 'base_view.dart';

class LoginView extends StatefulWidget {
  LoginView({Key key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return BaseView<LoginModel>(
        onModelReady: (model) => model.initLogin(context),
        builder: (context, model, child) => Container(
              color: Colors.white,
            ));
  }
}
