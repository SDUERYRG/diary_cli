import 'dart:convert';
import 'dart:io';
import 'package:diary_cli/entity/Item.dart';
import 'package:diary_cli/components/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  late Future<List<Item>> futureItems;
  String _searchItem = '';
  String _itemId = '';
  String _itemName = '';
  String _picture = '';
  int _stock = 1;
  String _description = '';
  int _sell = 0;
  double _price = 0.0;
  double _discount = 1;

  //文件相关
  String? _fileName;
  bool _isLoading = false;
  String? _directoryPath;
  List<PlatformFile>? _paths;
  bool _userAborted = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _dialogTitleController = TextEditingController();
  final _initialDirectoryController = TextEditingController();
  FileType _pickingType = FileType.any;
  final _fileExtensionController = TextEditingController();
  String? _extension;
  String? _saveAsFileName;
  String newFilePath = 'D:/photos/itemImg/photo1.png';
  File? file1;
  @override
  void initState() {
    super.initState();
    _fileExtensionController
        .addListener(() => _extension = _fileExtensionController.text);
    futureItems = fetchAllItems(1, 10);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 200,
      child: Column(
        children: [
          Expanded(
              //header部分
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    //header左
                    flex: 3,
                    child: Container(
                        // decoration:
                        //     const BoxDecoration(color: Colors.white),

                        ),
                  ),
                  Expanded(
                      //头像部分
                      flex: 1,
                      child: SizedBox(
                        height: 70,
                        width: 70,
                        child: Container(
                          width: 70,
                          decoration:
                              const BoxDecoration(color: secondaryColor),
                        ),
                      ))
                ],
              )),
          Expanded(
              flex: 4,
              child: FutureBuilder(
                  future: futureItems,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('查询失败: ${snapshot.error}'));
                    } else {
                      final items = snapshot.data!;
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Container(
                                  child: const Text("商品管理"),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  initialValue: _searchItem,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchItem = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "请输入商品名称",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        futureItems = fetchAllItems(1, 10);
                                      });
                                    },
                                    child: const Text("查询")),
                              ),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showMyDialog(context, "添加商品", "content");
                                  },
                                  child: Text("添加"),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              child: DataTable(
                            columns: const [
                              DataColumn(label: Text("商品ID")),
                              DataColumn(label: Text("商品名")),
                              DataColumn(label: Text("图片")),
                              DataColumn(label: Text("库存")),
                              DataColumn(label: Text("描述")),
                              DataColumn(label: Text("销量")),
                              DataColumn(label: Text("价格")),
                              DataColumn(label: Text("折扣")),
                              DataColumn(label: Text("                操作")),
                            ],
                            rows: List.generate(items.length, (index) {
                              final item = items[index];
                              return DataRow(cells: [
                                DataCell(Text(item.itemId)),
                                DataCell(Text(item.itemName)),
                                DataCell(item.picture != null
                                    ? Image.file(
                                        File(
                                            'D:/photos/itemImg/${item.picture!}'),
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.contain,
                                      )
                                    : const Text('N/A')),
                                DataCell(Text(item.stock.toString())),
                                DataCell(Text(item.description)),
                                DataCell(Text(item.sell.toString())),
                                DataCell(Text(item.price.toString())),
                                DataCell(Text(item.discount.toString())),
                                DataCell(Row(
                                  children: [
                                    ElevatedButton(
                                        onPressed: () async {
                                          final itemId = items[index].itemId;
                                          String picture = 'photo$itemId.png';
                                          final url = Uri.parse(
                                              'http://192.168.1.5:4001/diary-server/item/$itemId/$picture');
                                          final response =
                                              await http.delete(url);
                                          if (response.statusCode == 200) {
                                            setState(() {
                                              items.removeAt(index);
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content:
                                                      Text('删除成功(●\'◡\'●)')),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text('删除失败，请重试')),
                                            );
                                          }
                                        },
                                        child: const Text("删除")),
                                  ],
                                ))
                              ]);
                            }),
                          )),
                        ],
                      );
                    }
                  }))
        ],
      ),
    );
  }

  Future<List<Item>> fetchAllItems(int current, int pageSize) async {
    final url = Uri.parse(
        'http://192.168.1.5:4001/diary-server/item/$current/$pageSize');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final List<dynamic> data = responseBody['data']['records'];
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('查询失败: ${response.body}');
    }
  }

  void _resetState(StateSetter state) {
    if (!mounted) {
      return;
    }
    state(() {
      _isLoading = true;
      _directoryPath = null;
      _fileName = null;
      _paths = null;
      _saveAsFileName = null;
      _userAborted = false;
    });
  }

  Future<String> readFileAsString(String path) async {
    final file = File(path);
    String fileContent = '';
    try {
      Stream<List<int>> inputStream = file.openRead();

      await for (var line
          in inputStream.transform(utf8.decoder).transform(LineSplitter())) {
        fileContent += line + '\n';
      }
    } catch (e) {
      print('Error: $e');
    }
    return fileContent;
  }

  Future<File> _pickFiles(StateSetter state) async {
    _resetState(state);
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        compressionQuality: 30,
        type: _pickingType,
        onFileLoading: (FilePickerStatus status) => print(status),
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
        dialogTitle: _dialogTitleController.text,
        initialDirectory: _initialDirectoryController.text,
      ))
          ?.files;
    } on PlatformException catch (e) {
      print('Unsupported operation' + e.toString());
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return File('');
    state(() {
      _isLoading = false;
    });
    if (_paths != null && _paths!.isNotEmpty) {
      print('Selected file path: ${_paths!.first.path}');
      final String path1 = _paths!.first.path!;
      this.file1 = File(path1);
      // final Uint8List content = await this.file1!.readAsBytes();
      // print(content);
      // File newFile = File(newFilePath);
      // await newFile.writeAsBytes(content);
      return File(path1);
    } else {
      print('No file selected');
      return File('');
    }
  }

  Future<void> showMyDialog(
      BuildContext context, String title, String content) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, state) {
            return UnconstrainedBox(
              child: SizedBox(
                width: 500,
                child: Dialog(
                  child: Column(
                    children: [
                      // Padding(
                      //     padding: const EdgeInsets.all(20.0),
                      //     child: Text(
                      //       title,
                      //       style: const TextStyle(fontSize: 20),
                      //     )),
                      // Padding(
                      //   padding:
                      //       const EdgeInsets.only(left: 20, right: 20, top: 10),
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       setState(() {
                      //         _itemName = value;
                      //       });
                      //     },
                      //     decoration: const InputDecoration(
                      //       labelText: "商品名称",
                      //       border: OutlineInputBorder(),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding:
                      //       const EdgeInsets.only(left: 20, right: 20, top: 10),
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       setState(() {
                      //         _description = value;
                      //       });
                      //     },
                      //     decoration: const InputDecoration(
                      //       labelText: "商品描述",
                      //       border: OutlineInputBorder(),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding:
                      //       const EdgeInsets.only(left: 20, right: 20, top: 10),
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       setState(() {
                      //         _price = double.parse(value);
                      //       });
                      //     },
                      //     decoration: const InputDecoration(
                      //       labelText: "商品价格",
                      //       border: OutlineInputBorder(),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding:
                      //       const EdgeInsets.only(left: 20, right: 20, top: 10),
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       setState(() {
                      //         _stock = int.parse(value);
                      //       });
                      //     },
                      //     decoration: const InputDecoration(
                      //       labelText: "商品库存",
                      //       border: OutlineInputBorder(),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding:
                      //       const EdgeInsets.only(left: 20, right: 20, top: 10),
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       setState(() {
                      //         _discount = double.parse(value);
                      //       });
                      //     },
                      //     decoration: const InputDecoration(
                      //       labelText: "商品折扣",
                      //       border: OutlineInputBorder(),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding:
                      //       const EdgeInsets.only(left: 20, right: 20, top: 10),
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       setState(() {
                      //         _picture = value;
                      //       });
                      //     },
                      //     decoration: const InputDecoration(
                      //       labelText: "商品图片",
                      //       border: OutlineInputBorder(),
                      //     ),
                      //   ),
                      // ),
                      ElevatedButton(
                        child: Text("上传图片"),
                        onPressed: () async {
                          state(() {
                            _pickFiles(state);
                          });
                        },
                      ),
                      Builder(builder: (BuildContext context) {
                        if (_isLoading == true) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          return Text("data");
                        }
                      }),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }
}
