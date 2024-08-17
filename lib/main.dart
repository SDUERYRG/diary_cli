import 'package:diary_cli/SharedPre.dart';
import 'package:diary_cli/page/main_page.dart';
import 'package:diary_cli/userpage/user_regsiter.dart';
import 'package:flutter/material.dart';
import 'package:diary_cli/page/login_page.dart';
import 'package:diary_cli/page/register_page.dart';
import 'package:provider/provider.dart';
import 'package:diary_cli/controller/MenuController.dart' as prefix0;
import 'package:diary_cli/SharedPre.dart';

const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);
Future<void> main() async {
  String value= await SharedPre.init();// await 关键字必须用在异步方法中 await等待异步方法执行完毕 异步方法必须用变量接收
  if (value == 'ok'){
  runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData.dark().copyWith(
  scaffoldBackgroundColor: bgColor,
  canvasColor: secondaryColor,
  ),
  home: MultiProvider(
  providers: [
  ChangeNotifierProvider(
  create: (context) => prefix0.MenuController(),
  )
  ],
  child: Scaffold(
  resizeToAvoidBottomInset: false,
  body: LoginPage(),
  ),
  ),
  routes: {
  '/register': (context) => RegisterPage(),
  '/main': (context) => MainPage(),
  '/login': (context) => LoginPage(),
  '/userRegister': (context) => UserRegisterPage(),
  },
  ));
  }
}
