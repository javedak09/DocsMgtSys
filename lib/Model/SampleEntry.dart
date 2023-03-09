class SampleEntryModel {
  final String? id;
  final String? projectname;
  final String? sampleid;
  final String? imgpath;

  static final columns = ["id", "projectname", "sampleid", "imgpath"];

  const SampleEntryModel(
      {this.id, this.projectname, this.sampleid, this.imgpath});

  factory SampleEntryModel.fromJson(Map<String, dynamic> json) {
    return SampleEntryModel(
        id: json['id'] as String,
        projectname: json['projectname'] as String,
        sampleid: json['sampleid'] as String,
        imgpath: json['imgpath'] as String);
  }

  String? get setprojectname => projectname;

  String? get setsampleid => sampleid;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["projectname"] = projectname;
    map["sampleid"] = sampleid;
    map["imgpath"] = imgpath;
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
