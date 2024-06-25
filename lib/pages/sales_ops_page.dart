import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/helpers/sql_helper.dart';
import 'package:pos/models/order.dart';
import 'package:pos/models/order_Item.dart';
import 'package:pos/models/product_data.dart';
import 'package:pos/utilities/app_elevated_button.dart';
import 'package:pos/utilities/client_drop_down.dart';
import 'package:pos/utilities/my_palette.dart';
import 'package:sqflite/sqflite.dart';

class SalesOpsPage extends StatefulWidget {
  const SalesOpsPage({this.order, this.refreshTodaySales, super.key});
  final Order? order;
  final Function? refreshTodaySales;

  @override
  State<SalesOpsPage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<SalesOpsPage> {
  String? orderLabel;

  List<ProductData> products = [];
  List<OrderItem> selectedOrderItems = [];
  double totalPrice = 0.0;
  int? selectedClientId;

  Future<void> getProduct() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
Select P.*, C.name as categoryName, C.description as categoryDescription from products P
Inner JOIN categories C
On P.categoryId = C.id
""");
      if (data.isNotEmpty) {
        products = [];
        for (var item in data) {
          products.add(
            ProductData.fromJson(item),
          );
        }
      } else {
        products = [];
      }

      log('>>>>>>>>>>>>>>>>>$data');
    } catch (e) {
      products = [];

      log('Error in get products : $e');
    }
    setState(() {});
  }

  @override
  void initState() {
    initPage();
    super.initState();
  }

  void initPage() {
    getProduct();
    orderLabel = widget.order == null
        ? 'OR${DateTime.now().millisecondsSinceEpoch}'
        : widget.order?.label;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'Add New Sale' : 'Update Sale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: primary.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Label : $orderLabel',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ClientDropDown(
                        selectedValue: selectedClientId,
                        onChanged: (value) {
                          selectedClientId = value;
                          setState(() {});
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return StatefulBuilder(
                                        builder: (context, setStateEx) {
                                      return Dialog(
                                        backgroundColor: primary.shade50,
                                        child: products.isEmpty
                                            ? const Center(
                                                child: Text('No Data Found'),
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      child: ListView(
                                                        children: [
                                                          for (var item
                                                              in products)
                                                            ListTile(
                                                              title: Text(item
                                                                      .name ??
                                                                  'No Name'),
                                                              leading:
                                                                  Image.network(
                                                                item.image!,
                                                                width: 50,
                                                                height: 50,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                              subtitle: getOrderItem(
                                                                          item.id!) !=
                                                                      null
                                                                  ? Row(
                                                                      children: [
                                                                        IconButton(
                                                                            onPressed:
                                                                                () {
                                                                              if (getOrderItem(item.id!)!.productCount == 0) {
                                                                                return;
                                                                              }
                                                                              getOrderItem(item.id!)!.productCount = getOrderItem(item.id!)!.productCount! - 1;

                                                                              setStateEx(() {});
                                                                            },
                                                                            icon:
                                                                                const Icon(
                                                                              Icons.remove,
                                                                            )),
                                                                        Text(
                                                                            '${getOrderItem(item.id!)?.productCount}'),
                                                                        IconButton(
                                                                            onPressed:
                                                                                () {
                                                                              if (getOrderItem(item.id!)!.productCount == getOrderItem(item.id!)!.product!.stock) {
                                                                                return;
                                                                              }
                                                                              getOrderItem(item.id!)!.productCount = getOrderItem(item.id!)!.productCount! + 1;

                                                                              setStateEx(() {});
                                                                            },
                                                                            icon:
                                                                                const Icon(
                                                                              Icons.add,
                                                                            )),
                                                                      ],
                                                                    )
                                                                  : const SizedBox(),

                                                              // >>>>>>>>>>>>>old code for delete and add icon buttons

                                                              // trailing: getOrderItem(
                                                              //             item.id!) ==
                                                              //         null
                                                              //     ? IconButton(
                                                              //         onPressed: () {
                                                              //           onAddOrderItem(
                                                              //               item);
                                                              //           setStateEx(
                                                              //               () {});
                                                              //         },
                                                              //         icon: const Icon(
                                                              //           Icons.add,
                                                              //         ),
                                                              //       )
                                                              //     : IconButton(
                                                              //         onPressed: () {
                                                              //           onRemoveOrderItem(
                                                              //               item.id!);
                                                              //           setStateEx(
                                                              //             () {},
                                                              //           );
                                                              //         },
                                                              //         icon: const Icon(
                                                              //           Icons.delete,
                                                              //         ),
                                                              //       ),

                                                              // >>>>>>>>>>>>>>>>>>>>>>>>>>> the new one

                                                              trailing:
                                                                  IconButton(
                                                                onPressed: () {
                                                                  if (getOrderItem(
                                                                          item.id!) !=
                                                                      null) {
                                                                    onRemoveOrderItem(
                                                                        item.id!);
                                                                  } else {
                                                                    onAddOrderItem(
                                                                        item);
                                                                  }
                                                                  setStateEx(
                                                                      () {});
                                                                },
                                                                icon: getOrderItem(
                                                                            item.id!) ==
                                                                        null
                                                                    ? const Icon(
                                                                        Icons
                                                                            .add,
                                                                      )
                                                                    : const Icon(
                                                                        Icons
                                                                            .delete,
                                                                      ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    AppElevatedButton(
                                                        label: 'Done',
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        })
                                                  ],
                                                ),
                                              ),
                                      );
                                    });
                                  });
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.add,
                            ),
                          ),
                          const Text(
                            'Add Products',
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                color: primary.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                          'Order Items',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        for (var orderItem in selectedOrderItems)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text(
                                '${orderItem.product!.name ?? 'No Name'}, ${orderItem.productCount}X',
                              ),
                              leading: Image.network(
                                orderItem.product!.image ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              trailing: Text(
                                '${orderItem.productCount! * orderItem.product!.price!}',
                              ),
                            ),
                          ),
                        Text(
                          'Total Price : $calcTotalPrice',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        const Text('Discount 20%'),
                        const SizedBox(height: 10),
                        Text(
                          'Total Price After Discount: \$${calcDiscountedPrice.toString()}',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppElevatedButton(
                  label: 'Add Order',
                  onPressed: () async {
                    await onSetOrder();
                  })
            ],
          ),
        ),
      ),
    );
  }

  void onAddOrderItem(ProductData product) {
    var orderItem = OrderItem();
    orderItem.product = product;
    orderItem.productCount = 1;
    orderItem.productId = product.id;
    selectedOrderItems.add(orderItem);
    setState(() {});
  }

  void onRemoveOrderItem(int productId) {
    for (var i = 0; i < selectedOrderItems.length; i++) {
      if (selectedOrderItems[i].productId == productId) {
        selectedOrderItems.removeAt(i);
      }
    }
  }

  OrderItem? getOrderItem(int productId) {
    for (var orderItem in selectedOrderItems) {
      if (orderItem.productId == productId) {
        return orderItem;
      }
    }
    return null;
  }

  double? get calcTotalPrice {
    double totalPrice = 0.0;
    for (var orderItem in selectedOrderItems) {
      totalPrice =
          totalPrice + (orderItem.productCount! * orderItem.product!.price!);
    }
    return totalPrice;
  }

  Future<void> onSetOrder() async {
    try {
      if ((selectedOrderItems.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'You Must Add Order Items First',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        return;
      }

      var sqlHelper = GetIt.I.get<SqlHelper>();

      var orderId = await sqlHelper.db!
          .insert('orders', conflictAlgorithm: ConflictAlgorithm.replace, {
        'label': orderLabel,
        'totalPrice': calcTotalPrice,
        'discount': calcDiscountedPrice,
        'clientId': selectedClientId
      });
      var batch = sqlHelper.db!.batch();

      for (var orderItem in selectedOrderItems) {
        batch.insert('orderProductItems', {
          'orderId': orderId,
          'productId': orderItem.productId,
          'productCount': orderItem.productCount,
        });
      }
      var result = await batch.commit();

      log('>>>>>>>> orderProductItems$result');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Order Created Successfully',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error : $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  double get calcDiscountedPrice {
    return calcTotalPrice! * 0.8;
  }
}
