class Group {
  bool success;
  String message;
  List<GroupData> data;

  Group({this.success, this.message, this.data});

  Group.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<GroupData>();
      json['data'].forEach((v) {
        data.add(new GroupData.fromJson(v));
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

class GroupData {
  String name;
  String code;
  int onlineCount;
  List<dynamic> onlineUsers;
  int activeTicketCount;

  GroupData(
      {this.name,
      this.code,
      this.onlineCount,
      this.onlineUsers,
      this.activeTicketCount});

  GroupData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    onlineCount = json['onlineCount'];
    if (json['onlineUsers'] != null) {
      onlineUsers = new List<String>();
      json['onlineUsers'].forEach((v) {
        onlineUsers.add(v);
      });
    }
    activeTicketCount = json['activeTicketCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['code'] = this.code;
    data['onlineCount'] = this.onlineCount;
    if (this.onlineUsers != null) {
      data['onlineUsers'] = this.onlineUsers.map((v) => v.toJson()).toList();
    }
    data['activeTicketCount'] = this.activeTicketCount;
    return data;
  }
}