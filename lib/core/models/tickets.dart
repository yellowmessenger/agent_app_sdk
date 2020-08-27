class TicketList {
  List<Ticket> ticketList;
  bool success;
  String message;
  TicketList({this.message, this.success, this.ticketList});
  TicketList.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      ticketList = List<Ticket>();
      json['data'].forEach((v) {
        ticketList.add(Ticket.fromJson(v));
      });
    }
  }
}

class Ticket {
  List<String> tags;
  bool responded;
  String note;
  String ticketType;
  int ticketCsatScore;
  int agentCsatScore;
  List<String> comments;
  bool assignedByAdmin;
  bool manualAssignment;
  int lastAgentMessageTime;
  int lastUserMessageTime;
  int replyCount;
  String sId;
  String ticketId;
  String botId;
  String uid;
  Contact contact;
  String issue;
  String status;
  String source;
  String timestamp;
  String assignedTo;
  String xmpp;
  String assignedTime;
  List<String> logs;
  List<String> reassignmentLog;
  int iV;
  String firstResponseTime;
  String updated;
  String priority;
  String sessionId;
  AgentProfile agentProfile;
  String resolvedTime;
  double avgResponseTime;
  CustomFieldsValues customFieldsValues;

  Ticket(
      {this.tags,
      this.responded,
      this.note,
      this.ticketType,
      this.ticketCsatScore,
      this.agentCsatScore,
      this.comments,
      this.assignedByAdmin,
      this.manualAssignment,
      this.lastAgentMessageTime,
      this.lastUserMessageTime,
      this.replyCount,
      this.sId,
      this.ticketId,
      this.botId,
      this.uid,
      this.contact,
      this.issue,
      this.status,
      this.source,
      this.timestamp,
      this.assignedTo,
      this.xmpp,
      this.assignedTime,
      this.logs,
      this.reassignmentLog,
      this.iV,
      this.firstResponseTime,
      this.updated,
      this.priority,
      this.sessionId,
      this.agentProfile,
      this.resolvedTime,
      this.avgResponseTime,
      this.customFieldsValues});

  Ticket.fromJson(Map<String, dynamic> json) {
    tags = json['tags'].cast<String>();
    responded = json['responded'];
    note = json['note'];
    ticketType = json['ticketType'];
    ticketCsatScore = json['ticketCsatScore'];
    agentCsatScore = json['agentCsatScore'];
    comments = json['comments'].cast<String>();
    assignedByAdmin = json['assignedByAdmin'];
    manualAssignment = json['manualAssignment'];
    lastAgentMessageTime = json['lastAgentMessageTime'];
    lastUserMessageTime = json['lastUserMessageTime'];
    replyCount = json['replyCount'];
    sId = json['_id'];
    ticketId = json['ticketId'];
    botId = json['botId'];
    uid = json['uid'];
    contact =
        json['contact'] != null ? new Contact.fromJson(json['contact']) : null;
    issue = json['issue'];
    status = json['status'];
    source = json['source'];
    timestamp = json['timestamp'];
    assignedTo = json['assignedTo'];
    xmpp = json['xmpp'];
    assignedTime = json['assignedTime'];
    logs = json['logs'].cast<String>();
    reassignmentLog = json['reassignmentLog'].cast<String>();
    iV = json['__v'];
    firstResponseTime = json['firstResponseTime'];
    updated = json['updated'];
    priority = json['priority'];
    sessionId = json['sessionId'];
    agentProfile = json['agentProfile'] != null
        ? new AgentProfile.fromJson(json['agentProfile'])
        : null;
    resolvedTime = json['resolvedTime'];
    avgResponseTime = json['avgResponseTime'] == null
        ? null
        : double.parse(json['avgResponseTime'].toString());
    customFieldsValues = json['customFields'] != null
        ? new CustomFieldsValues.fromJson(json['customFields'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tags'] = this.tags;
    data['responded'] = this.responded;
    data['ticketType'] = this.ticketType;
    data['ticketCsatScore'] = this.ticketCsatScore;
    data['agentCsatScore'] = this.agentCsatScore;
    data['comments'] = this.comments;
    data['assignedByAdmin'] = this.assignedByAdmin;
    data['manualAssignment'] = this.manualAssignment;
    data['lastAgentMessageTime'] = this.lastAgentMessageTime;
    data['lastUserMessageTime'] = this.lastUserMessageTime;
    data['replyCount'] = this.replyCount;
    data['_id'] = this.sId;
    data['ticketId'] = this.ticketId;
    data['botId'] = this.botId;
    data['uid'] = this.uid;
    if (this.contact != null) {
      data['contact'] = this.contact.toJson();
    }
    data['issue'] = this.issue;
    data['status'] = this.status;
    data['source'] = this.source;
    data['timestamp'] = this.timestamp;
    data['assignedTo'] = this.assignedTo;
    data['xmpp'] = this.xmpp;
    data['assignedTime'] = this.assignedTime;
    data['logs'] = this.logs;
    data['reassignmentLog'] = this.reassignmentLog;
    data['__v'] = this.iV;
    data['firstResponseTime'] = this.firstResponseTime;
    data['updated'] = this.updated;
    data['priority'] = this.priority;
    data['sessionId'] = this.sessionId;
    if (this.agentProfile != null) {
      data['agentProfile'] = this.agentProfile.toJson();
    }
    data['resolvedTime'] = this.resolvedTime;
    data['avgResponseTime'] = this.avgResponseTime;
    return data;
  }
}

class Contact {
  String name;
  String email;
  String phone;

  Contact({this.name, this.email, this.phone});

  Contact.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }
}

class AgentProfile {
  String name;
  String profilePicture;
  String description;

  AgentProfile({this.name, this.profilePicture, this.description});

  AgentProfile.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    profilePicture = json['profile_picture'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['profile_picture'] = this.profilePicture;
    data['description'] = this.description;
    return data;
  }
}

class CustomFieldsValues {
  Map<String, dynamic> fields = Map<String, dynamic>();

  CustomFieldsValues({this.fields});

  CustomFieldsValues.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      fields[key] = json[key] != null ? json[key] : null;
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fields != null) {
      data['s1'] = this.fields;
    }
    return data;
  }
}
