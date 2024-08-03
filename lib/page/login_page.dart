import 'dart:convert';

import 'package:diary_cli/page/main_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _power = '用户';
  late String _password, _account;

  //SharedPreferences保存token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  //sharedPreferences获取token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _login(String account, String password) async {
    final url = Uri.parse('http://192.168.1.5:4001/diary-server/login');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'account': account,
        'password': password,
        // 'power': power,
      }),
    );
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final token = responseBody['message'];
      await saveToken(token); // 存储token
      print('登录成功:${token}');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else {
      print('登录失败:${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/login.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.only(left: 40), // 设置左边距为20
                height: screenHeight * 0.5,
                // decoration: BoxDecoration(
                //   color: Colors.white.withOpacity(0.5),
                // ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(labelText: '账号'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '请输入邮箱';
                          }
                          _account = value;
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: '密码'),
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '请输入密码';
                          }
                          _password = value;
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 100),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // _login(_account, _password, _power);
                                _login(_account, _password);
                              }
                            },
                            child: Text('登录'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, '/register'); // 返回登录页面
                            },
                            child: Text('去注册'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                child: Text(''),
              ),
            ),
          ],
        ));
  }
}
