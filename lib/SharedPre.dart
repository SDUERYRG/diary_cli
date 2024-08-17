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

  static void saveToken(String token){
    _prefs.setString(TOKEN, token);
  }
  static String? getToken() {
    return _prefs.getString(TOKEN);
  }

  static void removeToken() {
    _prefs.remove(TOKEN);
  }
  static void clearLogin(){
    _prefs.clear();
  }
}