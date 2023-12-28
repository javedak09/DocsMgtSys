import 'dart:io';

import 'package:dio/dio.dart';
import 'package:docsmgtsys/CustomAlertDialog.dart';
import 'package:docsmgtsys/DBProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;

class syncImages {
  syncSampleEntryModel(BuildContext context) async {
    try {
      Database db = await DBProvider().initDb();
      List<Map<String, dynamic>> lst = await db.query("sampleentry");

      //Map<String, dynamic> lst1 = SampleEntryModel().toMap();

      var formData = FormData.fromMap({"sampleEntrymodel": lst});

      /*var response = Dio().post(
          "http://CLS-PAE-FP60088:81/webapi/Home/SyncData",
          data: formData);*/

      syncSampleEntryFiles(context);
    } catch (e) {
      print(e.toString());
      CustomAlertDialog.ShowAlertDialog(context, e.toString());
    }
  }

  syncSampleEntryFiles(BuildContext context) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
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
      }

      FTPConnect ftpConnect = new FTPConnect("CLS-PAE-FP60088",
          user: "support.jk", pass: "Dellpro.1903", port: 21);
      await ftpConnect.connect();
      // await ftpConnect.changeDirectory("webapi");
      await ftpConnect.uploadFile(File("\\0\\sdcard\\DCIM\\docsmgtsys\\"));
      await ftpConnect.disconnect();
    } catch (e) {
      print(e.toString());
      CustomAlertDialog.ShowAlertDialog(context, e.toString());
    }
  }

  Future<void> syncDataHttp() async {
    var lst = new Map<String, dynamic>();
    lst["id"] = "1";
    lst["projectid"] = "1";
    lst["sampleid"] = "1";

    /*var request = new http.MultipartRequest(
        "POST", Uri.parse("http://cls-pae-fp60088/webapi/Privacy"));

        http.Response response1 =
        await http.Response.fromStream(await request.send());
     */

    final response = http.post(
        Uri.parse("http://cls-pae-fp60088:81/webapi/Home/SyncData"),
        body: lst);
  }

  //final String endPoint = 'http://10.0.2.2:8000/analyze';

  /*void _upload(File file) async {
    String fileName = file.path.split('/').last;
    print(fileName);

    FormData data = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    Dio dio = new Dio();

    dio.post(endPoint, data: data).then((response) {
      var jsonResponse = jsonDecode(response.toString());
      var testData = jsonResponse['histogram_counts'].cast<double>();
      var averageGrindSize = jsonResponse['average_particle_size'];
    }).catchError((error) => print(error));
  }*/

  getHttp() async {
    try {
      //FormData data = FormData.fromMap({"id": "1", "projectid": "1", "sampleid": "1"});

      var response = await Dio().get('http://CLS-PAE-FL73255/webapi/sync.php');

      print(response.statusCode.toString() +
          " - " +
          response.statusMessage.toString());

      /*dio.post("http://cls-pae-fl73255/webapi/testphp.php", data: data).then((response) {
        var jsonResponse = jsonDecode(response.toString());
        //var testData = jsonResponse['histogram_counts'].cast<double>();
        //var averageGrindSize = jsonResponse['average_particle_size'];

        //print("i m data    --> " + response.data);
      }).catchError((error) => print(error));*/
    } catch (e) {
      print(e);
    }
  }
}
