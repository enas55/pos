import 'package:pos/models/product_data.dart';

class OrderItem {
  int? orderId;
  int? productCount;
  int? productId;
  ProductData? product;

  OrderItem();

  OrderItem.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    productCount = json['productCount'];
    productId = json['productId'];
    product = ProductData.fromJson(json);
  }
}
