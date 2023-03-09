import 'package:docsmgtsys/Model/Users.dart';
import 'dart:async';
import 'package:docsmgtsys/DBProvider.dart';

class LoginController {
  DBProvider con = new DBProvider();

  //insertion
  Future<int> saveUser(Users user) async {
    var dbClient = await con.db;
    int res = await dbClient!.insert("Users", user.toMap());
    return res;
  }

  //deletion
  Future<int> deleteUser(Users user) async {
    var dbClient = await con.db;
    int res = await dbClient!.delete("Users");
    return res;
  }

  Future<List<Map<String, dynamic>>> getLogin(
      String user, String password) async {
    var dbClient = await con.db;
    return await dbClient!
        .query("users", where: "userid = '$user' and passwd = '$password'");
  }

  Future<bool> isLoggedIn() async {
    var dbClient = await con.db;
    var res = await dbClient!.query("Users");
    return res.length > 0 ? true : false;
  }

  Future<List<Users>> getUsers() async {
    var dbClient = await con.db;
    List<Map> list = await dbClient!.rawQuery('SELECT * FROM Users');
    List<Users> users = [];
    for (int i = 0; i < list.length; i++) {
      /*users.add(new Users(list[i]["id"], list[i]["userid"], list[i]["passwd"],
          list[i]["userstatus"], list[i]["isadmin"]));*/
    }
    print(users.length);
    return users;
  }
}
