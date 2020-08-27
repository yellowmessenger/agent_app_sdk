class Agents {
  bool success;
  String message;
  List<AgentItem> agentItems;

  Agents({this.success, this.message, this.agentItems});

  Agents.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      agentItems = new List<AgentItem>();
      json['data'].forEach((v) {
        agentItems.add(new AgentItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.agentItems != null) {
      data['data'] = this.agentItems.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AgentItem {
  String sId;
  String agentId;
  String botId;
  String updatedAt;
  String status;
  int iV;
  String createdAt;
  int currentHandlingTicketsCount;
  bool currentVoiceCallStatus;
  AgentProfile agentProfile;
  String groupCode;
  String groupName;
  ActivitySummary activitySummary;

  AgentItem(
      {this.sId,
      this.agentId,
      this.botId,
      this.updatedAt,
      this.status,
      this.iV,
      this.createdAt,
      this.currentHandlingTicketsCount,
      this.currentVoiceCallStatus,
      this.agentProfile,
      this.groupCode,
      this.groupName,
      this.activitySummary});

  AgentItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    agentId = json['agentId'];
    botId = json['botId'];
    updatedAt = json['updatedAt'];
    status = json['status'];
    iV = json['__v'];
    createdAt = json['createdAt'];
    currentHandlingTicketsCount = json['currentHandlingTicketsCount'] ?? 0;
    currentVoiceCallStatus = json['currentVoiceCallStatus'];
    agentProfile = json['agentProfile'] != null
        ? new AgentProfile.fromJson(json['agentProfile'])
        : null;
    groupCode = json['groupCode'];
    groupName = json['groupName'];
    activitySummary = json['activitySummary'] != null
        ? new ActivitySummary.fromJson(json['activitySummary'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['agentId'] = this.agentId;
    data['botId'] = this.botId;
    data['updatedAt'] = this.updatedAt;
    data['status'] = this.status;
    data['__v'] = this.iV;
    data['createdAt'] = this.createdAt;
    data['currentHandlingTicketsCount'] = this.currentHandlingTicketsCount;
    data['currentVoiceCallStatus'] = this.currentVoiceCallStatus;
    if (this.agentProfile != null) {
      data['agentProfile'] = this.agentProfile.toJson();
    }
    data['groupCode'] = this.groupCode;
    data['groupName'] = this.groupName;
    if (this.activitySummary != null) {
      data['activitySummary'] = this.activitySummary.toJson();
    }
    return data;
  }
}

class AgentProfile {
  String email;
  int id;
  String owner;
  String username;
  int userId;
  String name;
  String profilePicture;
  String description;
  int maxConnTickets;
  int callEnabled;
  String xmppUsername;

  AgentProfile(
      {this.email,
      this.id,
      this.owner,
      this.username,
      this.userId,
      this.name,
      this.profilePicture,
      this.description,
      this.maxConnTickets,
      this.callEnabled,
      this.xmppUsername});

  AgentProfile.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    id = json['id'];
    owner = json['owner'];
    username = json['username'];
    userId = json['user_id'];
    name = json['name'];
    profilePicture = json['profile_picture'];
    description = json['description'];
    maxConnTickets = json['max_conn_tickets'];
    callEnabled = json['call_enabled'];
    xmppUsername = json['xmpp_username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['id'] = this.id;
    data['owner'] = this.owner;
    data['username'] = this.username;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['profile_picture'] = this.profilePicture;
    data['description'] = this.description;
    data['max_conn_tickets'] = this.maxConnTickets;
    data['call_enabled'] = this.callEnabled;
    data['xmpp_username'] = this.xmppUsername;
    return data;
  }
}

class ActivitySummary {
  int aCTIVE;
  int bUSY;
  int aVAILABLE;

  ActivitySummary({this.aCTIVE, this.bUSY, this.aVAILABLE});

  ActivitySummary.fromJson(Map<String, dynamic> json) {
    aCTIVE = json['ACTIVE'];
    bUSY = json['BUSY'];
    aVAILABLE = json['AVAILABLE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ACTIVE'] = this.aCTIVE;
    data['BUSY'] = this.bUSY;
    data['AVAILABLE'] = this.aVAILABLE;
    return data;
  }
}
