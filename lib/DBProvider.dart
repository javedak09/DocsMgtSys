import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static final DBProvider _instance = new DBProvider.internal();

  factory DBProvider() => _instance;

  static Database? _database;

  //Future<Database> get database async => _database ??= await initDb();

  // okay its is new working

  Future<Database?> get db async {
    if (_database != null) {
      return _database;
    }
    _database = await initDb();
    return _database;
  }

  DBProvider.internal();

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "sampledb.db");
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);

    return db;
  }

  Future _onCreate(Database db, int dbversion) async {
    await db.execute("CREATE TABLE IF NOT EXISTS users ("
        "id INTEGER PRIMARY KEY,"
        "userid TEXT,"
        "passwd TEXT,"
        "userstatus TEXT"
        ");");

    await db.execute("CREATE TABLE IF NOT EXISTS userslog ("
        "id INTEGER PRIMARY KEY,"
        "userid TEXT,"
        "entrydate TEXT"
        ");");

    await db.execute("CREATE TABLE IF NOT EXISTS sampleentry ("
        "id INTEGER PRIMARY KEY,"
        "tabdataid TEXT,"
        "projectid TEXT,"
        "sampleid TEXT,"
        "userid TEXT,"
        "entrydate TEXT,"
        "issynced TEXT"
        ");");

    await db.execute("CREATE TABLE IF NOT EXISTS files ("
        "id INTEGER PRIMARY KEY,"
        "projectid TEXT,"
        "sampleid TEXT,"
        "sampleentryid TEXT,"
        "filesname TEXT,"
        "issynced TEXT"
        ");");

    await db.execute("CREATE TABLE IF NOT EXISTS project ("
        "id INTEGER PRIMARY KEY,"
        "projectname TEXT"
        ");");
  }
}
