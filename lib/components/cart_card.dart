import 'package:diary_cli/host.dart';
import 'package:http/http.dart' as http;
import 'package:diary_cli/SharedPre.dart';
import 'package:diary_cli/components/flutter_flow_theme.dart';
import 'package:diary_cli/entity/ShoppingCart.dart';
import 'package:flutter/material.dart';

class CartCard extends StatefulWidget {
  final ShoppingCart cart;
  final int index;
  final Function(bool) onChangedSum;
  final Function(bool) onFresh;
  CartCard({
    Key? key,
    required this.cart,
    required this.index,
    required this.onChangedSum,
    required this.onFresh,
  }) : super(key: key);

  _CartCardState createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  String _host = Host.host;
  bool checked = false;
  late String itemId;
  String image = '';

  @override
  void initState() {
    super.initState();
    itemId = widget.cart.itemId;
    image = 'assets/itemImage/photo$itemId.jpg';
  }

  Future<void> _deleteCart() async {
    String userId = SharedPre.getUserId().toString();
    String token = SharedPre.getToken().toString();
    String itemId = widget.cart.itemId;
    print(itemId);
    final url = Uri.parse(
        'http://$_host:4001/diary-server/shoppingCart/deleteItem/$itemId/$userId');
    final response = await http.delete(url, headers: {
      'token': token,
    });
    if (response.statusCode == 200) {
      final responseBody = response.body;
      print(responseBody);
      widget.onFresh(true);
    } else {
      final responseBody = response.body;
      print(responseBody);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(10),
        // border: Border.all(color: FlutterFlowTheme.of(context).primary),
      ),
      child: Row(
        children: [
          Checkbox(
            value: checked,
            onChanged: (value) {
              setState(() {
                checked = !checked;
                widget.onChangedSum(value ?? false); // 添加空值检查
                // 调用回调函数
              });
            },
          ),
          const Padding(padding: EdgeInsets.only(right: 10)),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              // color: Colors.red,
              image: DecorationImage(image: AssetImage(image)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    widget.cart.itemName,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 25)),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    '￥${((widget.cart.price) * (widget.cart.quantity)).toString()}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: IconButton(
                  onPressed: () async {
                    await _deleteCart();
                  },
                  icon: const Icon(Icons.delete))),
        ],
      ),
    );
  }
}
