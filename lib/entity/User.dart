class User {
  final String userId;
  final String userName;
  final String account;
  final String email;
  final String power;
  final String? sex;
  final String? txPicture;

  User({
    required this.userId,
    required this.userName,
    required this.account,
    required this.email,
    required this.power,
    this.sex,
    this.txPicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      userName: json['userName'],
      account: json['account'],
      power: json['power'],
      email: json['email'],
      sex: json['sex'],
      txPicture: json['txPicture'],
    );
  }
}
