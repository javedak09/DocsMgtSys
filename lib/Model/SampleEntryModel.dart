class SampleEntryModel {
  final String? id;
  final String? projectid;
  final String? sampleid;

  static final columns = ["id", "projectid", "sampleid"];

  SampleEntryModel({this.id, this.projectid, this.sampleid});

  factory SampleEntryModel.fromJson(Map<String, dynamic> json) {
    return SampleEntryModel(
        id: json['id'] as String,
        projectid: json['projectid'] as String,
        sampleid: json['sampleid'] as String);
  }

  static List<SampleEntryModel>? fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => SampleEntryModel.fromJson(item)).toList();
  }

  String? get setprojectid => projectid;

  String? get setsampleid => sampleid;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["projectid"] = projectid;
    map["sampleid"] = sampleid;
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
