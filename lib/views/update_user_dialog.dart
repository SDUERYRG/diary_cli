import 'dart:convert';

import 'package:diary_cli/entity/User.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateUserDialog extends StatefulWidget {
  final User user;
  final Function(User) onUpdate;

  UpdateUserDialog({required this.user, required this.onUpdate});

  @override
  _UpdateUserDialogState createState() => _UpdateUserDialogState();
}

class _UpdateUserDialogState extends State<UpdateUserDialog> {
  late String _userName;
  late String _account;
  late String _email;
  late String _power;

  @override
  void initState() {
    super.initState();
    _userName = widget.user.userName;
    _account = widget.user.account;
    _email = widget.user.email;
    _power = widget.user.power;
  }

  Future<void> updateUser(String userId, String userName, String account,
      String email, String power) async {
    final url = Uri.parse('http://192.168.1.5:4001/diary-server/updateUser');
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userId': userId,
        'userName': userName,
        'account': account,
        'email': email,
        'power': power,
      }),
    );

    if (response.statusCode == 200) {
      // 更新成功，处理响应
      print('用户信息更新成功');
    } else {
      // 更新失败，处理错误
      print('用户信息更新失败: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('修改用户信息'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: _userName,
            onChanged: (value) {
              setState(() {
                _userName = value;
              });
            },
            decoration: InputDecoration(labelText: '用户名'),
          ),
          TextFormField(
            initialValue: _account,
            onChanged: (value) {
              setState(() {
                _account = value;
              });
            },
            decoration: InputDecoration(labelText: '账号'),
          ),
          TextFormField(
            initialValue: _email,
            onChanged: (value) {
              setState(() {
                _email = value;
              });
            },
            decoration: InputDecoration(labelText: '邮箱'),
          ),
          DropdownButtonFormField<String>(
            value: _power,
            items: <String>['用户', '管理员'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _power = value!;
              });
            },
            decoration: InputDecoration(labelText: '用户权限'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: () async {
            await updateUser(
                widget.user.userId, _userName, _account, _email, _power);
            widget.onUpdate(User(
              userId: widget.user.userId,
              userName: _userName,
              account: _account,
              email: _email,
              power: _power,
            ));
            Navigator.of(context).pop();
          },
          child: Text('保存'),
        ),
      ],
    );
  }
}
