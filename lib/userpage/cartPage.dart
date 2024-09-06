import 'dart:convert';
import 'package:diary_cli/SharedPre.dart';
import 'package:diary_cli/components/cart_card.dart';
import 'package:diary_cli/components/flutter_flow_theme.dart';
import 'package:diary_cli/entity/Address.dart';
import 'package:diary_cli/host.dart';
import 'package:flutter/material.dart';
import 'package:diary_cli/entity/ShoppingCart.dart';
import 'package:http/http.dart' as http;

class CartPage extends StatefulWidget {
  final GlobalKey homePageKey;

  const CartPage({super.key, required this.homePageKey});
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late double sum;
  String _host = Host.host;
  List<bool> _checkedList = [];
  List<double> _priceList = [];
  List<String> _itemIdList = [];
  Address? address;
  int cartNum = 0;
  // double sum = 0;
  late Future<List<ShoppingCart>> cartList;

  @override
  void initState() {
    super.initState();
    setState(() {
      sum = 0;
      cartList = fetchUserCart(0, 100, SharedPre.getName().toString(),
          SharedPre.getToken().toString());
    });
  }

  Future<List<ShoppingCart>> fetchUserCart(
      int current, int pageSize, String userName, String token) async {
    final queryParameters = {
      'userName': userName,
    };
    final headers = {
      'token': token, // 将token添加到请求头
    };
    final url = Uri.http(
        '$_host:4001',
        '/diary-server/shoppingCart/searchByUser/$current/$pageSize',
        queryParameters);
    final response = await http.get(url, headers: headers); // 添加headers参数
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

  double addPrice(int index) {
    print(_checkedList);
    if (_checkedList[index]) {
      sum += _priceList[index];
    } else {
      sum -= _priceList[index];
    }
    return sum;
  }

  void updateCheckedList(int index, bool value) {
    setState(() {
      if (_checkedList.length < index + 1) {
        for (int i = _checkedList.length; i < index; i++) {
          _checkedList.add(false);
        }
        _checkedList.add(value);
      } else {
        _checkedList[index] = value;
      }

      cartList.then((carts) {
        if (value) {
          _itemIdList.add(carts[index].itemId);
        } else {
          _itemIdList.remove(carts[index].itemId);
        }
      });
    });
    print(_checkedList);
    print(_priceList);
    print(addPrice(index));
    SharedPre.setSum(sum);
  }

  void refreshCart() {
    setState(() {
      cartList = fetchUserCart(0, 100, SharedPre.getName().toString(),
          SharedPre.getToken().toString());
    });
  }

  Future<void> getUserAddress(String userId) async {
    // 构建请求URL
    final url = Uri.parse(
        'http://$_host:4001/diary-server/address/getUserAddress/$userId');

    // 发送 GET 请求
    final response = await http.get(
      url,
      headers: {
        'token': SharedPre.getToken().toString(),
        'Content-Type': 'application/json',
      },
    );
    final responseBody = jsonDecode(response.body);
    // 处理响应
    if (responseBody['status'] == true) {
      print(responseBody['data']);
      List<dynamic> addressList = responseBody['data'];
      address = Address.fromJson(addressList[0]);
      print('获取成功: $addressList');
    } else {
      print('获取失败');
      print(response.body);
    }
  }

  Future<void> pay() async {
    await getUserAddress(SharedPre.getUserId().toString());
    final url = Uri.parse('http://$_host:4001/diary-server/shoppingCart/pay');

    // 构建请求体
    Map<String, dynamic> requestBody = {
      'itemIdList': _itemIdList,
      'price': sum.toString(),
      'address': address?.toJson(), // 调用 toJson 方法
    };

    // 发送 POST 请求
    final response = await http.post(
      url,
      headers: {
        'token': SharedPre.getToken().toString(),
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody), // 将请求体转换为 JSON 字符串
    );

    final responseBody = jsonDecode(response.body);
    print(responseBody);
    if (responseBody['status'] == true) {
      print('购买成功');
      for (int i = 0; i < _itemIdList.length; i++) {
        await _deleteCart(_itemIdList[i], SharedPre.getUserId().toString());
      }
      setState(() {
        this.sum = 0;
      });
      refreshCart();
    } else {
      print('购买失败');
      print(response.body);
    }
  }

  Future<void> _deleteCart(String itemId, String userId) async {
    userId = SharedPre.getUserId().toString();
    String token = SharedPre.getToken().toString();
    print(itemId);
    final url = Uri.parse(
        'http://$_host:4001/diary-server/shoppingCart/deleteItem/$itemId/$userId');
    final response = await http.delete(url, headers: {
      'token': token,
    });
    if (response.statusCode == 200) {
      final responseBody = response.body;
      print(responseBody);
    } else {
      final responseBody = response.body;
      print(responseBody);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          width: MediaQuery.of(context).size.width,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 20,
            child: FutureBuilder(
              future: cartList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('查询失败: ${snapshot.error}'));
                } else {
                  final carts = snapshot.data!;
                  this.cartNum = carts.length;
                  _priceList = List.filled(cartNum, 0);
                  print('_checkedList');
                  return ListView.builder(
                    itemCount: carts.length,
                    itemBuilder: (context, index) {
                      _priceList[index] = carts[index].price;
                      return Container(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: CartCard(
                          cart: carts[index],
                          onFresh: (value) {
                            setState(() {
                              refreshCart();
                            });
                          },
                          onChangedSum: (value) {
                            setState(() {
                              updateCheckedList(index, value);
                            });
                          },
                          index: index,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: FlutterFlowTheme.of(context).primaryBackground,
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('总价: \$${sum.toStringAsFixed(2)}'),
                ElevatedButton(
                  onPressed: () async {
                    // 处理结算逻辑
                    await pay();
                  },
                  child: Text('结算'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
