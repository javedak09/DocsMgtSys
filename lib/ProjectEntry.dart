import 'package:docsmgtsys/CustomAlertDialog.dart';
import 'package:docsmgtsys/syncronizationWork.dart';
import 'package:flutter/material.dart';
import 'package:docsmgtsys/DBProvider.dart';
import 'package:docsmgtsys/ProjectController.dart';
import 'package:docsmgtsys/SampleRegister.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

class ProjectEntry extends StatelessWidget {
  const ProjectEntry({Key? key}) : super(key: key);

  static const String _title = 'Docs Management System';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: MaterialApp(
        title: _title,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(title: const Text(_title)),
          body: const MyStatefulWidget(),
        ),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => new _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  TextEditingController projectNameController = TextEditingController();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  String btnText = "";

  var focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  _insert() async {
    // get a reference to the database
    // because this is an expensive operation we use async and await
    Database db = await DBProvider().initDb();

    // row to insert
    Map<String, dynamic> row = {"projectname": projectNameController.text};

    // do the insert and get the id of the inserted row
    int id = await db.insert("project", row);

    // show the results: print all rows in the db
    print(await db.query("project"));

    CustomAlertDialog.ShowAlertDialog(context, "Record saved successfully");
    projectNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
          ),
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Project Entry',
                style: TextStyle(fontSize: 20),
              )),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: projectNameController,
              autofocus: true,
              focusNode: focusNode,
              validator: (value) {
                if (value!.isEmpty)
                  return "Project name required";
                else
                  return null;
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Project Name'),
            ),
          ),
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ElevatedButton(
              child: Text(
                'Save Data',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                //_showUsers();
                _submit();
              },
            ),
          ),
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ElevatedButton(
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: _clearField,
            ),
          ),
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ElevatedButton(
              child: Text(
                'Sample Entry',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _gotoSampleEntry();
              },
            ),
          ),
        ],
      ),
    );
  }

  _gotoSampleEntry() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => new SampleRegister()));
  }

  void _searchSampleID() async {
    final allRows =
        await ProjectController().getSampleInfo(projectNameController.text);

    if (allRows.length <= 0) {
      CustomAlertDialog.ShowAlertDialog(context, "Project does not exist");
      FocusScope.of(context).requestFocus(focusNode);
    } else {
      Database db = await DBProvider().initDb();
      print(await db.query("project"));
      //allRows.forEach((row) => userArray.add(Users.fromMap(row)));
    }
  }

  void _clearField() {
    formKey.currentState!.reset();
    projectNameController.text = "";
  }

  void _submit() {
    if (this.formKey.currentState!.validate()) {
      this.formKey.currentState!.save();
      if (defaultTargetPlatform == TargetPlatform.android) {
        _insert();
      } else {
        synchronizationWork()
            .AddProject(context, projectname: projectNameController.text);
      }
    }
  }
}
