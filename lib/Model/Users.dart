class Users {
  final String? id;
  final String? userid;
  final String? passwd;
  final String? userstatus;
  final String? isadmin;

  static final columns = ["id", "userid", "passwd", "userstatus", "isadmin"];

  const Users(
      {this.id, this.userid, this.passwd, this.userstatus, this.isadmin});

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
        id: json['id'] as String,
        userid: json['userid'] as String,
        passwd: json['passwd'] as String,
        userstatus: json['userstatus'] as String,
        isadmin: json['isadmin'] as String);
  }

  String? get username => userid;

  String? get password => passwd;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["userid"] = userid;
    map["passwd"] = passwd;
    map["userstatus"] = userstatus;
    map["isadmin"] = isadmin;
    return map;
  }
}

class Character {
  int id;
  String name;
  String img;
  String nickname;

  Character.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        img = json['img'],
        nickname = json['nickname'];

  Map toJson() {
    return {'id': id, 'name': name, 'img': img, 'nickname': nickname};
  }
}
