class Order {
  int? id;
  String? label;
  double? totalPrice;
  double? discount;
  int? clientId;
  String? clientName;
  String? clientPhone;
  DateTime? orderDate;

  Order();

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label'];
    totalPrice = json['totalPrice'];
    discount = json['discount'];
    clientId = json['clientId'];
    clientName = json['clientName'];
    clientPhone = json['clientPhone'];
    orderDate = json['orderDate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'totalPrice': totalPrice,
      'discount': discount,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'orderDate': orderDate,
    };
  }
}
