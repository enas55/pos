import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/helpers/sql_helper.dart';
import 'package:pos/models/product_data.dart';
import 'package:pos/pages/product_ops.dart';
import 'package:pos/utilities/my_palette.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<ProductData> products = [];
  bool isAscending = true;
  String filteredProducts = '';

  @override
  void initState() {
    getProduct();
    super.initState();
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: filterDialog,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () async {
              var res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) {
                    return const ProductOps();
                  },
                ),
              );
              if (res ?? false) {
                getProduct();
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    onChanged: (text) async {
                      if (text == '') {
                        await getProduct();
                        return;
                      }

                      var sqlHelper = GetIt.I.get<SqlHelper>();
                      var data = await sqlHelper.db!.rawQuery("""
                      Select * from products
                      where name like '%$text%' or description like '%$text%'
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
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      label: const Text(
                        'Search',
                        style: TextStyle(
                          color: primary,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: primary,
                      ),
                      border: getBorder(),
                      enabledBorder: getBorder(),
                      focusedBorder: getBorder().copyWith(
                        borderSide: BorderSide(
                          color: primary.shade400,
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: primary[400],
                    ),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      sortProducts();
                    },
                    icon: const Icon(
                      Icons.sort_by_alpha_rounded,
                      color: primary,
                    ),
                  ),
                ),
                Text(
                  isAscending ? 'From (Z-A)' : 'From (A-Z)',
                  style: const TextStyle(color: primary, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text('No Data'))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        var res = products[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          color: primary.shade50,
                          child: Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: Text(
                                    res.name ?? 'No name',
                                    style: const TextStyle(
                                        color: primary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        res.description ?? 'No Description',
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Price: ${res.price!.toString()}',
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Stock: ${res.stock ?? 0}',
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Available: ${res.isAvailable == true ? 'Yes' : 'No'}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: res.isAvailable == true
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Category : ${res.categoryName ?? 'No Category'}',
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  leading:

                                      // res.image != null
                                      //     ? Image.network(
                                      //         res.image!,
                                      //         width: 50,
                                      //         height: 50,
                                      //         fit: BoxFit.cover,
                                      //       )
                                      //     : Container(
                                      //         width: 50,
                                      //         height: 50,
                                      //         child: const Icon(Icons.image,
                                      //             color: primary),
                                      //       ),

                                      Image.network(
                                    res.image!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: primary),
                                        onPressed: () async {
                                          await onUpdateProduct(res);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: primary),
                                        onPressed: () async {
                                          await onDeleteProduct(res);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Expanded(
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.end,
                              //     children: [
                              //       IconButton(
                              //         onPressed: () async {
                              //           // await onUpdateCategory(res);
                              //         },
                              //         icon: const Icon(
                              //           Icons.edit,
                              //           color: primary,
                              //         ),
                              //       ),
                              //       IconButton(
                              //         onPressed: () async {
                              //           // await onDeleteCategory(res);
                              //         },
                              //         icon: const Icon(
                              //           Icons.delete,
                              //           color: primary,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onDeleteProduct(ProductData product) async {
    try {
      var confirmDelete = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: primary.shade50,
              title: const Text('Delete Category'),
              content:
                  const Text('Are you sure you want to delete this product?'),
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
          'products',
          where: 'id =?',
          whereArgs: [product.id],
        );
        getProduct();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Failed to delete this product : ${product.name}',
          ),
        ),
      );
    }
  }

  Future<void> onUpdateProduct(ProductData product) async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) {
          return ProductOps(
            product: product,
          );
        },
      ),
    );
    if (res ?? false) {
      getProduct();
    }
  }

  void sortProducts() {
    products.sort((a, b) {
      return isAscending
          ? a.name!.compareTo(b.name!)
          : b.name!.compareTo(a.name!);
    });
    isAscending = !isAscending;
    setState(() {});
  }

  InputBorder getBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: primary),
      borderRadius: BorderRadius.circular(5),
    );
  }

  Future<void> filteredPro(String filter) async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var result = await sqlHelper.db!.rawQuery("""
      SELECT * FROM products 
      WHERE name LIKE '%$filter%''
      """);
      if (result.isNotEmpty) {
        products = [];
        for (var item in result) {
          products.add(ProductData.fromJson(item));
        }
      } else {
        products = [];
      }
      setState(() {});
    } catch (e) {
      products = [];
      log('Error in filtering categories : $e');
    }
  }

  void filterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String filterInput = filteredProducts;

        return AlertDialog(
          backgroundColor: primary.shade50,
          title: const Text(
            'Filter Products',
            style: TextStyle(color: primary),
          ),
          content: TextField(
            onChanged: (value) {
              filterInput = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter filter text',
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Filter'),
              onPressed: () {
                Navigator.of(context).pop();
                filteredProducts = filterInput;
                setState(() {});
                filteredPro(filterInput);
              },
            ),
          ],
        );
      },
    );
  }
}
