class OrderItem {
  String orderNum; // 订单号
  DateTime orderTime; // 下单时间
  List<String> itemId; // 商品id
  List<String> itemName; // 商品名称
  String userId; // 购买用户id
  String userName; // 购买用户名
  double price; // 购买价格
  String address; // 收货地址

  OrderItem({
    required this.orderNum,
    required this.orderTime,
    required this.itemId,
    required this.itemName,
    required this.userId,
    required this.userName,
    required this.price,
    required this.address,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderNum: json['orderNum'],
      orderTime: DateTime.parse(json['orderTime']),
      itemId: List<String>.from(json['itemId']),
      itemName: List<String>.from(json['itemName']),
      userId: json['userId'],
      userName: json['userName'],
      price: json['price'],
      address: json['address'],
    );
  }
}
