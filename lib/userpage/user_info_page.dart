import 'package:diary_cli/components/button.dart';
import 'package:diary_cli/components/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Future<void> logout() async {
    final url = Uri.parse('http://192.168.1.5:4001/diary-server//logout');
    final response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      print('成功登出');
      Navigator.pushReplacementNamed(context, '/mainP');
    } else {
      print('登出失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.12,
            child: Row(
              children: [
                Padding(padding: EdgeInsets.only(left: 20)),
                Expanded(
                    child: Column(
                  children: [
                    Padding(padding: EdgeInsets.only(top: 10)),
                    IconButton(
                      iconSize: 45,
                      icon: const Icon(Icons.receipt_long_rounded),
                      onPressed: () {
                        Navigator.pushNamed(context, '/order'); // 返回登录页面
                      },
                    ),
                    Text('订单'),
                  ],
                )),
                Expanded(
                    child: Container(
                  width: 45,
                  height: 45,
                )),
                Expanded(
                    child: Column(
                  children: [
                    Padding(padding: EdgeInsets.only(top: 10)),
                    IconButton(
                      iconSize: 45,
                      icon: const Icon(Icons.add_location_alt_outlined),
                      onPressed: () {},
                    ),
                    Text('地址'),
                  ],
                )),
                Padding(padding: EdgeInsets.only(right: 20)),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.42,
            decoration: BoxDecoration(
              color: Colors.green,
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.06,
            child: FFButtonWidget(
              onPressed: () async {
                await logout();
              },
              text: '退出登录',
              options: FFButtonOptions(
                width: double.infinity,
                height: 50.0,
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
          )
        ],
      ),
    );
  }
}
