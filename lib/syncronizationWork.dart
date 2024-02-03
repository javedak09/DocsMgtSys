import 'dart:io';

import 'package:dio/dio.dart';
import 'package:docsmgtsys/CVars.dart';
import 'package:docsmgtsys/CustomAlertDialog.dart';
import 'package:docsmgtsys/DBProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;

class synchronizationWork {
  syncSampleEntryModel(BuildContext context) async {
    try {
      Database db = await DBProvider().initDb();
      List<Map<String, dynamic>> lst = await db.query("sampleentry");
      List<Map<String, dynamic>> lstFiles = await db.query("files");

      //Map<String, dynamic> lst1 = SampleEntryModel().toMap();

      var formData = FormData.fromMap(
          {"sampleEntrymodel": lst, "filesEntryModel": lstFiles});

      var response = Dio().post(
          GlobalVariables().SERVER_URL! + "webapi/Home/SyncData",
          data: formData);

      syncSampleEntryFiles(context);
    } catch (e) {
      print(e.toString());
      CustomAlertDialog.ShowAlertDialog(context, e.toString());
    }
  }

  syncSampleEntryFiles(BuildContext context) async {
    FTPConnect? ftpConnect;

    try {
      /*WidgetsFlutterBinding.ensureInitialized();
      Future<String> str = rootBundle.loadString("assets/config.xml");
      print(str);

      final config_fl = File("assets/config.xml");
      final document = XmlDocument.parse(config_fl.readAsStringSync());
      final dataNodes = document.findElements('data').first;
      final node = dataNodes.findElements('userid');

// Extract employee data using a loop
      for (final node_loop in node) {
        final name = node_loop.findElements('userid').first.text;
        final salary = node_loop.findElements('paswd').first.text;
      }*/

      final appDocDir = await getExternalStorageDirectory();

      var arr = appDocDir!.path.split('/');

      Directory? appDocDirFolder = Directory(arr[0] +
          "/" +
          arr[1] +
          "/" +
          arr[2] +
          "/" +
          arr[3] +
          '/DCIM/docsmgtsys/');

      var dirs = appDocDirFolder.listSync(recursive: true);

      var index = 0;

      ftpConnect = new FTPConnect(GlobalVariables().TESTSERVER_FTP!,
          user: "support.jk", pass: "Dellpro.1903", port: 21);
      await ftpConnect.connect();

      for (var dir in dirs) {
        var mydir = dirs[index].path;

        arr = mydir.split('/');

        if (Directory(dir.path).existsSync() == true) {
          await ftpConnect.createFolderIfNotExist(arr[6]);
        }

        if (File(dir.path).existsSync() == true) {
          // await ftpConnect.changeDirectory("webapi");
          await ftpConnect.changeDirectory(arr[6]);
          await ftpConnect.uploadFile(File(dirs[index].path));
        }

        await ftpConnect.changeDirectory("/");
        index++;
      }

      CustomAlertDialog.ShowAlertDialog(context, "Data uploaded on the server");
    } catch (e) {
      print(e.toString());
      CustomAlertDialog.ShowAlertDialog(context, e.toString());
    } finally {
      await ftpConnect?.disconnect();
    }
  }

  loginUser(BuildContext context, {@required userid, @required passwd}) {
    try {
      List<Map<String, dynamic>> loginMap = [
        {"userid": userid, "passwd": passwd}
      ];

      var formData = FormData.fromMap({"loginModel": loginMap});

      var response = Dio().post(
          GlobalVariables().SERVER_URL! + "webapi/Login/Authenticate",
          data: formData);

      print(response);
    } catch (e) {
      CustomAlertDialog.ShowAlertDialog(context, e.toString());
    }
  }
}
