class Order {
  String orderId;
  String orderNum;
  DateTime orderTime;
  DateTime? deliverTime;
  DateTime? receiptTime;
  String state;
  double price;
  String userId;
  Order({
    required this.orderId,
    required this.orderNum,
    required this.orderTime,
    this.deliverTime,
    this.receiptTime,
    required this.state,
    required this.price,
    required this.userId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      orderNum: json['orderNum'],
      orderTime: DateTime.parse(json['orderTime']),
      deliverTime: json['deliverTime'] != null
          ? DateTime.parse(json['deliverTime'])
          : null,
      receiptTime: json['receiptTime'] != null
          ? DateTime.parse(json['receiptTime'])
          : null,
      state: json['state'],
      price: json['price'].toDouble(),
      userId: json['userId'],
    );
  }
}
