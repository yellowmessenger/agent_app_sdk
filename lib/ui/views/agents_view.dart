import 'package:flutter/material.dart';
import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/viewmodels/agents_model.dart';
import 'package:support_agent/ui/views/base_view.dart';
import 'package:support_agent/ui/widgets/agentList.dart';
import 'package:support_agent/ui/widgets/loading_content.dart';
import 'package:support_agent/ui/widgets/no_data.dart';

class AgentsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseView<AgentsModel>(
        onModelReady: (model) async => await model.initAgents(),
        builder: (context, model, child) => Scaffold(
              appBar: AppBar(title: Text("Agents")),
              body: model.state == ViewState.Busy
                  ? LoadingContent()
                  : model.getAllAgents.agentItems.length == 0
                      ? NoData()
                      : AgentList(model.getAllAgents.agentItems,),
            ));
  }

  /*
   @override
  Widget build(BuildContext context) {
    return BaseView<AgentsModel>(
        onModelReady: (model) async => await model.initAgents(),
        builder: (context, model, child) => SliverList(
              delegate: SliverChildListDelegate([
                model.state == ViewState.Busy
                    ? LoadingContent()
                    : model.getAllAgents.agentItems.length == 0
                        ? NoData()
                        : AgentList(model.getAllAgents.agentItems),
              ]),
            ));
  }
   */
}
