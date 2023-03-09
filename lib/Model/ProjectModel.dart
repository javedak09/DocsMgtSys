class ProjectModel {
  int? id;
  String? projectname;

  static final columns = ["id", "projectname"];

  ProjectModel({this.id, this.projectname});

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
        id: json['id'] as int, projectname: json['projectname'] as String);
  }

  static List<ProjectModel>? fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => ProjectModel.fromJson(item)).toList();
  }

  String projectNameAsString() {
    return '#${this.id} ${this.projectname}';
  }

  String? get setprojectname => projectname;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["projectname"] = projectname;
    return map;
  }

  ///this method will prevent the override of toString
  bool? projectFilterByName(String filter) {
    return this.projectname.toString().contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(ProjectModel model) {
    return this.id == model.id;
  }

  @override
  String toString() => projectname!;
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
