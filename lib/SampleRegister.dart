import 'dart:io';
import 'dart:typed_data';

//import 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:docsmgtsys/ViewFiles.dart';
import 'package:docsmgtsys/test.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:docsmgtsys/DBProvider.dart';
import 'package:docsmgtsys/Model/ProjectModel.dart';
import 'package:docsmgtsys/Model/SampleEntryModel.dart';
import 'package:docsmgtsys/ProjectController.dart';
import 'package:docsmgtsys/ProjectEntry.dart';
import 'package:docsmgtsys/SampleController.dart';
import 'package:docsmgtsys/SearchSample.dart';
import 'package:docsmgtsys/login.dart';
import 'package:docsmgtsys/syncImages.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';

/*void main() {
  runApp(MyApp());
}*/

class SampleRegister extends StatelessWidget {
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

  late List<ProjectModel> lst_project = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  var focusNode = FocusNode();
  var _image;

  FilePickerResult? result;
  String? fileName;
  PlatformFile? pickedFile, pickedFile_new;
  String? UploadFilePath;

  //XFile file;
  File? fileToDisplay, fileToDisplay_new;

  get ext => null;

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
      saveFilePermanently();
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
      "sampleid": controller_sampleID.text
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

  _viewFiles() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ViewFiles()));
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

  Future saveFilePermanently() async {
    try {
      if (Platform.isAndroid) {
        final Directory? appDocDir = await getExternalStorageDirectory();

        var arr = appDocDir!.path.split('/');

        Directory? appDocDirFolder = Directory(arr[0] +
            "/" +
            arr[1] +
            "/" +
            arr[2] +
            "/" +
            arr[3] +
            '/DCIM/docsmgtsys/${controller_projectID.text}/');

        var arr1 = pickedFile!.path!.split('/');

        if (await appDocDirFolder.exists()) {
          //if folder already exists return path
        } else {
          //if folder not exists create folder and then return its path

          //final Directory _appDocDirNewFolder = await _appDocDirFolder.create(recursive: true);
          appDocDirFolder = await appDocDirFolder.create(recursive: true);
        }

        var ext;
        if (arr1[7].indexOf('.') != -1) {
          ext = arr1[7].split('.');

          print(pickedFile_new!.path! +
              " - " +
              appDocDirFolder.path +
              ext![1] +
              " - " +
              fileToDisplay!.path);

          File(pickedFile!.path!).copySync(appDocDirFolder.path +
              controller_projectID.text +
              "_" +
              controller_sampleID.text +
              "." +
              ext[1]);
        } else {
          print(pickedFile_new!.path! +
              " - " +
              appDocDirFolder.path +
              " - " +
              fileToDisplay!.path);

          File(pickedFile!.path!).copySync(appDocDirFolder.path +
              controller_projectID.text +
              "_" +
              controller_sampleID.text);
        }

        UploadFilePath = appDocDirFolder.path +
            controller_projectID.text +
            "_" +
            controller_sampleID.text +
            "." +
            ext[1];

        syncData();

        //fileToDisplay!.copySync(appDocDirFolder.path + controller_imgpath.text);

        //final file = await File(pickedFile.path + '/Traders/Report').create(recursive: true);
        //file.writeAsStringSync("Hello I'm writting a stackoverflow answer into you");

        //newFile.copySync(_appDocDirFolder.path + arr[7]);

        /*String outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Please select an output file:',
          fileName: controller_imgpath.text,
        );

        if (outputFile == null) {
          // User canceled the picker
        }*/
      } else {}
    } catch (e) {
      showAlertDialog(context, e.toString());
      print(e.toString());
    }
  }

  Future saveFilePermanently_working() async {
    try {
      if (Platform.isAndroid) {
        final Directory? appDocDir = await getExternalStorageDirectory();

        Directory? appDocDirFolder = Directory(
            '${appDocDir!.path}/DCIM/docsmgtsys/${controller_projectID.text}/');

        if (await appDocDirFolder.exists()) {
          //if folder already exists return path
        } else {
          //if folder not exists create folder and then return its path

          //final Directory _appDocDirNewFolder = await _appDocDirFolder.create(recursive: true);
          appDocDirFolder = await appDocDirFolder.create(recursive: true);
        }

        var arr = pickedFile?.path!.split('/');

        print(pickedFile!.path! +
            " - " +
            appDocDirFolder.path +
            arr![7] +
            " - " +
            fileToDisplay!.path);

        //File(pickedFile!.path!).copySync(appDocDirFolder.path + fileName!);

        fileToDisplay!.copySync(appDocDirFolder.path + fileName!);

        //final file = await File(pickedFile.path + '/Traders/Report').create(recursive: true);
        //file.writeAsStringSync("Hello I'm writting a stackoverflow answer into you");

        //newFile.copySync(_appDocDirFolder.path + arr[7]);

        /*String outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Please select an output file:',
          fileName: controller_imgpath.text,
        );

        if (outputFile == null) {
          // User canceled the picker
        }*/
      }
    } catch (e) {
      showAlertDialog(context, e.toString());
      print(e.toString());
    }
  }

  Future getDocs_Gallery() async {
    try {
      if (Platform.isAndroid) {
        result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowMultiple: false,
            allowedExtensions: [
              "jpg",
              "jpeg",
              "png",
              "doc",
              "docx",
              "xls",
              "xlsx",
              "mp4",
              "mp3",
              "avi",
              "pdf",
              "txt"
            ]);

        if (result != null) {
          fileName = result!.files.first.name;
          pickedFile = result!.files.first;
          pickedFile_new = result!.files.first;
          fileToDisplay = File(pickedFile_new!.path.toString());

          var arr = fileToDisplay!.path.split("/");

          var ext;

          if (arr[7].indexOf('.') != -1) {
            ext = arr[7].split('.');

            controller_imgpath.text = controller_projectID.text +
                "_" +
                controller_sampleID.text +
                "." +
                ext[1];

            var dir = await getExternalStorageDirectory();
            var arr_dir = dir!.path.split('/');

            fileToDisplay_new = File(arr_dir[0] +
                "/" +
                arr_dir[1] +
                "/" +
                arr_dir[2] +
                "/" +
                arr_dir[3] +
                "/DCIM/" +
                controller_projectID.text +
                "/" +
                controller_projectID.text +
                "_" +
                controller_sampleID.text +
                "." +
                ext[1]);
          } else {
            controller_imgpath.text =
                controller_projectID.text + "_" + controller_sampleID.text;

            var dir = await getExternalStorageDirectory();
            var arr_dir = dir!.path.split('/');

            fileToDisplay_new = File(arr_dir[0] +
                "/" +
                arr_dir[1] +
                "/" +
                arr_dir[2] +
                "/" +
                arr_dir[3] +
                "/DCIM/" +
                controller_projectID.text +
                "/" +
                controller_projectID.text +
                "_" +
                controller_sampleID.text);
          }
        } else {
          // User canceled the picker
        }
      }
    } catch (e) {
      showAlertDialog(context, e.toString());
      print(e.toString());
    }
  }

  Future getDocs_Gallery_working() async {
    try {
      if (Platform.isAndroid) {
        result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowMultiple: false,
            allowedExtensions: [
              "jpg",
              "jpeg",
              "png",
              "doc",
              "docx",
              "xls",
              "xlsx",
              "mp4",
              "mp3",
              "avi",
              "pdf",
              "txt"
            ]);

        if (result != null) {
          fileName = result!.files.first.name;
          pickedFile = result!.files.first;
          fileToDisplay = File(pickedFile!.path.toString());

          var arr = fileToDisplay!.path.split("/");
          controller_imgpath.text = arr[7];
        } else {
          // User canceled the picker
        }
      }
    } catch (e) {
      showAlertDialog(context, e.toString());
      print(e.toString());
    }
  }

  /*Future getDocs_Gallery() async {
    try {
      if (Platform.isAndroid) {
        result = await FilePicker.platform.pickFiles(
            dialogTitle: "Please select file", allowCompression: true);

        docFile = result.files.first;

        controller_projectID.text = ProjectModel().projectname;

        var ext = result.files.first.name.split('.');

        final String newFileName = controller_projectID.text +
            "_" +
            controller_sampleID.text +
            "." +
            ext[1];

        setState(() {
          controller_imgpath.text = newFileName;
        });
      }
    } catch (e) {
      showAlertDialog(context, e.toString());
      print(e.toString());
    }
  }*/

  _syncData() async {
    try {
      var request = new http.MultipartRequest(
          "POST",
          Uri.parse(
              "https://aku4.sharepoint.com/sites/PaedsResearch/default.aspx"));
      //request.fields['user'] = 'someone@somewhere.com';

      request.files.add(http.MultipartFile.fromBytes(
          'picture', File(pickedFile!.path!).readAsBytesSync()));

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

  void syncData() async {
    final dio = Dio();

    String fileName = controller_imgpath.text.split('/').last;

    /*FormData formData = FormData.fromMap({
      "image-param-name": await MultipartFile.fromFile(
        controller_imgpath.text,
        filename: fileName,
        contentType: new MediaType("image", "jpeg"), //important
      ),
    });*/

    FormData formData = FormData.fromMap({
      "tabdataid": "1",
      "projectid": controller_projectID.text,
      "sampleid": controller_sampleID.text,
      "img_file":
          await MultipartFile.fromFile(UploadFilePath!, filename: fileName),
    });

    final response = await dio
        .post('http://cls-pae-fp60088/webapi/Home/Privacy', data: formData);

    //final response = await dio.get('http://cls-pae-fp60088/webapi/Home/Privacy');

    print(response.data);

    /*return (json.decode(response.body)['data'] as List)
        .map((e) => SampleEntryModel.fromJson(e))
        .toList();*/
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
                    return "Participant ID (Unique identification number) required";
                  else
                    return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Participant ID (Unique identification number)',
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
                  labelText: 'Participant Document',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              height: 60,
              child: ElevatedButton(
                child: Text(
                  "Pick Any file from Gallery",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                onPressed: () {
                  getDocs_Gallery();
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
                  getDocs_Gallery();
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
                  'View Files',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _viewFiles();
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
                  //syncImages().getSampleSync();
                  syncData();
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
