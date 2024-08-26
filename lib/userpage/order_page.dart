import 'package:diary_cli/SharedPre.dart';
import 'package:diary_cli/components/flutter_flow_theme.dart';
import 'package:diary_cli/entity/Order.dart';
import 'package:diary_cli/entity/OrderItem.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late Future<OrderItem> futureOrderItems;
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

  Future<OrderItem> fetchOrderItem(String orderId, String orderNum) async {
    final url = Uri.parse(
        'http://192.168.1.5:4001/diary-server/order/show/$orderId/$orderNum');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'token': SharedPre.getToken().toString(),
      },
    );
    final responseBody = json.decode(response.body);
    print(responseBody);
    if (responseBody['status'] == true) {
      // 处理数据
      final data = responseBody['data'];
      return OrderItem.fromJson(data);
    } else {
      // 处理错误
      print('请求失败，状态码：${response.statusCode}');
      throw Exception('请求失败，状态码：${response.statusCode}');
    }
  }

  Future<OrderItem?> fetchOrderItems(String orderId) async {
    final url =
        Uri.parse('http://192.168.1.5:4001/diary-server/order/$orderId');
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
      print(responseBody);
      return null;
    } else {
      // 处理错误
      print('请求失败，状态码：${response.statusCode}');
      throw Exception('请求失败，状态码：${response.statusCode}');
    }
  }

  Future<List<Order>> fetchOrders(int current, int pageSize) async {
    final userId = SharedPre.getUserId();
    final url = Uri.parse(
        'http://192.168.1.5:4001/diary-server/order/userOrder/$userId/$current/$pageSize');
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
            title: const Text('订单'),
          ),
          body: FutureBuilder(
            future: fetchOrders(0, 10),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
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
                      onTap: () {
                        futureOrderItems = fetchOrderItem(
                            order.orderId, order.orderNum.toString());
                        showDialog(
                            context: context,
                            builder: (context) {
                              return UnconstrainedBox(
                                child: Container(
                                  width: 300,
                                  height: 500,
                                  decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground),
                                  child: FutureBuilder(
                                    future: futureOrderItems,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                '查询失败: ${snapshot.error}'));
                                      } else {
                                        final orderItems = snapshot.data!;
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Text(
                                                  "订单号：${orderItems.orderNum}"),
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        20, 0, 20, 20),
                                                child: Text(
                                                    "下单时间：${orderItems.orderTime}")),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        20, 0, 20, 20),
                                                child: Text(
                                                    "用户名：${orderItems.userName}")),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        20, 0, 20, 20),
                                                child: Text(
                                                    "收货地址：${orderItems.address}")),
                                            const Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    20, 0, 20, 20),
                                                child: Text("订单内容：")),
                                            Expanded(
                                              child: ListView.builder(
                                                  itemCount:
                                                      orderItems.itemId.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(20,
                                                                  20, 20, 0),
                                                          child: Text(
                                                              "商品ID：${orderItems.itemId[index]}"),
                                                        ),
                                                        Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    20,
                                                                    10,
                                                                    20,
                                                                    10),
                                                            child: Text(
                                                                "商品名称：${orderItems.itemName[index]}")),
                                                      ],
                                                    );
                                                  }),
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        20, 20, 20, 20),
                                                child: Text(
                                                    "总价：${orderItems.price}")),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            });
                      },
                    );
                  },
                );
              }
            },
          ),
        ));
  }
}
