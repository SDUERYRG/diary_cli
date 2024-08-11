import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _userName = '';
  String _account = '';
  String _password = '';
  // ignore: unused_field
  String _confirmPassword = '';
  String _power = '用户'; // 默认用户权限
  String _email = '';
  String _verificationCode = '';
  String _regTime = '';

  Future<void> _sendCode() async {
    final Uri uri =
        Uri.parse('http://192.168.1.5:4001/diary-server/sendMail/$_email');
    // Uri.parse('http://localhost:4001/flower_shop/sendMail/$_email');
    final response = await http.get(uri);
    print(response.body);
  }

  static Future<void> _register(String name, String account, String email,
      String password, String code, String power, String regTime) async {
    final url = Uri.parse('http://192.168.1.5:4001/diary-server/userRegister');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userName': name,
        'account': account,
        'email': email,
        'password': password,
        'code': code,
        'power': power,
        'regTime': regTime,
      }),
    );

    if (response.statusCode == 200) {
      print('注册成功: ${response.body}');
    } else {
      print('注册失败: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('注册'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: '用户名'),
                onChanged: (value) {
                  setState(() {
                    _userName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '账号'),
                onChanged: (value) {
                  setState(() {
                    _account = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入账号';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '密码'),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '确认密码'),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _confirmPassword = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请再次输入密码';
                  }
                  if (value != _password) {
                    return '两次输入密码不一致';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '邮箱'),
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入邮箱';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '验证码'),
                onChanged: (value) {
                  setState(() {
                    _verificationCode = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入验证码';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '用户权限'),
                value: _power,
                items: <String>['用户', '管理员'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _power = '用户';
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _regTime = DateTime.now().toString();
                    _register(_userName, _account, _email, _password,
                        _verificationCode, _power, _regTime);
                  }
                },
                child: Text('注册'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 处理发送验证码逻辑
                  print('Email: $_email');
                  _sendCode();
                },
                child: Text('发送验证码'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 返回登录页面
                },
                child: Text('返回登录'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
