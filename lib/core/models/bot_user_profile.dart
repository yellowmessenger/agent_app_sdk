class BotUser {
  bool success;
  String message;
  Data data;

  BotUser({this.success, this.message, this.data});

  BotUser.fromJson(Map<String, dynamic> json) {
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
  String sId;
  String uid;
  String bot;
  String platform;
  ProfileData profileData;
  bool firstTime;
  String created;
  String updated;
  int iV;

  Data(
      {this.sId,
      this.uid,
      this.bot,
      this.platform,
      this.profileData,
      this.firstTime,
      this.created,
      this.updated,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    uid = json['uid'];
    bot = json['bot'];
    platform = json['platform'];
    profileData = json['data'] != null ? new ProfileData.fromJson(json['data']) : null;
    firstTime = json['firstTime'];
    created = json['created'];
    updated = json['updated'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['uid'] = this.uid;
    data['bot'] = this.bot;
    data['platform'] = this.platform;
    if (this.profileData != null) {
      data['data'] = this.profileData.toJson();
    }
    data['firstTime'] = this.firstTime;
    data['created'] = this.created;
    data['updated'] = this.updated;
    data['__v'] = this.iV;
    return data;
  }
}

class ProfileData {
  UserAgent userAgent;
  String payload;
  String city;
  String country;
  String region;
  String longitude;
  String latitude;
  int endIp;
  String value;
  String countryCode;
  int startIp;
  String timezone;
  String ip;
  String name;
  String userId;
  String userToken;
  String utmSource;
  String utmCampaign;
  String utmMedium;
  String utmTerm;
  String utmContent;

  ProfileData(
      {this.userAgent,
      this.payload,
      this.city,
      this.country,
      this.region,
      this.longitude,
      this.latitude,
      this.endIp,
      this.value,
      this.countryCode,
      this.startIp,
      this.timezone,
      this.ip,
      this.name,
      this.userId,
      this.userToken,
      this.utmSource,
      this.utmCampaign,
      this.utmMedium,
      this.utmTerm,
      this.utmContent});

  ProfileData.fromJson(Map<String, dynamic> json) {
    userAgent = json['userAgent'] != null
        ? new UserAgent.fromJson(json['userAgent'])
        : null;
    payload = "";
    // print(json['payload']);
    // payload = json['payload'];
    city = json['city'];
    country = json['country'];
    region = json['region'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    endIp = json['end_ip'];
    value = json['value'];
    countryCode = json['country_code'];
    startIp = json['start_ip'];
    timezone = json['timezone'];
    ip = json['ip'];
    name = json['name'];
    userId = json['userId'];
    userToken = json['userToken'];
    utmSource = json['utm_source'];
    utmCampaign = json['utm_campaign'];
    utmMedium = json['utm_medium'];
    utmTerm = json['utm_term'];
    utmContent = json['utm_content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userAgent != null) {
      data['userAgent'] = this.userAgent.toJson();
    }
    data['payload'] = this.payload;
    data['city'] = this.city;
    data['country'] = this.country;
    data['region'] = this.region;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['end_ip'] = this.endIp;
    data['value'] = this.value;
    data['country_code'] = this.countryCode;
    data['start_ip'] = this.startIp;
    data['timezone'] = this.timezone;
    data['ip'] = this.ip;
    data['name'] = this.name;
    data['userId'] = this.userId;
    data['userToken'] = this.userToken;
    data['utm_source'] = this.utmSource;
    data['utm_campaign'] = this.utmCampaign;
    data['utm_medium'] = this.utmMedium;
    data['utm_term'] = this.utmTerm;
    data['utm_content'] = this.utmContent;
    return data;
  }
}

class UserAgent {
  String browser;
  String os;
  String platform;
  String source;
  String device;

  UserAgent({this.browser, this.os, this.platform, this.source, this.device});

  UserAgent.fromJson(Map<String, dynamic> json) {
    browser = json['browser'];
    os = json['os'];
    platform = json['platform'];
    source = json['source'];
    device = json['device'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['browser'] = this.browser;
    data['os'] = this.os;
    data['platform'] = this.platform;
    data['source'] = this.source;
    data['device'] = this.device;
    return data;
  }
}
