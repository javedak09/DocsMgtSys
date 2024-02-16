import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:docsmgtsys/CVars.dart';
import 'package:docsmgtsys/CustomAlertDialog.dart';
import 'package:docsmgtsys/DBProvider.dart';
import 'package:docsmgtsys/Model/SampleEntryModel.dart';
import 'package:docsmgtsys/SampleController.dart';
import 'package:docsmgtsys/SampleRegister.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class synchronizationWork {
  syncSampleEntryModel(BuildContext context) async {
    try {
      Database db = await DBProvider().initDb();
      List<Map<String, dynamic>> lst = await db.query("sampleentry",
          where: "issynced is null or issynced='' or issynced='0'");

      List<Map<String, dynamic>> lstFiles = await db.query("files",
          where: "issynced is null or issynced='' or issynced='0'");

      if (lst.length <= 0) {
        CustomAlertDialog.ShowAlertDialog(
            context, "No new records found for synchronization");
      } else {
        //Map<String, dynamic> lst1 = SampleEntryModel().toMap();

        var formData = FormData.fromMap(
            {"sampleEntrymodel": lst, "filesEntryModel": lstFiles});

        Response response = await Dio().post(
            GlobalVariables().SERVER_URL! + "webapi/Home/SyncData",
            data: formData);

        if (response.statusCode == 200) {
          if (response.data != null) {
            Map lst_new = response.data;
            print(lst_new["msg"]);
          }
          SampleController().updateSyncedColumn();
        } else {
          CustomAlertDialog.ShowAlertDialog(context, "Server error occurred");
        }
      }

      if (lstFiles.length <= 0) {
        syncSampleEntryFiles(context);
      }
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
          user: "support.jk", pass: "Dellpro.1904", port: 21);
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

  loginUser(BuildContext context, {@required userid, @required passwd}) async {
    try {
      List<Map<String, dynamic>> loginMap = [
        {"userid": userid, "passwd": passwd}
      ];

      var formData = FormData.fromMap({"loginModel": loginMap});

      Response response = await Dio().post(
          GlobalVariables().SERVER_URL! + "webapi/Login/Authenticate",
          data: formData);

      var lst_response = jsonDecode(response.toString());

      if (lst_response["msg"] != "Success") {
        CustomAlertDialog.ShowAlertDialog(context, lst_response["msg"]);
      }

      if (lst_response["msg"] == "Success") {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SampleRegister()));
      }
    } catch (e) {
      CustomAlertDialog.ShowAlertDialog(context, e.toString());
    }
  }

  AddProject(BuildContext context, {@required projectname}) async {
    try {
      List<Map<String, dynamic>> lst = [projectname];

      var formData = FormData.fromMap({"projModel": lst});

      print("i m new - " + lst.first.values.toString());

      print(formData.fields[0].key + " - " + formData.fields[0].value);

      var response = Dio().post(
          GlobalVariables().getServerURL()! + "webapi/DataSave/AddProject",
          data: formData);

      var jsonObject = jsonDecode(response.toString());

      CustomAlertDialog.ShowAlertDialog(context, jsonObject[0]);
    } catch (e) {
      CustomAlertDialog.ShowAlertDialog(context, e.toString());
    }
  }
}
