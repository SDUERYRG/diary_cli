import 'package:flutter/material.dart';

import 'package:diary_cli/page/login_page.dart';
import 'package:diary_cli/page/register_page.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: LoginPage(),
    ),
    routes: {
      '/register': (context) => RegisterPage(),
    },
  ));
}
