import 'dart:convert';

import 'package:diary_cli/components/constants.dart';
import 'package:diary_cli/entity/Order.dart';
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
  late Future<List<Order>> futureOrders;

  @override
  void initState() {
    super.initState();
    // futureOrders = fetchAllOrders(1, 10);
  }

  // Future<List<Order>> fetchAllOrders(int current, int pageSize) async {
  //   final url = Uri.parse(
  //       'http://192.168.1.5:4001/diary-server/order/$current/$pageSize');
  //   final response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     final responseBody = jsonDecode(response.body);
  //     final List<dynamic> data = responseBody['data']['records'];
  //     return data.map((json) => Order.fromJson(json)).toList();
  //   } else {
  //     throw Exception('查询失败: ${response.body}');
  //   }
  // }

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
                      final items = snapshot.data!;

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Container(
                                  child: const Text("商品管理"),
                                ),
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
                                  child: Text("添加"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  }))
        ],
      ),
    );
  }
}
