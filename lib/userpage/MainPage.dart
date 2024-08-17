import 'package:diary_cli/userpage/user_home.dart';
import 'package:flutter/material.dart';

import 'package:diary_cli/views/admin_view.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;

class UserMainPage extends StatefulWidget {
  @override
  _UserMainPageState createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  bool useMaterial3 = true;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: useLightMode ? Brightness.light : Brightness.dark,
        useMaterial3: useMaterial3,
      ),
      child: Scaffold(
        body: UserHome(),
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
