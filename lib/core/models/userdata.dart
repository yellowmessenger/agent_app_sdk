class UserData {
  String accessToken;
  User user;
  String username;
  String error;

  UserData({this.accessToken, this.user, this.username, this.error});

  UserData.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    username = json['username'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if(this.error ==null){
    data['access_token'] = this.accessToken;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    data['username'] = this.username;
    }
    else data['error'] = this.error;
    return data;
  }
}

class User {
  String username;
  String name;
  int id;
  String proPic;
  String email;
  String xmppPassword;
  List<Roles> roles;

  User(
      {this.username,
      this.name,
      this.id,
      this.proPic,
      this.email,
      this.xmppPassword,
      this.roles});

  User.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    name = json['name'];
    id = json['id'];
    proPic = json['proPic'] ?? '';
    email = json['email'];
    xmppPassword = json['xmppPassword'] ?? '';
    if (json['roles'] != null) {
      roles = new List<Roles>();
      json['roles'].forEach((v) {
        roles.add(new Roles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['name'] = this.name;
    data['id'] = this.id;
    data['proPic'] = this.proPic;
    data['email'] = this.email;
    data['xmppPassword'] = this.xmppPassword;
    if (this.roles != null) {
      data['roles'] = this.roles.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Roles {
  String role;
  String owner;

  Roles({this.role, this.owner});

  Roles.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    owner = json['owner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['role'] = this.role;
    data['owner'] = this.owner;
    return data;
  }
}
