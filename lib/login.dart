import 'dart:io';

import 'package:docsmgtsys/CustomAlertDialog.dart';
import 'package:docsmgtsys/syncronizationWork.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:docsmgtsys/CVars.dart';
import 'package:docsmgtsys/DBProvider.dart';
import 'package:docsmgtsys/LoginController.dart';
import 'package:docsmgtsys/RegisterUser.dart';
import 'package:docsmgtsys/SampleController.dart';
import 'package:docsmgtsys/SampleRegister.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Docs Management System';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: const MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => new _MyStatefulWidgetState();
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register User'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            Database? db = await DBProvider.internal().db;
            db?.rawInsert(
                "INSERT INTO users (userid, passwd) VALUES('user1', 'user1')");

            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController controller_userrole = TextEditingController();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  String btnText = "";

  var focusNode = FocusNode();

  List<String> lst_users = ["User", "Admin"];

  @override
  void initState() {
    super.initState();
  }

  _showUsers() async {
    // get a reference to the database
    // because this is an expensive operation we use async and await
    Database db = await DBProvider().initDb();

    // show the results: print all rows in the db
    print(await db.query("users"));
  }

  saveUserRole(GlobalVariables cvars) async {
    controller_userrole.text = cvars.userRole!;
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
                'Sign in',
                style: TextStyle(fontSize: 20),
              )),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: nameController,
              autofocus: true,
              focusNode: focusNode,
              validator: (value) {
                if (value!.isEmpty)
                  return "Username required";
                else
                  return null;
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'User Name'),
              style: new TextStyle(fontSize: 20),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
            child: TextFormField(
              obscureText: true,
              controller: passwordController,
              validator: (value) {
                if (value!.isEmpty)
                  return "Password required";
                else
                  return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              style: new TextStyle(fontSize: 20),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
            child: DropdownSearch<String>(
              items: lst_users,
              mode: Mode.DIALOG,
              validator: (value) {
                if (value == null) {
                  return "User Role required";
                }
              },
              showSearchBox: true,
            ),
          ),
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ElevatedButton(
              child: Text(
                'Login',
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
                'Register',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _registerUser();
                //_submit();
              },
            ),
          ),
        ],
      ),
    );
  }

  _registerUser() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterUser()));
  }

  void _login() async {
    final allRows = await LoginController()
        .getLogin(nameController.text, passwordController.text);

    if (allRows.length <= 0) {
      CustomAlertDialog.ShowAlertDialog(context, "User does not exist");
      FocusScope.of(context).requestFocus(focusNode);
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SampleRegister()));
      //allRows.forEach((row) => userArray.add(Users.fromMap(row)));
    }
  }

  void _login_windows() async {
    print("i m login windows");
    synchronizationWork().loginUser(context,
        userid: nameController.text, passwd: passwordController.text);
  }

  void _clearField() {
    nameController.text = "";
    passwordController.text = "";
    formKey.currentState!.reset();
  }

  void _submit() {
    if (this.formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (defaultTargetPlatform == TargetPlatform.android) {
        _login();
      } else {
        _login_windows();
      }
    }
  }

  changeText(String txt) {
    txt = "werwe";
  }
}
