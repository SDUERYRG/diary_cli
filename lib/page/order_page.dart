import 'dart:convert';

import 'package:diary_cli/SharedPre.dart';
import 'package:diary_cli/components/constants.dart';
import 'package:diary_cli/entity/Order.dart';
import 'package:diary_cli/entity/OrderItem.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _OrderPageState();
  }
}

class _OrderPageState extends State<OrderPage> {
  String _host = '192.168.160.32';
  late Future<List<Order>> futureOrders;
  late Future<OrderItem> futureOrderItems;
  @override
  void initState() {
    super.initState();
    futureOrders = fetchAllOrders(1, 100);
  }

  Future<void> deliverGoods(Order order) async {
    final url = Uri.parse(
        'http://$_host:4001/diary-server/order/deliverGoods/${order.orderId}');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'token': SharedPre.getToken().toString(),
      },
    );
    final responseBody = json.decode(response.body);
    if (responseBody['status'] == true) {
      print('发货成功');
    } else {
      print('发货失败');
    }
  }

  Future<List<Order>> fetchAllOrders(int current, int pageSize) async {
    final url =
        Uri.parse('http://$_host:4001/diary-server/order/$current/$pageSize');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'token': SharedPre.getToken().toString()
    });
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final List<dynamic> data = responseBody['data']['records'];
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('查询失败: ${response.body}');
    }
  }

  Future<OrderItem> fetchOrderItems(String orderId, String orderNum) async {
    final url = Uri.parse(
        'http://$_host:4001/diary-server/order/show/$orderId/$orderNum');
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 200,
      child: Column(
        children: [
          Expanded(
              //header部分
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    //header左
                    flex: 3,
                    child: Container(
                        // decoration:
                        //     const BoxDecoration(color: Colors.white),

                        ),
                  ),
                  Expanded(
                      //头像部分
                      flex: 1,
                      child: SizedBox(
                        height: 70,
                        width: 70,
                        child: Container(
                          width: 70,
                          decoration:
                              const BoxDecoration(color: secondaryColor),
                        ),
                      ))
                ],
              )),
          Expanded(
              flex: 4,
              child: FutureBuilder(
                  future: futureOrders,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('查询失败: ${snapshot.error}'));
                    } else {
                      final orders = snapshot.data!;

                      return ListView(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                flex: 4,
                                child: Text("订单管理"),
                              ),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  onChanged: (value) {},
                                  decoration: const InputDecoration(
                                    labelText: "请输入商品名称",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                    onPressed: () {}, child: const Text("查询")),
                              ),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("添加"),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text("订单号")),
                                DataColumn(label: Text("下单时间")),
                                DataColumn(label: Text("订单状态")),
                                DataColumn(label: Text("发货时间")),
                                DataColumn(label: Text("收货时间")),
                                DataColumn(label: Text("操作")),
                              ],
                              rows: List.generate(orders.length, (index) {
                                final order = orders[index];
                                return DataRow(cells: [
                                  DataCell(Text(order.orderNum.toString())),
                                  DataCell(Text(order.orderTime.toString())),
                                  DataCell(Text(order.state)),
                                  DataCell(Text(order.deliverTime.toString())),
                                  DataCell(Text(order.receiptTime.toString())),
                                  DataCell(Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          futureOrderItems = fetchOrderItems(
                                              order.orderId,
                                              order.orderNum.toString());
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return UnconstrainedBox(
                                                  child: Container(
                                                    width: 400,
                                                    height: 500,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color:
                                                                secondaryColor),
                                                    child: FutureBuilder(
                                                      future: futureOrderItems,
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Center(
                                                              child:
                                                                  CircularProgressIndicator());
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return Center(
                                                              child: Text(
                                                                  '查询失败: ${snapshot.error}'));
                                                        } else {
                                                          final orderItems =
                                                              snapshot.data!;
                                                          return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        20),
                                                                child: Text(
                                                                    "订单号：${orderItems.orderNum}"),
                                                              ),
                                                              Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .fromLTRB(
                                                                          20,
                                                                          0,
                                                                          20,
                                                                          20),
                                                                  child: Text(
                                                                      "下单时间：${orderItems.orderTime}")),
                                                              Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .fromLTRB(
                                                                          20,
                                                                          0,
                                                                          20,
                                                                          20),
                                                                  child: Text(
                                                                      "用户名：${orderItems.userName}")),
                                                              Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .fromLTRB(
                                                                          20,
                                                                          0,
                                                                          20,
                                                                          20),
                                                                  child: Text(
                                                                      "收货地址：${orderItems.address}")),
                                                              const Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          20,
                                                                          0,
                                                                          20,
                                                                          20),
                                                                  child: Text(
                                                                      "订单内容：")),
                                                              Expanded(
                                                                child: ListView
                                                                    .builder(
                                                                        itemCount: orderItems
                                                                            .itemId
                                                                            .length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          return Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                                                                child: Text("商品ID：${orderItems.itemId[index]}"),
                                                                              ),
                                                                              Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 10), child: Text("商品名称：${orderItems.itemName[index]}")),
                                                                            ],
                                                                          );
                                                                        }),
                                                              ),
                                                              Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .fromLTRB(
                                                                          20,
                                                                          20,
                                                                          20,
                                                                          20),
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
                                        child: const Text("查看"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await deliverGoods(order);
                                          setState(() {
                                            futureOrders =
                                                fetchAllOrders(1, 100);
                                          });
                                        },
                                        child: const Text("发货"),
                                      ),
                                    ],
                                  ))
                                ]);
                              }),
                            ),
                          )
                        ],
                      );
                    }
                  }))
        ],
      ),
    );
  }
}
