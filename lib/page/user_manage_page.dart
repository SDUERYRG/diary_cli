import 'dart:convert';

import 'package:diary_cli/components/constants.dart';
import 'package:diary_cli/entity/User.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserManagePage extends StatefulWidget {
  const UserManagePage({super.key});

  @override
  _UserManagePageState createState() => _UserManagePageState();
}

class _UserManagePageState extends State<UserManagePage> {
  late Future<List<User>> futureUsers;
  String _userId = '';
  String _userName = '';
  String _account = '';
  String _password = '';
  String _power = '用户'; // 默认用户权限
  String _confirmPassword = '';
  String _email = '';
  String _regTime = DateTime.now().toString();
  String _searchUserName = '';

  @override
  void initState() {
    super.initState();
    futureUsers = fetchAllUsers(1, 10); // 示例：查询第1页，每页10条记录
  }

  Future<void> _updateUser() async {
    final url = Uri.parse('http://192.168.1.5:4001/diary-server/updateUser');
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userId': _userId,
        'userName': _userName,
        'account': _account,
        'password': _password,
        'email': _email,
        'power': _power,
      }),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      setState(() {
        futureUsers = fetchAllUsers(1, 10);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('用户信息修改成功')),
      );
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to update user');
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Text('人员管理');
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
                  future: futureUsers,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('查询失败: ${snapshot.error}'));
                    } else {
                      final users = snapshot.data!;
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Container(
                                  // decoration: const BoxDecoration(color: Colors.white),
                                  child: const Text('用户管理'),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  initialValue: _searchUserName,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchUserName = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: '请输入用户名或账号或邮箱查询',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      futureUsers = fetchUsers(1, 10);
                                    });
                                  },
                                  child: const Text('搜索'),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return UnconstrainedBox(
                                              child: SizedBox(
                                            width: 1200,
                                            child: AlertDialog(
                                              title: const Text('添加用户'),
                                              content: Column(
                                                children: [
                                                  TextFormField(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _userName = value;
                                                      });
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            labelText: '用户名'),
                                                  ),
                                                  TextFormField(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _account = value;
                                                      });
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            labelText: '账号'),
                                                  ),
                                                  TextFormField(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _password = value;
                                                      });
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            labelText: '密码'),
                                                  ),
                                                  TextFormField(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _confirmPassword =
                                                            value;
                                                      });
                                                    },
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return '请再次输入密码';
                                                      }
                                                      if (value != _password) {
                                                        return '两次输入密码不一致';
                                                      }
                                                      return null;
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            labelText: '确认密码'),
                                                  ),
                                                  TextFormField(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _email = value;
                                                      });
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            labelText: '邮箱'),
                                                  ),
                                                  DropdownButtonFormField<
                                                      String>(
                                                    decoration:
                                                        const InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            labelText: '用户权限'),
                                                    value: _power,
                                                    items: <String>['用户', '管理员']
                                                        .map((String value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged: (value) {
                                                      // setState(() {
                                                      //   _power = '用户';
                                                      // });
                                                    },
                                                  ),
                                                  const SizedBox(height: 20),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      final url = Uri.parse(
                                                          'http://192.168.1.5:4001/diary-server/addUser');
                                                      final response =
                                                          await http.post(
                                                        url,
                                                        headers: <String,
                                                            String>{
                                                          'Content-Type':
                                                              'application/json; charset=UTF-8',
                                                        },
                                                        body:
                                                            jsonEncode(<String,
                                                                String>{
                                                          'userId':
                                                              (users.length + 1)
                                                                  .toString(),
                                                          'userName': _userName,
                                                          'account': _account,
                                                          'password': _password,
                                                          'email': _email,
                                                          'power': _power,
                                                          'regTime': _regTime,
                                                        }),
                                                      );
                                                      if (response.statusCode ==
                                                          200) {
                                                        print(
                                                            '注册成功: ${response.body}');
                                                        Navigator.of(context)
                                                            .pop(); // 关闭Dialog
                                                        setState(() {
                                                          futureUsers =
                                                              fetchAllUsers(1,
                                                                  10); // 刷新DataTable内容
                                                        });
                                                      } else {
                                                        print(
                                                            '注册失败: ${response.statusCode}');
                                                      }
                                                    },
                                                    child: const Text('提交'),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ));
                                        });
                                  },
                                  child: const Text('添加用户'),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                              child: DataTable(
                            columns: const [
                              DataColumn(label: Text("用户ID")),
                              DataColumn(label: Text("用户名")),
                              DataColumn(label: Text("账号")),
                              DataColumn(label: Text("邮箱")),
                              DataColumn(label: Text("权限")),
                              DataColumn(label: Text("性别")),
                              DataColumn(label: Text("头像")),
                              DataColumn(label: Text("                操作")),
                            ],
                            rows: List.generate(users.length, (index) {
                              final user = users[index];
                              return DataRow(cells: [
                                DataCell(Text(user.userId)),
                                DataCell(Text(user.userName)),
                                DataCell(Text(user.account)),
                                DataCell(Text(user.email)),
                                DataCell(Text(user.power)),
                                DataCell(Text(user.sex ?? 'N/A')),
                                DataCell(user.txPicture != null
                                    ? Image.network(user.txPicture!)
                                    : const Text('N/A')),
                                DataCell(Row(
                                  children: [
                                    ElevatedButton(
                                        onPressed: () async {
                                          final userId = users[index].userId;
                                          final url = Uri.parse(
                                              'http://192.168.1.5:4001/diary-server/$userId');
                                          final response =
                                              await http.delete(url);
                                          if (response.statusCode == 200) {
                                            setState(() {
                                              users.removeAt(index);
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
                                      onPressed: () {
                                        _userId = users[index].userId;
                                        _userName = users[index].userName;
                                        _account = users[index].account;
                                        _email = users[index].email;
                                        _power = users[index].power;
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return UnconstrainedBox(
                                              child: SizedBox(
                                                width: 1200,
                                                child: AlertDialog(
                                                  title: const Text('修改用户信息'),
                                                  content: Column(
                                                    children: [
                                                      TextFormField(
                                                        initialValue:
                                                            users[index]
                                                                .userName,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _userName = value;
                                                          });
                                                        },
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    '用户名'),
                                                      ),
                                                      TextFormField(
                                                        initialValue:
                                                            users[index]
                                                                .account,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _account = value;
                                                          });
                                                        },
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    '账号'),
                                                      ),
                                                      TextFormField(
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _password = value;
                                                          });
                                                        },
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    '密码'),
                                                      ),
                                                      TextFormField(
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _confirmPassword =
                                                                value;
                                                          });
                                                        },
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return '请再次输入密码';
                                                          }
                                                          if (value !=
                                                              _password) {
                                                            return '两次输入密码不一致';
                                                          }
                                                          return null;
                                                        },
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    '确认密码'),
                                                      ),
                                                      TextFormField(
                                                        initialValue:
                                                            users[index].email,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _email = value;
                                                          });
                                                        },
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    '邮箱'),
                                                      ),
                                                      DropdownButtonFormField<
                                                          String>(
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    '用户权限'),
                                                        value: _power,
                                                        items: <String>[
                                                          '用户',
                                                          '管理员'
                                                        ].map((String value) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _power = value!;
                                                          });
                                                        },
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      ElevatedButton(
                                                        onPressed: _updateUser,
                                                        child: const Text('提交'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: const Text("修改"),
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

  Future<List<User>> fetchAllUsers(int current, int pageSize) async {
    final url = Uri.parse(
        'http://192.168.1.5:4001/diary-server/all/$current/$pageSize');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final List<dynamic> data = responseBody['data']['records'];
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('查询失败: ${response.body}');
    }
  }

  Future<List<User>> fetchUsers(int current, int pageSize) async {
    final queryParameters = {
      'keyword': _searchUserName,
    };
    final uri = Uri.http('192.168.1.5:4001',
        'diary-server/search/$current/$pageSize', queryParameters);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final List<dynamic> data = responseBody['data']['records'];
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('查询失败: ${response.body}');
    }
  }
}
