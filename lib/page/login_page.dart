import 'dart:convert';

import 'package:diary_cli/page/main_page.dart';
import 'package:diary_cli/userpage/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../SharedPre.dart';
import '../components/button.dart';
import '../components/flutter_flow_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _host = '192.168.160.32';
  final _formKey = GlobalKey<FormState>();
  String _power = '用户';
  late String _password, _account;

  Future<void> _login(String account, String password) async {
    final url = Uri.parse('http://$_host:4001/diary-server/login');
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
      final name = responseBody['data']['userName'];
      final token = responseBody['message'];
      SharedPre.setName(name); // 存储name
      SharedPre.saveToken(token); // 存储token
      print('登录成功:${SharedPre.getToken()}');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else {
      print('登录失败:${response.body}');
    }
  }

  Future<void> _userLogin(String account, String password) async {
    try {
      final url = Uri.parse('http://$_host:4001/diary-server/login');
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
        print(response.body);
        final responseBody = jsonDecode(response.body);
        final name = responseBody['data']['userName'];
        final token = responseBody['message'];
        SharedPre.saveToken(token); // 存储token
        SharedPre.setName(name); // 存储name
        SharedPre.setUserId(responseBody['data']['userId']);
        print('登录成功:${token}');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserMainPage()),
        );
      } else {
        print('登录失败:${response.body}');
      }
    } catch (e) {
      print(e);
    }
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isDesktop(context)) {
      return Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/login.png'),
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
    } else {
      return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          width: screenWidth,
          height: screenHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.only(left: 40, right: 40), // 设置左边距为20
                  height: screenHeight * 0.8,
                  // decoration: BoxDecoration(
                  //   color: Colors.white.withOpacity(0.5),
                  // ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 300,
                          decoration: const BoxDecoration(
                            // color: Colors.amber
                            image: DecorationImage(
                              image: AssetImage('assets/images/logo2.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 4.0),
                          child: Text(
                            '账号',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                          ),
                        ),
                        TextFormField(
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 1.0,
                                    color: Colors.black,
                                  ),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0x00000000),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0x00000000),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0x00000000),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0x00000000),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF2F2F2),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '请输入账号';
                            }
                            _account = value;
                            print('账号：$_account');
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 4.0),
                          child: Text(
                            '密码',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                          ),
                        ),
                        TextFormField(
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 1.0,
                                    color: Colors.black,
                                  ),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0x00000000),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0x00000000),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0x00000000),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0x00000000),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF2F2F2),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '请输入密码';
                            }
                            _password = value;
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 0.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // _login(_account, _password, _power);
                                _userLogin(_account, _password);
                              }
                            },
                            text: '登录',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 50.0,
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 0.0,
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              Navigator.pushNamed(
                                  context, '/userRegister'); // 返回登录页面
                            },
                            text: '注册',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 50.0,
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 0.0,
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ));
    }
  }
}
