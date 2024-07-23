import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:docsmgtsys/CVars.dart';
import 'package:docsmgtsys/CustomAlertDialog.dart';
import 'package:docsmgtsys/DBProvider.dart';
import 'package:docsmgtsys/Model/ProjectModel.dart';
import 'package:docsmgtsys/Model/SampleEntryModel.dart';
import 'package:docsmgtsys/SampleController.dart';
import 'package:docsmgtsys/SampleRegister.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:intl/intl.dart';
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
            "${GlobalVariables.SERVER_URL!}webapi/Home/SyncData",
            data: formData);

        if (response.statusCode == 200) {
          SampleController().updateSyncedColumn();
        } else {
          CustomAlertDialog.ShowAlertDialog(context, "Server error occurred");
        }
      }

      if (lstFiles.length != 0) {
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

      ftpConnect = new FTPConnect(GlobalVariables.TESTSERVER_FTP!,
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

      SampleController().updateSyncedColumnFiles();

      CustomAlertDialog.ShowAlertDialog(
          context, "Files uploaded on the server");
    } catch (e) {
      CustomAlertDialog.ShowAlertDialog(context, e.toString());
    } finally {
      await ftpConnect?.disconnect();
    }
  }

  loginUser_Windows(BuildContext context,
      {@required userid, @required passwd}) async {
    try {
      List<Map<String, dynamic>> loginMap = [
        {"userid": userid, "passwd": passwd}
      ];

      var formData = FormData.fromMap({"loginModel": loginMap});

      Response response = await Dio()
          .post("${GlobalVariables.SERVER_URL!}webapi/Login/Authenticate",
              data: formData,
              options: Options(
                headers: {
                  'content-Type': 'application/json',
                  'Accept': 'application/text',
                  "Access-Control-Allow-Origin": "*",
                  // Required for CORS support to work
                  "Access-Control-Allow-Credentials": true,
                  // Required for cookies, authorization headers with HTTPS
                  "Access-Control-Allow-Headers":
                      "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
                  "Access-Control-Allow-Methods": "POST, OPTIONS",
                },
              ));

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

  AddProject_Windows(BuildContext context, {@required projectname}) async {
    try {
      List<Map<String, dynamic>> lst = [
        {"projectname": projectname}
      ];

      var formData = FormData.fromMap({"projModel": lst});

      Response response = await Dio().post(
        "${GlobalVariables.SERVER_URL!}webapi/Project/AddProject",
        data: formData,
        options: Options(
          headers: {
            'content-Type': 'application/json',
            'Accept': 'application/text',
            "Access-Control-Allow-Origin": "*",
            // Required for CORS support to work
            "Access-Control-Allow-Credentials": true,
            // Required for cookies, authorization headers with HTTPS
            "Access-Control-Allow-Headers":
                "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
            "Access-Control-Allow-Methods": "GET, PUT, POST, OPTIONS",
          },
        ),
      );

      var lst_response = jsonDecode(response.toString());

      if (lst_response["msg"] != "Record saved successfully") {
        CustomAlertDialog.ShowAlertDialog(context, lst_response["msg"]);
      }

      if (lst_response["msg"] == "Record saved successfully") {
        CustomAlertDialog.ShowAlertDialog(context, lst_response["msg"]);
      }
    } catch (e) {
      CustomAlertDialog.ShowAlertDialog(context, e.toString());
    }
  }

  downloadProject(BuildContext context) async {
    try {
      var conResult = await Connectivity().checkConnectivity();

      if (conResult == ConnectivityResult.none) {
        CustomAlertDialog.ShowAlertDialog(
            context, "Please connect your device or enable WIFI");
      } else {
        Response response = await Dio().get(
          "${GlobalVariables.SERVER_URL}api/Project/downloadProject_Json",
          options: Options(
            contentType: "application/json",
            responseType: ResponseType.json,
          ),
          /*options: Options(
          headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods":
                "POST, GET, OPTIONS, PUT, DELETE, HEAD",
            "Access-Control-Allow-Headers":
                "custId, appId, Origin, Content-Type, Cookie, X-CSRF-TOKEN, Accept, Authorization, X-XSRF-TOKEN, Access-Control-Allow-Origin",
            "Access-Control-Expose-Headers": "Authorization, authenticated",
            "Access-Control-Allow-Credentials": "true",
          },
        ),*/
        );

        List<dynamic> lst = response.data;

        Database db = await DBProvider().initDb();
        await db.delete("project");

        for (int a = 0; a <= lst.length - 1; a++) {
          Map<String, dynamic> row = {
            "id": lst[a]["id"],
            "projectname": lst[a]["projectname"]
          };
          int id = await db.insert("project", row);
        }

        CustomAlertDialog.ShowAlertDialog(
            context, "Projects downloaded successfully");
      }
    } catch (e) {
      CustomAlertDialog.ShowAlertDialog(context, e.toString());
    }
  }

  downloadUsers(BuildContext context) async {
    try {
      var conResult = await Connectivity().checkConnectivity();

      if (conResult == ConnectivityResult.none) {
        CustomAlertDialog.ShowAlertDialog(
            context, "Please connect your device or enable WIFI");
      } else {
        Response response = await Dio().get(
          "${GlobalVariables.SERVER_URL}api/Project/downloadProject_Json",
          options: Options(
            contentType: "application/json",
            responseType: ResponseType.json,
          ),
        );

        List<dynamic> lst = response.data;

        Database db = await DBProvider().initDb();
        await db.delete("project");

        for (int a = 0; a <= lst.length - 1; a++) {
          Map<String, dynamic> row = {
            "id": lst[a]["id"],
            "projectname": lst[a]["projectname"]
          };
          int id = await db.insert("project", row);
        }

        CustomAlertDialog.ShowAlertDialog(
            context, "Projects downloaded successfully");
      }
    } catch (e) {
      CustomAlertDialog.ShowAlertDialog(context, e.toString());
    }
  }

  AddSample_Windows(BuildContext context, projectid, sampleid, imageurl) async {
    try {
      List<Map<String, dynamic>> lst = [
        {
          "projectid": projectid,
          "sampleid": sampleid,
          "userid": GlobalVariables.ENTRY_USER_ID,
          "entrydate": DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now()),
          "plateform": "desktop",
        }
      ];

      var formData = FormData.fromMap({"sampleEntryModel": lst});

      Response response = await Dio().post(
        "${GlobalVariables.SERVER_URL!}webapi/SampleEntry/AddSample_Windows",
        data: formData,
        options: Options(
          headers: {
            'content-Type': 'application/json',
            'Accept': 'application/text',
            "Access-Control-Allow-Origin": "*",
            // Required for CORS support to work
            "Access-Control-Allow-Credentials": true,
            // Required for cookies, authorization headers with HTTPS
            "Access-Control-Allow-Headers":
                "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
            "Access-Control-Allow-Methods": "GET, PUT, POST, OPTIONS",
          },
        ),
      );

      var lst_response = jsonDecode(response.toString());

      if (lst_response["msg"] != "Record saved successfully") {
        CustomAlertDialog.ShowAlertDialog(context, lst_response["msg"]);
      }

      if (lst_response["msg"] == "Record saved successfully") {
        CustomAlertDialog.ShowAlertDialog(context, lst_response["msg"]);
        UploadSampleEntryFiles(context);
      }
    } catch (e) {
      CustomAlertDialog.ShowAlertDialog(context, e.toString());
    }
  }

  UploadSampleEntryFiles(BuildContext context) async {
    try {
      CustomAlertDialog.ShowAlertDialog(
          context, "Files uploaded on the server");
    } catch (e) {
      CustomAlertDialog.ShowAlertDialog(context, e.toString());
    }
  }
}
