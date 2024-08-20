import 'dart:convert';
import 'dart:io';

import 'package:diary_cli/components/constants.dart';
import 'package:diary_cli/entity/ShoppingCart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../SharedPre.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<ShoppingCart>> futureCart;

  int cartNum = 0;
  String _searchByUser = '';
  String _searchByItem = '';
  String? _token;
  @override
  void initState() {
    super.initState();
    _token = SharedPre.getToken();
    futureCart = fetchAllCart(1, 10, _token);
  }

  Future<List<ShoppingCart>> fetchAllCart(
      int current, int pageSize, String? token) async {
    print('token : $_token');
    final url = Uri.parse(
        'http://192.168.1.5:4001/diary-server/shoppingCart/$current/$pageSize');
    final response = await http.get(
      url,
      headers: {
        'token': _token.toString(), // 将 token 放入请求头中
      },
    );
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final List<dynamic> data = responseBody['data']['records'];
      return data.map((json) => ShoppingCart.fromJson(json)).toList();
    } else {
      throw Exception('查询失败: ${response.body}');
    }
  }

  Future<List<ShoppingCart>> fetchUserCart(
      int current, int pageSize, String userName) async {
    final queryParameters = {
      'userName': userName,
    };
    final url = Uri.http(
        '192.168.1.5:4001',
        '/diary-server/shoppingCart/searchByUser/$current/$pageSize',
        queryParameters);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['status'] == true) {
        final List<dynamic> data = responseBody['data']['records'];
        return data.map((json) => ShoppingCart.fromJson(json)).toList();
      } else {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'];
        throw Exception('查询失败: $message');
      }
    } else {
      final responseBody = jsonDecode(response.body);
      final message = responseBody['message'];
      throw Exception('查询失败: $message');
    }
  }

  Future<List<ShoppingCart>> fetchItemCart(
      int current, int pageSize, String itemName) async {
    final queryParameters = {
      'itemName': itemName,
    };
    final url = Uri.http(
        '192.168.1.5:4001',
        '/diary-server/shoppingCart/searchByItem/$current/$pageSize',
        queryParameters);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['status'] == true) {
        final List<dynamic> data = responseBody['data']['records'];
        print(data);
        return data.map((json) => ShoppingCart.fromJson(json)).toList();
      } else {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'];
        throw Exception('查询失败: $message');
      }
    } else {
      final responseBody = jsonDecode(response.body);
      final message = responseBody['message'];
      throw Exception('查询失败: $message');
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
                  future: futureCart,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('查询失败: ${snapshot.error}'));
                    } else {
                      final carts = snapshot.data!;
                      this.cartNum = carts.length;
                      return ListView(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Container(
                                  child: const Text("购物车管理"),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: _searchByItem,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchByItem = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "请输入商品名称",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: _searchByUser,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchByUser = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "请输入用户名",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        futureCart = _searchByUser != ''
                                            ? fetchUserCart(
                                                1, 10, _searchByUser)
                                            : _searchByItem != ''
                                                ? fetchItemCart(
                                                    1, 10, _searchByItem)
                                                : fetchAllCart(1, 10, _token);
                                      });
                                    },
                                    child: const Text("查询")),
                              ),
                            ],
                          ),
                          SizedBox(
                              child: DataTable(
                            columns: const [
                              DataColumn(label: Text("购物车ID")),
                              DataColumn(label: Text("商品ID")),
                              DataColumn(label: Text("     图片")),
                              DataColumn(label: Text("用户ID")),
                              DataColumn(label: Text("用户名")),
                              DataColumn(label: Text("数量")),
                              DataColumn(label: Text("价格")),
                              DataColumn(label: Text("     操作")),
                            ],
                            rows: List.generate(carts.length, (index) {
                              final cart = carts[index];
                              final itemId = cart.itemId;
                              return DataRow(cells: [
                                DataCell(Text(cart.cartId)),
                                DataCell(Text(cart.itemId)),
                                DataCell(
                                    // cart.picture != null
                                    GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Container(
                                            width: 800,
                                            height: 600,
                                            child: Image.file(
                                              File(
                                                  'D:/photos/itemImg/photo$itemId.jpg'),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Image.file(
                                    File('D:/photos/itemImg/photo$itemId.jpg'),
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.contain,
                                  ),
                                )
                                    // :
                                    ),
                                DataCell(Text(cart.userId)),
                                DataCell(Text(cart.userName)),
                                DataCell(Text(cart.quantity.toString())),
                                DataCell(Text(cart.price.toString())),
                                DataCell(Row(
                                  children: [
                                    ElevatedButton(
                                        onPressed: () async {
                                          final itemId = cart.itemId;
                                          final userId = cart.userId;
                                          final url = Uri.parse(
                                              'http://192.168.1.5:4001/diary-server/shoppingCart/deleteItem/$itemId/$userId');
                                          final response =
                                              await http.delete(url);
                                          if (response.statusCode == 200) {
                                            setState(() {
                                              carts.removeAt(index);
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content:
                                                      Text('删除成功(●\'◡\'●)')),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text('删除失败，请重试')),
                                            );
                                          }
                                        },
                                        child: const Text("删除")),
                                  ],
                                ))
                              ]);
                            }),
                          )),
                        ],
                      );
                    }
                  }))
        ],
      ),
    );
  }
}
