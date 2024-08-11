class Item {
  final String itemId;
  final String itemName;
  final String? picture;
  final int stock;
  final String description;
  final int sell;
  final double price;
  final double discount;
  final double? score;

  //数据库中没有的字段
  final String? orderNum;
  final bool? rxFlag;
  final bool? xpFlag;
  final bool? tjFlag;
  final String? shoppingCartId;
  // final List<Evaluate> evaluateList;

  Item({
    required this.itemId,
    required this.itemName,
    this.picture,
    required this.stock,
    required this.description,
    required this.sell,
    required this.price,
    required this.discount,
    this.score,
    this.orderNum,
    this.rxFlag,
    this.xpFlag,
    this.tjFlag,
    this.shoppingCartId,
    // required this.evaluateList,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json['itemId'],
      itemName: json['itemName'],
      picture: json['picture'],
      stock: json['stock'],
      description: json['description'],
      sell: json['sell'],
      price: json['price'],
      discount: json['discount'],
      score: json['score'],
      orderNum: json['orderNum'],
      rxFlag: json['rxFlag'],
      xpFlag: json['xpFlag'],
      tjFlag: json['tjFlag'],
      shoppingCartId: json['shoppingCartId'],
      // evaluateList: json['evaluateList'],
    );
  }
}
