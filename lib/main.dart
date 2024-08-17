import 'package:diary_cli/page/main_page.dart';
import 'package:diary_cli/page/user_manage_page.dart';
import 'package:diary_cli/userpage/user_regsiter.dart';
import 'package:flutter/material.dart';
import 'package:diary_cli/page/login_page.dart';
import 'package:diary_cli/page/register_page.dart';
import 'package:provider/provider.dart';
import 'package:diary_cli/controller/MenuController.dart' as prefix0;
import 'package:diary_cli/responsive.dart';

const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);
void main() {
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
