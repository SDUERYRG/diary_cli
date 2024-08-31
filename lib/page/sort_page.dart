import 'dart:convert';

import 'package:diary_cli/SharedPre.dart';
import 'package:diary_cli/components/constants.dart';
import 'package:diary_cli/entity/Sort.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SortPage extends StatefulWidget {
  @override
  _SortPageState createState() => _SortPageState();
}

class _SortPageState extends State<SortPage> {
  String _host = '192.168.160.32';
  String _searchUserName = '';
  late Future<List<Sort>> futureSorts;
  String _sortId = '';
  String _sortName = '';
  String _itemName = '';
  @override
  void initState() {
    super.initState();
    futureSorts = fetchSort();
  }

  Future<List<Sort>> fetchSort() async {
    final header = {
      'token': SharedPre.getToken().toString(),
    };
    final url = Uri.parse('http://$_host:4001/diary-server/sort/0/100');
    try {
      final response = await http.get(url, headers: header);
      final responseBody = jsonDecode(response.body);
      print(response.body);
      if (responseBody['status'] == true) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody['data']['records'];
        print('获取到data');
        return data.map((json) => Sort.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sort');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load sort');
    }
  }

  Future<void> addSort(Sort sort) async {
    final header = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'token': SharedPre.getToken().toString(),
    };
    final url = Uri.parse('http://$_host:4001/diary-server/sort');
    final response = await http.post(url,
        headers: header,
        body: jsonEncode(<String, String>{
          'sortId': sort.sortId,
          'sortName': sort.sortName,
          'itemName': sort.itemName,
        }));
    print(response.body);
    final responseBody = jsonDecode(response.body);
    if (responseBody['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('添加成功(●\'◡\'●)')),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('添加失败≡(▔﹏▔)≡')));
      throw Exception('Failed to add sort');
    }
  }

  Future<void> deleteSort(String sortId) async {
    final header = {
      'token': SharedPre.getToken().toString(),
    };
    final url = Uri.parse('http://$_host:4001/diary-server/sort/$sortId');
    final response = await http.delete(url, headers: header);
    print(response.body);
    final responseBody = jsonDecode(response.body);
    if (responseBody['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('删除成功(●\'◡\'●)')),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('删除失败≡(▔﹏▔)≡')));

      throw Exception('Failed to delete sort');
    }
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
                    child: Container(),
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
                future: futureSorts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('查询失败: ${snapshot.error}'));
                  } else {
                    final sorts = snapshot.data!;
                    return ListView(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Container(
                                // decoration: const BoxDecoration(color: Colors.white),
                                child: const Text('分类管理'),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: _searchUserName,
                                onChanged: (value) {
                                  setState(() {
                                    _searchUserName = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: '请输入分类名',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // setState(() {
                                  //   futureUsers = fetchUsers(1, 10);
                                  // });
                                },
                                child: const Text('搜索'),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return UnconstrainedBox(
                                          child: SizedBox(
                                            width: 1200,
                                            child: AlertDialog(
                                              title: const Text('添加分类'),
                                              content: Column(
                                                children: [
                                                  TextField(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _sortId =
                                                            value.toString();
                                                      });
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      labelText: '分类Id',
                                                    ),
                                                  ),
                                                  TextField(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _sortName = value;
                                                      });
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      labelText: '分类名',
                                                    ),
                                                  ),
                                                  TextField(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _itemName = value;
                                                      });
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      labelText: '商品名',
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      await addSort(Sort(
                                                          sortId: _sortId,
                                                          sortName: _sortName,
                                                          itemName: _itemName));
                                                      setState(() {
                                                        futureSorts =
                                                            fetchSort();
                                                      });
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('确定'),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: const Text('添加'),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('分类Id')),
                              DataColumn(label: Text('分类名')),
                              DataColumn(label: Text('商品id')),
                              DataColumn(label: Text('商品名')),
                              DataColumn(label: Text('操作')),
                            ],
                            rows: List.generate(sorts.length, (index) {
                              final sort = sorts[index];
                              return DataRow(cells: [
                                DataCell(Text(sort.sortId)),
                                DataCell(Text(sort.sortName)),
                                DataCell(Text(sort.itemId.toString())),
                                DataCell(Text(sort.itemName)),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        await deleteSort(sort.sortId);
                                        setState(() {
                                          sorts.removeAt(index);
                                        });
                                        setState(() {
                                          futureSorts = fetchSort();
                                        });
                                      },
                                    )
                                  ],
                                ))
                              ]);
                            }),
                          ),
                        )
                      ],
                    );
                  }
                }),
          )
        ],
      ),
    );
  }

  ThemeMode themeMode = ThemeMode.system;
  bool get useLightMode {
    switch (themeMode) {
      case ThemeMode.system:
        return MediaQuery.platformBrightnessOf(context) == Brightness.light;

      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
    }
  }
}
