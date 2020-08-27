class MessageFormat {
  String type;
  Map data;
  String uid;
  String source;
  String ticketId;
  Contact contact;
  String messageType;

  MessageFormat(
      {this.type,
      this.data,
      this.uid,
      this.source,
      this.ticketId,
      this.contact,
      this.messageType});

  MessageFormat.fromJson(Map<String, dynamic> json) {
    type = json['type'];

    uid = json['uid'];
    source = json['source'];
    ticketId = json['ticketId'];
    contact =
        json['contact'] != null ? Contact.fromJson(json['contact']) : null;
    messageType = json['messageType'] != null ? json['messageType'] : null;
    //  data = null;
    data = json['data'] != null
        ? json['data'] as Map<String, dynamic>
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    if (this.data != null) {
      // data['data'] = this.data.toJson();
    }
    data['uid'] = this.uid;
    data['source'] = this.source;
    data['ticketId'] = this.ticketId;
    if (this.contact != null) {
      data['contact'] = this.contact.toJson();
    }
    data['messageType'] = this.messageType;
    return data;
  }
}

class Data {
  String message;

  Data({this.message});

  Data.fromJson(Map<String, dynamic> json) {
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    return data;
  }
}

class TypingData {
  bool typing;
  TypingData({this.typing});
  TypingData.fromJson(Map<String, dynamic> json) {
    typing = json['typing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['typing'] = this.typing;
    return data;
  }
}

class Contact {
  String phone;
  String name;
  String email;

  Contact({this.phone, this.name, this.email});

  Contact.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone'] = this.phone;
    data['name'] = this.name;
    data['email'] = this.email;
    return data;
  }
}
