import 'package:flutter/cupertino.dart';
import 'package:docsmgtsys/Model/ProjectModel.dart';
import 'dart:async';
import 'package:docsmgtsys/DBProvider.dart';

class ProjectController {
  DBProvider con = new DBProvider();

  //insertion
  Future<int> saveUser(ProjectModel proj) async {
    var dbClient = await con.db;
    int res = await dbClient!.insert("project", proj.toMap());
    return res;
  }

  //deletion
  Future<int> deleteUser(ProjectModel proj) async {
    var dbClient = await con.db;
    int res = await dbClient!.delete("project");
    return res;
  }

  Future<List<Map<String, dynamic>>> getSampleInfo(String id) async {
    var dbClient = await con.db;
    return await dbClient!.query("project", where: "id = '$id'");
  }

  Future<List> getProjects_All(String proj) async {
    var dbClient = await con.db;
    List<Map<String, dynamic>> lst_proj =
        await dbClient!.query("project", where: "projectname = '$proj'");

    //List<String> lst_proj1 = await dbClient.query("project");

    //return ProjectModel(projectname: lst_proj[0]["projectname"]);
    return lst_proj;
  }

  Future<bool> isLoggedIn() async {
    var dbClient = await con.db;
    var res = await dbClient!.query("project");
    return res.length > 0 ? true : false;
  }

/*Future<List<ProjectModel!>> getProjects() async {
    var dbClient = await con.db;
    List<Map> list = await dbClient!.rawQuery('SELECT * FROM project');

    for (int i = 0; i < list.length; i++) {
      return List?.generate(list.length, (index) {
        return ProjectModel(
            id: list[index]["id"], projectname: list[index]["projectname"]);
      });
    }
    print(list.length);
  }*/
}
