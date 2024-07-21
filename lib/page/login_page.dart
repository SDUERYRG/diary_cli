import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late String _email, _password, _code;

  Future<void> _sendCode() async {
    final Uri uri =
        Uri.parse('http://localhost:4001/diary-server/sendMail/$_email');
    // final response = await http.post(
    //   'http://localhost:4001/diary-sever/sendMail/$_email',
    //   body: jsonEncode(<String, String>{
    //     'email': _email,
    //   }),
    // );
    final response = await http.get(uri);
    print(response.body);
    // if (response.statusCode == 200) {

    // } else {
    //   print('验证码发送失败');
    // }
  }

  Future<void> _register() async {
    final response = await http.post(
      'http://localhost:4001/diary-sever/userRegister' as Uri,
      body: jsonEncode(<String, String>{
        'email': _email,
        'password': _password,
        'code': _code,
      }),
    );

    if (response.statusCode == 200) {
      print('注册成功');
    } else {
      print('注册失败');
    }
  }

  Future<void> _resetPassword() async {
    final response = await http.post(
      'http://localhost:4001/diary-sever/modifyPassword' as Uri,
      body: jsonEncode(<String, String>{
        'email': _email,
        'password': _password,
        'code': _code,
      }),
    );

    if (response.statusCode == 200) {
      print('密码重置成功');
    } else {
      print('密码重置失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(labelText: '邮箱'),
            validator: (value) {
              if (value!.isEmpty) {
                return '请输入邮箱';
              }
              _email = value;
              return null;
            },
          ),
          // TextFormField(
          //   decoration: InputDecoration(labelText: '密码'),
          //   obscureText: true,
          //   validator: (value) {
          //     if (value!.isEmpty) {
          //       return '请输入密码';
          //     }
          //     _password = value;
          //     return null;
          //   },
          // ),
          // TextFormField(
          //   decoration: InputDecoration(labelText: '验证码'),
          //   validator: (value) {
          //     if (value!.isEmpty) {
          //       return '请输入验证码';
          //     }
          //     _code = value;
          //     return null;
          //   },
          // ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _sendCode();
              }
            },
            child: Text('发送验证码'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _resetPassword();
              }
            },
            child: Text('找回密码'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register'); // 返回登录页面
            },
            child: Text('去注册'),
          ),
        ],
      ),
    );
  }
}
