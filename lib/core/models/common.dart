class CommonApiModel {
  bool success;
  String message;
  dynamic data;

  CommonApiModel({this.success, this.message, this.data});

  CommonApiModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'] ?? "";
    if (json['data'] != null) {
      data = json['data'];
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