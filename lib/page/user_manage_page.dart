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
  @override
  void initState() {
    super.initState();
    futureUsers = fetchAllUsers(1, 10); // 示例：查询第1页，每页10条记录
  }

  @override
  Widget build(BuildContext context) {
    // return Text('人员管理');
    return FutureBuilder(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('查询失败: ${snapshot.error}'));
          } else {
            final users = snapshot.data!;
            return Container(
                //最外层
                width: MediaQuery.of(context).size.width - 200,
                // decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  //最外层
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
                                    decoration: const BoxDecoration(
                                        color: secondaryColor),
                                  ),
                                ))
                          ],
                        )),
                    Expanded(
                      //body部分
                      flex: 4,
                      child: SizedBox(
                          child: DataTable(
                        columns: const [
                          DataColumn(label: Text("用户名")),
                          DataColumn(label: Text("账号")),
                          DataColumn(label: Text("邮箱")),
                          DataColumn(label: Text("权限")),
                          DataColumn(label: Text("性别")),
                          DataColumn(label: Text("头像")),
                        ],
                        rows: List.generate(users.length, (index) {
                          final user = users[index];
                          return DataRow(cells: [
                            DataCell(Text(user.userName)),
                            DataCell(Text(user.account)),
                            DataCell(Text(user.email)),
                            DataCell(Text(user.power)),
                            DataCell(Text(user.sex ?? 'N/A')),
                            DataCell(user.txPicture != null
                                ? Image.network(user.txPicture!)
                                : const Text('N/A')),
                          ]);
                        }),
                      )),
                    ),
                  ],
                ));
          }
        });
  }

  // Future<void> fetchUsers(int current, int pageSize) async {
  //   final url = Uri.parse(
  //       'http://192.168.1.5:4001/diary-server/all/$current/$pageSize');
  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     final responseBody = jsonDecode(response.body);
  //     // 处理响应数据
  //     print(response.body);
  //     print('查询成功: ${responseBody['data']}');
  //   } else {
  //     print('查询失败: ${response.body}');
  //   }
  // }
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
}
