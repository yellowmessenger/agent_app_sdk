class AgentActions {
  bool success;
  String message;
  List<ActionResponses> data;

  AgentActions({this.success, this.message, this.data});

  AgentActions.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = List<ActionResponses>();
      json['data'].forEach((k, v) {
        data.add(ActionResponses.fromJson(v, k));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ActionResponses {
  String name;
  bool action;
  List<Steps> steps;
  bool shortcut;
  String description;

  ActionResponses({this.action, this.steps, this.shortcut, this.description});

  ActionResponses.fromJson(Map<String, dynamic> json, String k) {
    name = k;
    action = json['action'];
    if (json['steps'] != null) {
      steps = List<Steps>();
      json['steps'].forEach((v) {
        steps.add(Steps.fromJson(v));
      });
    }
    shortcut = json['shortcut'];
    description = json['description'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['action'] = this.action;
    if (this.steps != null) {
      data['steps'] = this.steps.map((v) => v.toJson()).toList();
    }
    data['shortcut'] = this.shortcut;
    data['description'] = this.description ?? "";
    return data;
  }
}

class Steps {
  String id;
  String slug;
  bool mandatory;
  String description;

  Steps({this.id, this.slug, this.mandatory, this.description});

  Steps.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    mandatory = json['mandatory'];
    description = json['description'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['slug'] = this.slug;
    data['mandatory'] = this.mandatory;
    data['description'] = this.description;
    return data;
  }
}
