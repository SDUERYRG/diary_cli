class Address {
  int addressId;
  String userName;
  String address;
  String tel;
  String userId;

  Address({
    required this.addressId,
    required this.userName,
    required this.address,
    required this.tel,
    required this.userId,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['addressId'],
      userName: json['userName'],
      address: json['address'],
      tel: json['tel'],
      userId: json['userId'],
    );
  }

  // 添加 toJson 方法
  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'userName': userName,
      'address': address,
      'tel': tel,
      'userId': userId,
    };
  }
}
