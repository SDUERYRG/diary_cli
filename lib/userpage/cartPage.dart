import 'dart:convert';
import 'dart:ffi';
import 'package:diary_cli/SharedPre.dart';
import 'package:diary_cli/components/cart_card.dart';
import 'package:diary_cli/components/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:diary_cli/entity/ShoppingCart.dart';
import 'package:http/http.dart' as http;
import 'package:diary_cli/userpage/user_home.dart';

class CartPage extends StatefulWidget {
  final GlobalKey homePageKey;

  const CartPage({super.key, required this.homePageKey});
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late double sum;
  List<bool> _checkedList = [];
  List<double> _priceList = [];
  int cartNum = 0;
  // double sum = 0;
  late Future<List<ShoppingCart>> cartList;

  @override
  void initState() {
    super.initState();
    setState(() {
      sum = 0;
      cartList = fetchUserCart(0, 10, SharedPre.getName().toString(),
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
        '192.168.1.5:4001',
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
    });
    print(_checkedList);
    print(_priceList);
    print(addPrice(index));
    SharedPre.setSum(sum);
  }

  void refreshCart() {
    setState(() {
      cartList = fetchUserCart(0, 10, SharedPre.getName().toString(),
          SharedPre.getToken().toString());
    });
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
                  onPressed: () {
                    // 处理结算逻辑
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
