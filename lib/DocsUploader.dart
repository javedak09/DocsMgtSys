import 'dart:io';

//import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:docsmgtsys/DBProvider.dart';
import 'package:docsmgtsys/Model/ProjectModel.dart';
import 'package:docsmgtsys/Model/SampleEntryModel.dart';
import 'package:docsmgtsys/ProjectController.dart';
import 'package:docsmgtsys/ProjectEntry.dart';
import 'package:docsmgtsys/SampleController.dart';
import 'package:docsmgtsys/SearchSample.dart';
import 'package:docsmgtsys/login.dart';
import 'package:docsmgtsys/syncImages.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';

class DocsUploader extends StatelessWidget {
  // This widget is the root of your application.
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
          body: const HomePageState(),
        ),
      ),
    );
  }
}

enum ImageSourceType { gallery, camera }

class HomePageState extends StatefulWidget {
  const HomePageState({Key? key}) : super(key: key);

  @override
  HomePage createState() => new HomePage();
}

class HomePage extends State<HomePageState> {
  TextEditingController controller_projectID = new TextEditingController();
  TextEditingController controller_sampleID = new TextEditingController();
  TextEditingController controller_imgpath = new TextEditingController();

  late List<ProjectModel> lst_project;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  var focusNode = FocusNode();
  var _image;

  XFile? file;
  File? newFile;

  @override
  void initState() {
    super.initState();
    _getProjectData();
  }

  /*void _handleURLButtonPress(BuildContext context, var type) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ImageFromGalleryEx(type)));
  }*/

  void _submit() {
    if (this.formKey.currentState!.validate()) {
      _insert();
      saveFile();
    }
    //formKey.currentState.save();
  }

  _insert() async {
    // get a reference to the database
    // because this is an expensive operation we use async and await
    Database db = await DBProvider().initDb();

    // row to insert
    Map<String, dynamic> row = {
      "projectid": controller_projectID.text,
      "sampleid": controller_sampleID.text,
      "imgpath": controller_imgpath.text
    };

    // do the insert and get the id of the inserted row
    int id = await db.insert("sampleentry", row);

    // show the results: print all rows in the db
    print(await db.query("sampleentry"));

    showAlertDialog(context, "Record saved successfully");
  }

  _getData() async {
    Database db = await DBProvider().initDb();
    //Map<String, dynamic> lst = (await db.query("sampleentry")) as Map<String, dynamic>;
    //print(lst[0]);

    Future<List<SampleEntryModel>> lst = SampleController().getSamples();
    print(await db.query("sampleentry"));
  }

  void _getProjectData() async {
    Database db = await DBProvider().initDb();
    List lst = await db.query("project");
    List<ProjectModel>? lst1 = ProjectModel.fromJsonList(lst);

    setState(() {
      lst_project = lst1!;
    });

    //List lst = ProjectController().getProjects_All() as List;
    //Map<String, dynamic> test1 = ProjectModel().toMap();
  }

  Widget box(String title, Color backgroundcolor) {
    return Container(
        margin: EdgeInsets.all(10),
        width: 80,
        color: backgroundcolor,
        alignment: Alignment.center,
        child:
            Text(title, style: TextStyle(color: Colors.white, fontSize: 20)));
  }

  showAlertDialog(BuildContext context, String msg) {
    // set up the buttons
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        _clearField();
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert Dialog"),
      content: Text(msg),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _clearField() {
    formKey.currentState!.reset();
    controller_projectID.text = "";
    controller_sampleID.text = "";
    controller_imgpath.text = "";
  }

  changeText(String txt) {
    txt = "werwe";
  }

  _gotologin() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
  }

  _gotoSampleSearch() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SearchSample()));
  }

  _gotoCreateProject() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProjectEntry()));
  }

  Future saveFile() async {
    try {
      File resultFile = File(file!.path);

      final String newFileName =
          controller_projectID.text + "_" + controller_sampleID.text + ".jpg";

      var path = file!.path;
      var lastSeperator = path.lastIndexOf(Platform.pathSeparator);
      var newPath = path.substring(0, lastSeperator + 1) + newFileName;

      //Get this App Document Directory
      final Directory? _appDocDir = await getExternalStorageDirectory();
      //App Document Directory + folder name
      Directory _appDocDirFolder = Directory(
          '${_appDocDir!.path}/DCIM/docsmgtsys/' +
              controller_projectID.text +
              '/');

      if (await _appDocDirFolder.exists()) {
        //if folder already exists return path
      } else {
        //if folder not exists create folder and then return its path

        //final Directory _appDocDirNewFolder = await _appDocDirFolder.create(recursive: true);
        _appDocDirFolder = await _appDocDirFolder.create(recursive: true);
      }

      //File newFile = resultFile.renameSync(newPath);

      print(file!.path + " - " + newFile!.path);

      var arr = file!.path.split('/');

      arr = newFile!.path.split('/');

      newFile!.copySync(_appDocDirFolder.path + arr[6]);

      //file.saveTo(_appDocDir.path + "/docsmgtsys/docsmgtsys/" + arr[6]);

      //file.saveTo(_appDocDir.path + "/docsmgtsys/" + controller_imgpath.text);
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future getImage_Gallery() async {
    try {
      if (Platform.isAndroid) {
        file = await ImagePicker().pickImage(source: ImageSource.gallery);

        File resultFile = File(file!.path);

        controller_projectID.text = ProjectModel().projectname!;

        final String newFileName =
            controller_projectID.text + "_" + controller_sampleID.text + ".jpg";

        var path = file!.path;
        var lastSeperator = path.lastIndexOf(Platform.pathSeparator);
        var newPath = path.substring(0, lastSeperator + 1) + newFileName;

        newFile = resultFile.renameSync(newPath);

        //Get this App Document Directory
        final Directory? _appDocDir = await getExternalStorageDirectory();
        //App Document Directory + folder name

        Directory _appDocDirFolder =
            Directory('${_appDocDir!.path}/DCIM/docsmgtsys/');

        if (await _appDocDirFolder.exists()) {
          //if folder already exists return path
        } else {
          //if folder not exists create folder and then return its path

          //final Directory _appDocDirNewFolder = await _appDocDirFolder.create(recursive: true);
          _appDocDirFolder = await _appDocDirFolder.create(recursive: true);
        }

        var arr = newFile!.path.split('/');
        newFile!.copySync(_appDocDirFolder.path + arr[6]);

        setState(() {
//          _image = file.path;
          controller_imgpath.text = arr[6];
        });
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future getImage_Camera() async {
    try {
      if (Platform.isAndroid) {
        /*file = await ImagePicker().pickImage(source: ImageSource.camera);

        File resultFile = File(file.path);

        final String newFileName =
            controller_projectID.text + "_" + controller_sampleID.text + ".jpg";

        var path = file.path;
        var lastSeperator = path.lastIndexOf(Platform.pathSeparator);
        var newPath = path.substring(0, lastSeperator + 1) + newFileName;

        newFile = resultFile.renameSync(newPath);*/

        /*//Get this App Document Directory
        final Directory _appDocDir = await getExternalStorageDirectory();
        //App Document Directory + folder name

        Directory _appDocDirFolder =
            Directory('${_appDocDir.path}/DCIM/docsmgtsys/');

        if (await _appDocDirFolder.exists()) {
          //if folder already exists return path
        } else {
          //if folder not exists create folder and then return its path

          //final Directory _appDocDirNewFolder = await _appDocDirFolder.create(recursive: true);
          _appDocDirFolder = await _appDocDirFolder.create(recursive: true);
        }*/

        //var arr = newFile.path.split('/');
        //newFile.copySync(_appDocDirFolder.path + arr[6]);

        setState(() {
          //_image = file.path;
          //controller_imgpath.text = arr[6];
        });
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  _syncData() async {
    try {
      var request = new http.MultipartRequest(
          "POST",
          Uri.parse(
              "https://aku4.sharepoint.com/sites/PaedsResearch/default.aspx"));
      //request.fields['user'] = 'someone@somewhere.com';

      //request.files.add(http.MultipartFile.fromBytes('picture', File(newFile.path).readAsBytesSync()));

      request.send().then((response) {
        if (response.statusCode == 200)
          print("Uploaded!");
        else
          print(response);
      });

      //print(DioErrorType.response.toString());
    } catch (e) {
      print(e);
    }
  }

  saveProjectValue(ProjectModel projmodel) async {
    controller_projectID.text = projmodel.projectname!;
  }

/*_getImage(ImageSource source) async {
    var imageFile;

    final XFile file = await ImagePicker().pickImage(
        source: source, maxWidth: 640, maxHeight: 480, imageQuality: 70 //0-100
        );
    // getting a directory path for saving
    final Directory path = await getApplicationDocumentsDirectory();
    final String imgpath = path.path;
    // File temp = file as File;
    await file.saveTo('$imgpath');

    if (file?.path != null) {
      setState(() {
        imageFile = File(file.path);
        // imageFile = newImage;
      });
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showAlertDialog(context, "Back button is disabled");
        return false;
      },
      child: Form(
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
                  'Sample Entry',
                  style: TextStyle(fontSize: 20),
                )),
            /*Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                autofocus: true,
                focusNode: focusNode,
                controller: controller_projectID,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.isEmpty)
                    return "Project Name required";
                  else
                    return null;
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Project Name'),
              ),
            ),*/
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
              child: DropdownSearch<ProjectModel>(
                items: lst_project,
                mode: Mode.DIALOG,
                validator: (value) {
                  if (value == null) {
                    return "Project name required";
                  }
                },
                showSearchBox: true,
                onChanged: (ProjectModel? projmodel) {
                  saveProjectValue(projmodel!);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
              child: TextFormField(
                controller: controller_sampleID,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty)
                    return "Participant / Case ID required";
                  else
                    return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Participant / Case ID',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
              child: TextFormField(
                readOnly: true,
                controller: controller_imgpath,
                /*validator: (value) {
                  if (value.isEmpty)
                    return "Please select image to upload";
                  else
                    return null;
                },*/
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Sample Image',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              height: 60,
              child: ElevatedButton(
                child: Text(
                  "Pick Image from Gallery",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                onPressed: () {
                  getImage_Gallery();
                  //_handleURLButtonPress(context, ImageSourceType.gallery);
                },
              ),
            ),
            Container(
              height: 65,
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
              child: ElevatedButton(
                child: Text(
                  "Pick Image from Camera",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  getImage_Camera();
                  //_handleURLButtonPress(context, ImageSourceType.camera);
                },
              ),
            ),
            Container(
              height: 65,
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
              child: ElevatedButton(
                child: Text(
                  'Save Data',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _submit();
                },
              ),
            ),
            Container(
              height: 65,
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
              child: ElevatedButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: _clearField,
              ),
            ),
            Container(
              height: 65,
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
              child: ElevatedButton(
                child: const Text(
                  'Create Project',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _gotoCreateProject();
                },
              ),
            ),
            Container(
              height: 65,
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
              child: ElevatedButton(
                child: const Text(
                  'Search Sample',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _gotoSampleSearch();
                },
              ),
            ),
            Container(
              height: 65,
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
              child: ElevatedButton(
                child: const Text(
                  'Sync Data',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  //_syncData();
                  syncImages().getHttp();
                },
              ),
            ),
            Container(
              height: 65,
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
              child: ElevatedButton(
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _gotologin();
                },
              ),
            ),
            Container(
              height: 100,
              /*FutureBuilder<List<Data>>(
              future: -_getData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          height: 75,
                          color: Colors.white,
                          child: Center(
                            child: Text(snapshot.data![index].title),
                          ),
                        );
                      });
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                // By default show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),*/
            ),
          ],
        ),
      ),
    );
  }
}

/*class ImageFromGalleryEx extends StatefulWidget {
  final type;

  ImageFromGalleryEx(this.type);

  @override
  ImageFromGalleryExState createState() => ImageFromGalleryExState(this.type);
}

class ImageFromGalleryExState extends State<ImageFromGalleryEx> {
  var _image;
  var imagePicker;
  var type;

  ImageFromGalleryExState(this.type);

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    imagePicker = new ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(type == ImageSourceType.camera
              ? "Image from Camera"
              : "Image from Gallery")),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 52,
          ),
          Center(
            child: GestureDetector(
              onTap: () async {
                var source = type == ImageSourceType.camera
                    ? ImageSource.camera
                    : ImageSource.gallery;
                XFile image = await imagePicker.pickImage(
                    source: source,
                    imageQuality: 50,
                    preferredCameraDevice: CameraDevice.front);
                setState(() {
                  _image = File(image.path);
                });
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(color: Colors.red[200]),
                child: _image != null
                    ? Image.file(
                        _image,
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.fitHeight,
                      )
                    : Container(
                        decoration: BoxDecoration(color: Colors.red[200]),
                        width: 200,
                        height: 200,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }
}*/
