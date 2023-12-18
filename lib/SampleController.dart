import 'package:docsmgtsys/Model/SampleEntryModel.dart';
import 'dart:async';
import 'package:docsmgtsys/DBProvider.dart';

class SampleController {
  DBProvider con = new DBProvider();

  //insertion
  Future<int> saveUser(SampleEntryModel user) async {
    var dbClient = await con.db;
    int res = await dbClient!.insert("sampleentry", user!.toMap());
    return res;
  }

  //deletion
  Future<int> deleteUser(SampleEntryModel user) async {
    var dbClient = await con.db;
    int res = await dbClient!.delete("sampleentry");
    return res;
  }

  Future<List<Map<String, dynamic>>> getSampleInfo(String sampleid) async {
    var dbClient = await con.db;
    return await dbClient!
        .query("sampleentry", where: "sampleid = '$sampleid'");
  }

  Future<bool> isLoggedIn() async {
    var dbClient = await con.db;
    var res = await dbClient!.query("sampleentry");
    return res.length > 0 ? true : false;
  }

  Future<List<SampleEntryModel>> getSamples() async {
    var dbClient = await con.db;
    List<Map> list = await dbClient!.rawQuery('SELECT * FROM sampleentry');
    List<SampleEntryModel> users = [];
    for (int i = 0; i < list.length; i++) {
      /*users.add(new Users(list[i]["id"], list[i]["userid"], list[i]["passwd"],
          list[i]["userstatus"], list[i]["isadmin"]));*/
    }
    print(users.length);
    return users;
  }
}
