import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPre {
  static const String TOKEN = "TOKEN"; //token
  static late SharedPreferences _prefs; //延迟初始化
  static Future<String> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();
    return 'ok';
  }

  static void saveToken(String token) {
    _prefs.setString(TOKEN, token);
  }

  static String? getToken() {
    return _prefs.getString(TOKEN);
  }

  static void removeToken() {
    _prefs.remove(TOKEN);
  }

  static void clearLogin() {
    _prefs.clear();
  }

  static void setName(String name) {
    _prefs.setString('name', name);
  }

  static String? getName() {
    return _prefs.getString('name');
  }

  static void setSum(double sum) {
    _prefs.setDouble('sum', sum);
  }

  static double getSum() {
    return _prefs.getDouble('sum') ?? 0;
  }

  static void setUserId(String userId) {
    _prefs.setString('userId', userId);
  }

  static String? getUserId() {
    return _prefs.getString('userId');
  }
}
