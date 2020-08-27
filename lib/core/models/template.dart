class Template {
  bool success;
  String message;
  List<CannedResponse> data;

  Template({this.success, this.message, this.data});

  Template.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<CannedResponse>();
      json['data'].forEach((v) {
        data.add(new CannedResponse.fromJson(v));
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

class CannedResponse {
  String sId;
  String tag;
  String text;
  String agentId;
  String botId;
  String created;
  int iV;
  String fileType;
  String url;

  CannedResponse(
      {this.sId,
      this.tag,
      this.text,
      this.agentId,
      this.botId,
      this.created,
      this.iV,
      this.fileType,
      this.url});

  CannedResponse.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    tag = json['tag'];
    text = json['text'];
    agentId = json['agentId'];
    botId = json['botId'];
    created = json['created'];
    iV = json['__v'];
    fileType = json['fileType'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['tag'] = this.tag;
    data['text'] = this.text;
    data['agentId'] = this.agentId;
    data['botId'] = this.botId;
    data['created'] = this.created;
    data['__v'] = this.iV;
    data['fileType'] = this.fileType;
    data['url'] = this.url;
    return data;
  }
}
