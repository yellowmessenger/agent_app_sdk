import 'package:support_agent/core/models/tickets.dart';

class TicketSettings {
  bool success;
  String message;
  Data data;

  TicketSettings({this.success, this.message, this.data});

  TicketSettings.fromJson(Map<String, dynamic> json) {
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
  Settings settings;
  AgentProfileSettings agentProfile;

  Data({this.settings, this.agentProfile});

  Data.fromJson(Map<String, dynamic> json) {
    settings = json['settings'] != null
        ? new Settings.fromJson(json['settings'])
        : null;
    agentProfile = json['agentProfile'] != null
        ? new AgentProfileSettings.fromJson(json['agentProfile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.settings != null) {
      data['settings'] = this.settings.toJson();
    }
    if (this.agentProfile != null) {
      data['agentProfile'] = this.agentProfile.toJson();
    }
    return data;
  }
}

class Settings {
  String customFieldsValidationFn;
  List<String> tags;
  String csatRatingType;
  bool csatEnabled;
  String ticketRatingQuestion;
  String agentRatingQuestion;
  bool askTicketRating;
  bool askAgentRating;
  String solved;
  String unsolved;
  dynamic emailChatLogsToUser;
  TicketUpdateEventSettings ticketUpdateEventSettings;
  String sId;
  String createdDate;
  String updatedDate;
  String botId;
  bool enableCollaboration;
  int iV;
  List<dynamic> closeTicketOptions;
  List<AgentUiConfiguration> agentUiConfiguration;
  List<TicketsQueueConfig> ticketsQueueConfig;
  TicketAutoCloseTimeout ticketAutoCloseTimeout;
  CustomFields customFields;

  Settings(
      {this.customFieldsValidationFn,
      this.tags,
      this.csatRatingType,
      this.csatEnabled,
      this.ticketRatingQuestion,
      this.agentRatingQuestion,
      this.askTicketRating,
      this.askAgentRating,
      this.solved,
      this.unsolved,
      this.emailChatLogsToUser,
      this.ticketUpdateEventSettings,
      this.sId,
      this.createdDate,
      this.updatedDate,
      this.botId,
      this.enableCollaboration,
      this.iV,
      this.closeTicketOptions,
      this.agentUiConfiguration,
      this.ticketsQueueConfig,
      this.ticketAutoCloseTimeout,
      this.customFields});

  Settings.fromJson(Map<String, dynamic> json) {
    customFieldsValidationFn = json['customFieldsValidationFn'];
    tags = json['tags'].cast<String>();
    csatRatingType = json['csatRatingType'];
    csatEnabled = json['csatEnabled'];
    ticketRatingQuestion = json['ticketRatingQuestion'];
    agentRatingQuestion = json['agentRatingQuestion'];
    askTicketRating = json['askTicketRating'];
    askAgentRating = json['askAgentRating'];
    solved = json['solved'];
    unsolved = json['unsolved'];
    emailChatLogsToUser = json['emailChatLogsToUser'];
    ticketUpdateEventSettings = json['ticketUpdateEventSettings'] != null
        ? new TicketUpdateEventSettings.fromJson(
            json['ticketUpdateEventSettings'])
        : null;
    sId = json['_id'];
    createdDate = json['createdDate'];
    updatedDate = json['updatedDate'];
    botId = json['botId'];
    iV = json['__v'];
    if (json['closeTicketOptions'] != null) {
      closeTicketOptions = new List<dynamic>();
      json['closeTicketOptions'].forEach((v) {
        closeTicketOptions.add(v);
      });
    }
    if (json['agentUiConfiguration'] != null) {
      agentUiConfiguration = new List<AgentUiConfiguration>();
      json['agentUiConfiguration'].forEach((v) {
        agentUiConfiguration.add(new AgentUiConfiguration.fromJson(v));
      });
    }
    if (json['enableCollaboration'] != null) {
      enableCollaboration = json['enableCollaboration'];
    }
    if (json['ticketsQueueConfig'] != null) {
      ticketsQueueConfig = new List<TicketsQueueConfig>();
      json['ticketsQueueConfig'].forEach((v) {
        ticketsQueueConfig.add(new TicketsQueueConfig.fromJson(v));
      });
    }
    ticketAutoCloseTimeout = json['ticketAutoCloseTimeout'] != null
        ? new TicketAutoCloseTimeout.fromJson(json['ticketAutoCloseTimeout'])
        : null;
    customFields = json['customFields'] != null
        ? new CustomFields.fromJson(json['customFields'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customFieldsValidationFn'] = this.customFieldsValidationFn;
    data['tags'] = this.tags;
    data['csatRatingType'] = this.csatRatingType;
    data['csatEnabled'] = this.csatEnabled;
    data['ticketRatingQuestion'] = this.ticketRatingQuestion;
    data['agentRatingQuestion'] = this.agentRatingQuestion;
    data['askTicketRating'] = this.askTicketRating;
    data['askAgentRating'] = this.askAgentRating;
    data['solved'] = this.solved;
    data['unsolved'] = this.unsolved;
    data['emailChatLogsToUser'] = this.emailChatLogsToUser;
    if (this.ticketUpdateEventSettings != null) {
      data['ticketUpdateEventSettings'] =
          this.ticketUpdateEventSettings.toJson();
    }
    data['_id'] = this.sId;
    data['createdDate'] = this.createdDate;
    data['updatedDate'] = this.updatedDate;
    data['botId'] = this.botId;
    data['__v'] = this.iV;
    if (this.closeTicketOptions != null) {
      data['closeTicketOptions'] =
          this.closeTicketOptions.map((v) => v.toJson()).toList();
    }
    if (this.agentUiConfiguration != null) {
      data['agentUiConfiguration'] =
          this.agentUiConfiguration.map((v) => v.toJson()).toList();
    }
    if (this.ticketsQueueConfig != null) {
      data['ticketsQueueConfig'] =
          this.ticketsQueueConfig.map((v) => v.toJson()).toList();
    }
    if (this.ticketAutoCloseTimeout != null) {
      data['ticketAutoCloseTimeout'] = this.ticketAutoCloseTimeout.toJson();
    }
    if (this.customFields != null) {
      data['customFields'] = this.customFields.toJson();
    }

    return data;
  }
}

class TicketUpdateEventSettings {
  bool assignedFromQueue;
  bool ticketClosed;
  bool tagUpdate;
  bool noteUpdate;
  bool customFieldUpdate;
  bool ticketTransfer;
  String sId;

  TicketUpdateEventSettings(
      {this.assignedFromQueue,
      this.ticketClosed,
      this.tagUpdate,
      this.noteUpdate,
      this.customFieldUpdate,
      this.ticketTransfer,
      this.sId});

  TicketUpdateEventSettings.fromJson(Map<String, dynamic> json) {
    assignedFromQueue = json['assignedFromQueue'];
    ticketClosed = json['ticketClosed'];
    tagUpdate = json['tagUpdate'];
    noteUpdate = json['noteUpdate'];
    customFieldUpdate = json['customFieldUpdate'];
    ticketTransfer = json['ticketTransfer'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['assignedFromQueue'] = this.assignedFromQueue;
    data['ticketClosed'] = this.ticketClosed;
    data['tagUpdate'] = this.tagUpdate;
    data['noteUpdate'] = this.noteUpdate;
    data['customFieldUpdate'] = this.customFieldUpdate;
    data['ticketTransfer'] = this.ticketTransfer;
    data['_id'] = this.sId;
    return data;
  }
}

class AgentUiConfiguration {
  bool ticketReportDownloadVisibility;
  bool enableAttachments;
  bool publicChatUrlVisibility;
  bool chatTranscriptDownloadVisibility;
  bool userActivityVisibility;
  bool userLocationVisibility;
  bool enableEmoji;
  bool enablePauseBot;
  bool showBotAttachments;
  String sId;
  String agentUsername;

  AgentUiConfiguration(
      {this.ticketReportDownloadVisibility,
      this.enableAttachments,
      this.publicChatUrlVisibility,
      this.chatTranscriptDownloadVisibility,
      this.userActivityVisibility,
      this.userLocationVisibility,
      this.enableEmoji,
      this.enablePauseBot,
      this.showBotAttachments,
      this.sId,
      this.agentUsername});

  AgentUiConfiguration.fromJson(Map<String, dynamic> json) {
    ticketReportDownloadVisibility = json['ticketReportDownloadVisibility'];
    enableAttachments = json['enableAttachments'];
    publicChatUrlVisibility = json['publicChatUrlVisibility'];
    chatTranscriptDownloadVisibility = json['chatTranscriptDownloadVisibility'];
    userActivityVisibility = json['userActivityVisibility'];
    userLocationVisibility = json['userLocationVisibility'];
    enableEmoji = json['enableEmoji'];
    enablePauseBot = json['enablePauseBot'];
    showBotAttachments = json['showBotAttachments'];
    sId = json['_id'];
    agentUsername = json['agentUsername'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ticketReportDownloadVisibility'] =
        this.ticketReportDownloadVisibility;
    data['enableAttachments'] = this.enableAttachments;
    data['publicChatUrlVisibility'] = this.publicChatUrlVisibility;
    data['chatTranscriptDownloadVisibility'] =
        this.chatTranscriptDownloadVisibility;
    data['userActivityVisibility'] = this.userActivityVisibility;
    data['userLocationVisibility'] = this.userLocationVisibility;
    data['enableEmoji'] = this.enableEmoji;
    data['enablePauseBot'] = this.enablePauseBot;
    data['showBotAttachments'] = this.showBotAttachments;
    data['_id'] = this.sId;
    data['agentUsername'] = this.agentUsername;
    return data;
  }
}

class TicketsQueueConfig {
  bool allowTicketsQueue;
  int maxQueueLimit;
  String sId;
  String groupCode;

  TicketsQueueConfig(
      {this.allowTicketsQueue, this.maxQueueLimit, this.sId, this.groupCode});

  TicketsQueueConfig.fromJson(Map<String, dynamic> json) {
    allowTicketsQueue = json['allowTicketsQueue'];
    maxQueueLimit = json['maxQueueLimit'];
    sId = json['_id'];
    groupCode = json['groupCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['allowTicketsQueue'] = this.allowTicketsQueue;
    data['maxQueueLimit'] = this.maxQueueLimit;
    data['_id'] = this.sId;
    data['groupCode'] = this.groupCode;
    return data;
  }
}

class TicketAutoCloseTimeout {
  Default ticketCloseTimeout;

  TicketAutoCloseTimeout({this.ticketCloseTimeout});

  TicketAutoCloseTimeout.fromJson(Map<String, dynamic> json) {
    ticketCloseTimeout =
        json['default'] != null ? new Default.fromJson(json['default']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.ticketCloseTimeout != null) {
      data['default'] = this.ticketCloseTimeout.toJson();
    }
    return data;
  }
}

class Default {
  int timeout;
  bool enabled;

  Default({this.timeout, this.enabled});

  Default.fromJson(Map<String, dynamic> json) {
    timeout = json['timeout'];
    enabled = json['enabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timeout'] = this.timeout;
    data['enabled'] = this.enabled;
    return data;
  }
}

class CustomFields {
  Map<String, Field> fields = Map<String, Field>();

  CustomFields({this.fields});

  CustomFields.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      fields[key] = json[key] != null ? Field.fromJson(json[key]) : null;
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

class Field {
  bool requiredToCreateTicket;
  bool requiredToCloseTicket;
  bool requiredToTransferTicket;
  String description;
  String name;
  List<dynamic> tags;
  List<dynamic> checkboxes;
  String type;

  Field(
      {this.requiredToCreateTicket,
      this.requiredToCloseTicket,
      this.requiredToTransferTicket,
      this.description,
      this.name,
      this.checkboxes,
      this.tags,
      this.type});

  Field.fromJson(Map<String, dynamic> json) {
    requiredToCreateTicket = json['requiredToCreateTicket'];
    requiredToCloseTicket = json['requiredToCloseTicket'];
    requiredToTransferTicket = json['requiredToTransferTicket'];
    description = json['description'];
    name = json['name'];
    checkboxes = json['checkboxes'] ?? null;
    tags = json['tags'] ?? null;
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['requiredToCreateTicket'] = this.requiredToCreateTicket;
    data['requiredToCloseTicket'] = this.requiredToCloseTicket;
    data['requiredToTransferTicket'] = this.requiredToTransferTicket;
    data['description'] = this.description;
    data['name'] = this.name;
    data['type'] = this.type;
    return data;
  }
}

class AgentProfileSettings {
  int id;
  String owner;
  String username;
  int userId;
  String name;
  String profilePicture;
  String description;
  int maxConnTickets;
  bool callEnabled;
  bool voipCallEnabled;
  String voipPassword;
  String webrtcUsername;
  String email;

  AgentProfileSettings(
      {this.id,
      this.owner,
      this.username,
      this.userId,
      this.name,
      this.profilePicture,
      this.description,
      this.maxConnTickets,
      this.callEnabled,
      this.voipCallEnabled,
      this.voipPassword,
      this.webrtcUsername,
      this.email});

  AgentProfileSettings.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    owner = json['owner'];
    username = json['username'];
    userId = json['user_id'];
    name = json['name'];
    profilePicture = json['profile_picture'];
    description = json['description'];
    maxConnTickets = json['max_conn_tickets'];
    callEnabled = json['call_enabled'];
    voipCallEnabled = json['voip_call_enabled'];
    voipPassword = json['voip_password'];
    webrtcUsername = json['webrtc_username'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['owner'] = this.owner;
    data['username'] = this.username;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['profile_picture'] = this.profilePicture;
    data['description'] = this.description;
    data['max_conn_tickets'] = this.maxConnTickets;
    data['call_enabled'] = this.callEnabled;
    data['voip_call_enabled'] = this.voipCallEnabled;
    data['voip_password'] = this.voipPassword;
    data['webrtc_username'] = this.webrtcUsername;
    data['email'] = this.email;
    return data;
  }
}
