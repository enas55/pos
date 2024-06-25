import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/helpers/sql_helper.dart';
import 'package:pos/models/order.dart';
import 'package:pos/models/order_item.dart';
import 'package:pos/utilities/my_palette.dart';

class AllSalesPage extends StatefulWidget {
  const AllSalesPage({this.refreshTodaySales, super.key});
  final Function? refreshTodaySales;

  @override
  State<AllSalesPage> createState() => _AllSalesPageState();
}

class _AllSalesPageState extends State<AllSalesPage> {
  List<Order> orders = [];
  List<OrderItem> orderItems = [];

  @override
  void initState() {
    getOrder();
    super.initState();
  }

  Future<void> getOrder() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
Select O.*, C.name as clientName, C.phone as clientPhone from orders O
Inner JOIN clients C
On O.clientId = C.id
""");
      if (data.isNotEmpty) {
        for (var item in data) {
          orders.add(
            Order.fromJson(item),
          );
        }
      } else {
        orders = [];
      }

      log('>>>>>>>>>>>>>>>>>$data');
    } catch (e) {
      orders = [];

      log('Error in get orders : $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Sales'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: orders.isEmpty
            ? const Center(
                child: Text('No Sales Found'),
              )
            : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  var order = orders[index];
                  var discountedPrice =
                      calcDiscountedPrice(order.totalPrice ?? 0);
                  return Card(
                    color: primary.shade100,
                    child: ListTile(
                      title: Text(
                        'Order: ${order.label}',
                        style: const TextStyle(
                            color: primary, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client: ${order.clientName ?? 'No Name'}',
                          ),
                          Text(
                            'Phone: ${order.clientPhone ?? 'No Phone Found'}',
                          ),
                          Text(
                            'Total Price: \$${order.totalPrice.toString()}',
                          ),
                          Text(
                            'Total Price After Discount: \$${discountedPrice.toString()}',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await onShow(order);
                                },
                                icon: const Icon(
                                  Icons.visibility,
                                  color: primary,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await onDelete(order);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: primary,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  double calcDiscountedPrice(double totalPrice) {
    const discountRate = 0.20;
    return totalPrice * (1 - discountRate);
  }

  Future<void> onShow(Order order) async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
        Select OI.*, P.name , P.price
        from orderProductItems as OI
        Inner JOIN products as P
        ON OI.productId = P.id
        WHERE OI.orderId = ?
      """, [order.id]);

      if (data.isNotEmpty) {
        orderItems = [];
        for (var item in data) {
          orderItems.add(
            OrderItem.fromJson(item),
          );
        }
      } else {
        orderItems = [];
      }

      log('>>>>>>>>>>>>>>>>>$data');

      // the bottom sheet

      showModalBottomSheet(
        backgroundColor: primary.shade50,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Label: ${order.label}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Client: ${order.clientName ?? 'No Name'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Phone: ${order.clientPhone ?? 'No Phone Found'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total Price: \$${order.totalPrice.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total Price After Discount: \$${calcDiscountedPrice(order.totalPrice!).toString()}',
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Order Items:',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primary),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: orderItems.length,
                    itemBuilder: (context, index) {
                      var item = orderItems[index];
                      return ListTile(
                        title: Text(
                          '${item.product!.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount: ${item.productCount}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Price: \$${item.product!.price}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      log('Error in showing order details: $e');
    }
  }

  Future<void> onDelete(Order order) async {
    try {
      var confirmDelete = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: primary.shade50,
              title: const Text('Delete Order'),
              content:
                  const Text('Are you sure you want to delete this order?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          });

      if (confirmDelete ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        await sqlHelper.db!.delete(
          'orders',
          where: 'id =?',
          whereArgs: [order.id],
        );

        getOrder();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Failed to delete this order : ${order.label}',
          ),
        ),
      );
    }
  }
}
