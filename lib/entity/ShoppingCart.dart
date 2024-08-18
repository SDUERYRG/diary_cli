import 'package:diary_cli/entity/Item.dart';

class ShoppingCart {
  final String cartId;
  final String itemId;
  final String userId;
  final String itemName;
  final String userName;
  final int quantity;
  final double price;

  //数据库中不存在
  final List<Item>? itemList;

  ShoppingCart(
      {required this.cartId,
      required this.itemId,
      required this.userId,
      required this.quantity,
      this.itemList,
      required this.itemName,
      required this.userName,
      required this.price});

  factory ShoppingCart.fromJson(Map<String, dynamic> json) {
    return ShoppingCart(
      cartId: json['cartId'],
      itemId: json['itemId'],
      userId: json['userId'],
      quantity: json['quantity'],
      itemList: json['itemList'],
      itemName: json['itemName'],
      userName: json['userName'],
      price: json['price'],
    );
  }
}
