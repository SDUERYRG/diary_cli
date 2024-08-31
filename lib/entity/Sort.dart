class Sort {
  final String sortId;
  String? itemId;
  final String sortName;
  String itemName;
  List<String>? purposeArray;

  Sort({
    required this.sortId,
    this.itemId,
    required this.sortName,
    required this.itemName,
    this.purposeArray,
  });

  factory Sort.fromJson(Map<String, dynamic> json) {
    return Sort(
      sortId: json['sortId'].toString(),
      itemId: json['itemId'],
      sortName: json['sortName'],
      itemName: json['itemName'],
      purposeArray: json['purposeArray'],
    );
  }
}
