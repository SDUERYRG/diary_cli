import 'dart:convert';
import 'dart:io';
import 'package:diary_cli/entity/Item.dart';
import 'package:diary_cli/components/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  String _host = '192.168.160.32';
  late Future<List<Item>> futureItems;
  String _itemId = '';
  String _itemName = '';
  String _picture = '';
  int _stock = 1;
  String _description = '';
  int _sell = 0;
  double _price = 0.0;
  double _discount = 1;
  int itemNum = 0;
  String _searchKeyword = '';

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
  String _path = '';
  @override
  void initState() {
    super.initState();
    _fileExtensionController
        .addListener(() => _extension = _fileExtensionController.text);
    futureItems = fetchAllItems(1, 100);
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
                      this.itemNum = items.length;
                      print(itemNum);
                      return ListView(
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
                                  initialValue: _searchKeyword,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchKeyword = value;
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
                                        futureItems = _searchKeyword == ''
                                            ? fetchAllItems(1, 100)
                                            : fetchItem(_searchKeyword, 1, 100);
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
                              DataColumn(label: Text("     图片")),
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
                                    ? GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Container(
                                                  width: 800,
                                                  height: 600,
                                                  child: Image.file(
                                                    File(
                                                        'D:/photos/itemImg/${item.picture!}'),
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Image.file(
                                          File(
                                              'D:/photos/itemImg/${item.picture!}'),
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.contain,
                                        ),
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
                                              'http://$_host:4001/diary-server/item/$itemId/$picture');
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
                                    ElevatedButton(
                                      child: Text("修改"),
                                      onPressed: () async {
                                        _itemId = item.itemId;
                                        _itemName = item.itemName;
                                        _picture = item.picture!;
                                        _stock = item.stock;
                                        _description = item.description;
                                        _sell = item.sell;
                                        _price = item.price;
                                        _discount = item.discount;
                                        showUpdateDialog(
                                            item, context, 'content');
                                      },
                                    )
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

  Future<List<Item>> fetchItem(
      String keyword, int current, int pageSize) async {
    final queryParameters = {
      'keyword': keyword,
    };
    final url = Uri.http('$_host:4001',
        '/diary-server/item/search/$current/$pageSize', queryParameters);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final List<dynamic> data = responseBody['data']['records'];
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('查询失败: ${response.body}');
    }
  }

  Future<List<Item>> fetchAllItems(int current, int pageSize) async {
    final url =
        Uri.parse('http://$_host:4001/diary-server/item/$current/$pageSize');
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
      this._path = _paths!.first.path!;
      this.file1 = File(this._path);
      // final Uint8List content = await this.file1!.readAsBytes();
      // print(content);
      // File newFile = File(newFilePath);
      // await newFile.writeAsBytes(content);
      return File(this._path);
    } else {
      print('No file selected');
      return File('');
    }
  }

  Future<void> addItem(File file) async {
    _itemId = (itemNum + 1).toString();
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://$_host:4001/diary-server/item'));

    // 添加文件
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    // 添加其他字段
    request.fields['itemId'] = _itemId;
    request.fields['itemName'] = _itemName;
    request.fields['picture'] = _picture;
    request.fields['stock'] = _stock.toString();
    request.fields['description'] = _description;
    request.fields['sell'] = _sell.toString();
    request.fields['price'] = _price.toString();
    request.fields['discount'] = _discount.toString();

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        // 处理成功响应
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonResponse = json.decode(responseString);
        print('Response: $jsonResponse');
      } else {
        // 处理错误响应
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> updateItem(Item item, File file) async {
    var request = http.MultipartRequest(
        'PUT', Uri.parse('http://$_host:4001/diary-server/item/updateItem'));
    request.files.add(await http.MultipartFile.fromPath('file', _path));
    request.fields['itemId'] = item.itemId;
    request.fields['itemName'] = _itemName;
    request.fields['picture'] = item.picture!;
    request.fields['stock'] = _stock.toString();
    request.fields['description'] = _description;
    request.fields['sell'] = _sell.toString();
    request.fields['price'] = _price.toString();
    request.fields['discount'] = _discount.toString();
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonResponse = json.decode(responseString);
        print('Response: $jsonResponse');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
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
                      Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 20),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          child: Container(
                            child: Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text("商品名称:",
                                      style: TextStyle(fontSize: 16)),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        _itemName = value;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          child: Container(
                            child: Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text("商品描述:",
                                      style: TextStyle(fontSize: 16)),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        _description = value;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          )),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 10),
                        child: Container(
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 1,
                                child: Text("商品价格:",
                                    style: TextStyle(fontSize: 16)),
                              ),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      _price = double.parse(value);
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 10),
                        child: Container(
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 1,
                                child: Text("商品库存:",
                                    style: TextStyle(fontSize: 16)),
                              ),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      _stock = int.parse(value);
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 10),
                        child: Container(
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 1,
                                child: Text("商品销量:",
                                    style: TextStyle(fontSize: 16)),
                              ),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      _sell = int.parse(value);
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text("商品图片：",
                                        style: TextStyle(fontSize: 16))),
                                Expanded(
                                  flex: 2,
                                  child:
                                      Builder(builder: (BuildContext context) {
                                    if (_path != '') {
                                      return Image.file(
                                        File(_path),
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.contain,
                                      );
                                    } else {
                                      return const Text('');
                                    }
                                  }),
                                )
                              ],
                            ),
                          )),
                      ElevatedButton(
                        child: const Text("选择图片"),
                        onPressed: () async {
                          state(() {
                            _pickFiles(state);
                          });
                        },
                      ),
                      ElevatedButton(
                        child: Text("确认添加"),
                        onPressed: () async {
                          // print(this.itemNum);
                          newFilePath =
                              'D:/photos/itemImg/photo${itemNum + 1}.jpg';
                          final Uint8List content =
                              await this.file1!.readAsBytes();
                          File newFile = File(newFilePath);
                          await newFile.writeAsBytes(content);
                          await addItem(file1!);
                          // Navigator.of(context).pop();
                        },
                      ),
                      Builder(builder: (BuildContext context) {
                        if (_isLoading == true) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          return Text("");
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

  Future<void> showUpdateDialog(
      Item item, BuildContext context, String content) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return UnconstrainedBox(
                child: SizedBox(
                  width: 500,
                  child: Dialog(
                    child: Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              "修改商品",
                              style: TextStyle(fontSize: 20),
                            )),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text("商品名称:",
                                      style: TextStyle(fontSize: 16)),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    initialValue: item.itemName,
                                    onChanged: (value) {
                                      setState(() {
                                        _itemName = value;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text("商品描述:",
                                      style: TextStyle(fontSize: 16)),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    initialValue: item.description,
                                    onChanged: (value) {
                                      setState(() {
                                        _description = value;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text("商品价格:",
                                      style: TextStyle(fontSize: 16)),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    initialValue: item.price.toString(),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == '') {
                                          _price = 0.0;
                                        } else
                                          _price = double.parse(value);
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text("商品库存:",
                                      style: TextStyle(fontSize: 16)),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    initialValue: item.stock.toString(),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == '') {
                                          _stock = 0;
                                        } else
                                          _stock = int.parse(value);
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text("商品销量:",
                                      style: TextStyle(fontSize: 16)),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    initialValue: item.sell.toString(),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == '') {
                                          _sell = 0;
                                        } else
                                          _sell = int.parse(value);
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10),
                            child: Container(
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text("商品图片：",
                                          style: TextStyle(fontSize: 16))),
                                  Expanded(
                                    flex: 4,
                                    child: Builder(
                                        builder: (BuildContext context) {
                                      _path =
                                          'D:/photos/itemImg/${item.picture}';
                                      if (_path != '') {
                                        return Image.file(
                                          File(_path),
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.contain,
                                        );
                                      } else {
                                        return const Text('');
                                      }
                                    }),
                                  )
                                ],
                              ),
                            )),
                        ElevatedButton(
                          child: const Text("选择图片"),
                          onPressed: () async {
                            setState(() {
                              _pickFiles(setState);
                            });
                          },
                        ),
                        ElevatedButton(
                          child: Text("确认修改"),
                          onPressed: () async {
                            file1 ??= File(_path);
                            newFilePath =
                                'D:/photos/itemImg/photo${itemNum + 1}.png';
                            final Uint8List content =
                                await this.file1!.readAsBytes();
                            File newFile = File(newFilePath);
                            await newFile.writeAsBytes(content);
                            await updateItem(item, file1!);
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}
