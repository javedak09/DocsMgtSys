import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:docsmgtsys/DBProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'Model/SampleEntryModel.dart';

class syncImages {
  getSampleSync() async {
    try {
      Database db = await DBProvider().initDb();
      List lst = await db.query("sampleentry");
      //List<SampleEntryModel>? lst1 = SampleEntryModel.fromJsonList(lst);

      var response =
          Dio().post("http://CLS-PAE-FP60088/webapi/Home/SyncData", data: lst);

      /*var formData = FormData.fromMap({
      "id": lst1?[0].id,
      "projectid": lst1?[0].projectid,
      "sampleid": lst1?[0].sampleid,
    });*/
    } catch (e) {
      print(e.toString());
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

    final response = http
        .post(Uri.parse("http://cls-pae-fp60088/webapi/Privacy"), body: lst);
  }

  final String endPoint = 'http://10.0.2.2:8000/analyze';

  void _upload(File file) async {
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
  }

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
