class BotStatus {
  bool success;
  String message;
  Data data;

  BotStatus({this.success, this.message, this.data});

  BotStatus.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  bool paused;

  Data({this.paused});

  Data.fromJson(Map<String, dynamic> json) {
    paused = json['paused'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['paused'] = this.paused;
    return data;
  }
}