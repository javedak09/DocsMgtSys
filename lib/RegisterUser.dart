import 'package:docsmgtsys/CustomAlertDialog.dart';
import 'package:flutter/material.dart';
import 'package:docsmgtsys/DBProvider.dart';
import 'package:docsmgtsys/login.dart';
import 'package:sqflite/sqflite.dart';

class RegisterUser extends StatelessWidget {
  const RegisterUser({Key? key}) : super(key: key);

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

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var focusNode = new FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

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
                'Register User',
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
            ),
          ),
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ElevatedButton(
              child: Text('Save Data', style: TextStyle(fontSize: 20)),
              onPressed: () {
                _submit();
              },
            ),
          ),
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ElevatedButton(
              child: const Text('Cancel', style: TextStyle(fontSize: 20)),
              onPressed: () {
                _clearField();
              },
            ),
          ),
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ElevatedButton(
              child: const Text('Login', style: TextStyle(fontSize: 20)),
              onPressed: () {
                _gotologin();
              },
            ),
          ),
        ],
      ),
    );
  }

  _gotologin() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => new MyApp()));
  }

  _submit() async {
    if (this.formKey.currentState!.validate()) {
      _registerUser();
    }
  }

  void _registerUser() async {
    // get a reference to the database
    // because this is an expensive operation we use async and await
    Database db = await DBProvider().initDb();

    // row to insert
    Map<String, dynamic> row = {
      "userid": nameController.text,
      "passwd": passwordController.text,
    };

    // do the insert and get the id of the inserted row
    int id = await db.insert("users", row);

    // show the results: print all rows in the db
    print(await db.query("users"));

    CustomAlertDialog.ShowAlertDialog(context, "Record saved successfully");
  }

  _clearField() async {
    nameController.clear();
    passwordController.clear();
    formKey.currentState!.reset();
  }
}
