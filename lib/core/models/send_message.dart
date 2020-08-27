class SendMessage {
  String message;
  String messageType;
  String agentId;
  String uid;
  String source;
  String created;
  String ticketId;
  String type;

  SendMessage(
      {this.message,
      this.messageType,
      this.agentId,
      this.uid,
      this.source,
      this.created,
      this.ticketId,
      this.type});

  SendMessage.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    messageType = json['messageType'];
    agentId = json['agentId'];
    uid = json['uid'];
    source = json['source'];
    created = json['created'];
    ticketId = json['ticketId'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['messageType'] = this.messageType;
    data['agentId'] = this.agentId;
    data['uid'] = this.uid;
    data['source'] = this.source;
    data['created'] = this.created;
    data['ticketId'] = this.ticketId;
    data['type'] = this.type;
    return data;
  }
}