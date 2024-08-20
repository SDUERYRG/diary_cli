import 'package:diary_cli/SharedPre.dart';
import 'package:diary_cli/entity/Order.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
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

  @override
  void initState() {
    super.initState();
    fetchOrders(0, 10);
  }

  Future<List<Order>> fetchOrders(int current, int pageSize) async {
    final url = Uri.parse(
        'http://192.168.1.5:4001/diary-server/order/$current/$pageSize');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'token': SharedPre.getToken().toString(),
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      // 处理数据
      final List<dynamic> data = responseBody['data']['records'];
      print(responseBody);
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      // 处理错误
      print('请求失败，状态码：${response.statusCode}');
      throw Exception('请求失败，状态码：${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          brightness: useLightMode ? Brightness.light : Brightness.dark,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text('订单'),
          ),
          body: FutureBuilder(
            future: fetchOrders(0, 10),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                final List<Order> orderList = snapshot.data!;
                return ListView.builder(
                  itemCount: orderList.length,
                  itemBuilder: (context, index) {
                    final Order order = orderList[index];
                    print(order.orderTime);
                    final DateFormat formatter =
                        DateFormat('yyyy-MM-dd HH:mm:ss');
                    final String formattedOrderTime =
                        formatter.format(order.orderTime);
                    return ListTile(
                      title: Text(order.orderNum),
                      subtitle: Text(formattedOrderTime),
                      trailing: Text(order.state),
                    );
                  },
                );
              }
            },
          ),
        ));
  }
}
