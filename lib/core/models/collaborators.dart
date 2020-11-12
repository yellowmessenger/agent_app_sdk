class CollaboratorModel {
  bool success;
  String message;
  List<CollaboratorProfile> data;
  bool subscriptionExceeded;

  CollaboratorModel(
      {this.success, this.message, this.data, this.subscriptionExceeded});

  CollaboratorModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<CollaboratorProfile>();
      json['data'].forEach((v) {
        data.add(new CollaboratorProfile.fromJson(v));
      });
    }
    subscriptionExceeded = json['subscriptionExceeded'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['subscriptionExceeded'] = this.subscriptionExceeded;
    return data;
  }
}

class CollaboratorProfile {
  String email;
  String username;
  String name;
  bool callEnabled;
  bool voipCallEnabled;
  String voipPassword;
  String webrtcUsername;
  String xmppUsername;
  int userId;

  CollaboratorProfile(
      {this.email,
      this.username,
      this.name,
      this.callEnabled,
      this.voipCallEnabled,
      this.voipPassword,
      this.webrtcUsername,
      this.xmppUsername,
      this.userId});

  CollaboratorProfile.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    username = json['username'];
    name = json['name'];
    callEnabled = json['call_enabled'];
    voipCallEnabled = json['voip_call_enabled'];
    voipPassword = json['voip_password'];
    webrtcUsername = json['webrtc_username'];
    xmppUsername = json['xmppUsername'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['username'] = this.username;
    data['name'] = this.name;
    data['call_enabled'] = this.callEnabled;
    data['voip_call_enabled'] = this.voipCallEnabled;
    data['voip_password'] = this.voipPassword;
    data['webrtc_username'] = this.webrtcUsername;
    data['xmppUsername'] = this.xmppUsername;
    data['user_id'] = this.userId;
    return data;
  }
}
