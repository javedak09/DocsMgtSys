import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:filesize/filesize.dart';

class InnerFolder extends StatefulWidget {
  InnerFolder({required this.filespath});

  final String filespath;

  @override
  State<StatefulWidget> createState() {
    return InnerFolderState();
  }
}

class InnerFolderState extends State<InnerFolder> {
  String get fileStr => widget.filespath;
  String var_filesize = "";

  Future<String> createFolderInAppDocDir(String folderName) async {
    //Get this App Document Directory

    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/$folderName/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  callFolderCreationMethod(String folderInAppDocDir) async {
    // ignore: unused_local_variable
    String actualFileName = await createFolderInAppDocDir(folderInAppDocDir);
    print(actualFileName);
    setState(() {});
  }

  final folderController = TextEditingController();
  late String nameOfFolder;

  /*Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Text(
                'ADD FOLDER',
                textAlign: TextAlign.left,
              ),
              Text(
                'Type a folder name to add',
                style: TextStyle(
                  fontSize: 14,
                ),
              )
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return TextField(
                controller: folderController,
                autofocus: true,
                decoration: InputDecoration(hintText: 'Enter folder name'),
                onChanged: (val) {
                  setState(() {
                    nameOfFolder = folderController.text;
                    print(nameOfFolder);
                  });
                },
              );
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (nameOfFolder != null) {
                  await callFolderCreationMethod(nameOfFolder);
                  getDir();
                  setState(() {
                    folderController.clear();
                    nameOfFolder = "";
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
            ElevatedButton(
              child: Text(
                'No',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }*/

  late List<FileSystemEntity> _folders;
  var foldername;

  Future<void> getDir() async {
    /* final directory = await getApplicationDocumentsDirectory();
    final dir = directory.path;
    String pdfDirectory = '$dir/';
    final myDir = new Directory(pdfDirectory);*/

    final myDir = new Directory(fileStr);

    var _folders_list = myDir.listSync(recursive: true, followLinks: false);

    setState(() {
      _folders = myDir.listSync(recursive: true, followLinks: false);
    });
    print(_folders);
  }

  /*Future<void> _showDeleteDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Are you sure to delete this folder?',
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Yes'),
              onPressed: () async {
                await _folders[index].delete();
                getDir();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }*/

  @override
  void initState() {
    _folders = [];
    getDir();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileStr.split('/').last +
            " - Files(" +
            _folders.length.toString() +
            ")"),
        /*actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showMyDialog();
            },
          ),
        ],*/
      ),
      body: GridView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 25,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return Material(
            elevation: 6.0,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder(
                        future: getFileType(_folders[index]),
                        builder: (ctx, snapshot) {
                          if (snapshot.hasData) {
                            FileStat f = snapshot.data! as FileStat;
                            var_filesize = filesize(f!.size);
                            print(
                                "file.stat() ${f!.type} - filesize - ${filesize(f!.size)}");
                            if (f!.type.toString().contains("file")) {
                              return Icon(
                                Icons.file_copy_outlined,
                                size: 100,
                                color: Colors.orange,
                              );
                            } else {
                              return InkWell(
                                onTap: () {
                                  final myDir =
                                      new Directory(_folders[index].path);

                                  var _folders_list = myDir.listSync(
                                      recursive: true, followLinks: false);

                                  for (int k = 0;
                                      k < _folders_list.length;
                                      k++) {
                                    var config = File(_folders_list[k].path);
                                    print("IsFile ${config is File}");
                                  }
                                  print(_folders_list);
                                },
                                child: Icon(
                                  Icons.folder,
                                  size: 100,
                                  color: Colors.orange,
                                ),
                              );
                            }
                          }
                          return Icon(
                            Icons.file_copy_outlined,
                            size: 100,
                            color: Colors.orange,
                          );
                        },
                      ),
                      Text('${_folders[index].path.split('/').last}'),
                      Text('${var_filesize}')
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      //_showDeleteDialog(index);
                    },
                    child: Icon(
                      Icons.delete,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          );
        },
        itemCount: _folders.length,
      ),
    );
  }

  Future getFileType(file) {
    return file.stat();
  }
}
