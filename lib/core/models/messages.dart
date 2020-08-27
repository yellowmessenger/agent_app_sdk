import 'dart:convert' as convertor;

class Messages {
  bool success;
  String message;
  List<Message> data;

  Messages({this.success, this.message, this.data});

  Messages.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Message>();
      json['data'].forEach((v) {
        data.add(new Message.fromJson(v));
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

class Message {
  String sId;
  DateTime created;
  DateTime updated;
  String botId;
  String uid;
  String message;
  String messageType;
  String caption;
  String sessionId;
  String slug;
  String feedback;
  String source;
  String questionId;
  String medium;
  int iV;
  String agentId;
  String messageFormat;

  Message(
      {this.sId,
      this.created,
      this.updated,
      this.botId,
      this.uid,
      this.message,
      this.messageType,
      this.sessionId,
      this.slug,
      this.caption,
      this.feedback,
      this.source,
      this.questionId,
      this.medium,
      this.iV,
      this.agentId,
      this.messageFormat});

  Message.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    created = DateTime.parse(json['created']);
    updated = json['updated'] == "" || json['updated'] == null
        ? created
        : DateTime.parse(json['updated']);

    botId = json['botId'];
    uid = json['uid'];
    message = json['message'];
    messageType = json['messageType'];
    sessionId = json['sessionId'];
    slug = json['slug'];
    feedback = json['feedback'];
    source = json['source'];
    questionId = json['questionId'];
    medium = json['medium'];
    iV = json['__v'];
    agentId = json['agentId'];
    if (message[0] == "{" && message[message.length - 1] == "}") {
      try {
        Map<String, dynamic> currentMsg = convertor.json.decode(message);

        messageFormat = currentMsg['message'] != null
            ? "text"
            : currentMsg['image'] != null
                ? "image"
                : currentMsg['file'] != null ? "file" : "other";
        caption = messageFormat == "image"
            ? currentMsg['options'] != null
                ? currentMsg['options']["caption"]
                : currentMsg['caption'] ?? null
            : null;
      } catch (e) {}
    } else {
      messageFormat = "text";
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['created'] = this.created.toIso8601String();
    data['updated'] = this.updated.toIso8601String();
    data['botId'] = this.botId;
    data['uid'] = this.uid;
    data['message'] = this.message;
    data['messageType'] = this.messageType;
    data['sessionId'] = this.sessionId;
    data['slug'] = this.slug;
    data['feedback'] = this.feedback;
    data['source'] = this.source;
    data['questionId'] = this.questionId;
    data['medium'] = this.medium;
    data['__v'] = this.iV;
    data['agentId'] = this.agentId;
    return data;
  }
}
