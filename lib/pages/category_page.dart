import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/helpers/sql_helper.dart';
import 'package:pos/models/category_data.dart';
import 'package:pos/pages/category_ops.dart';
import 'package:pos/utilities/my_palette.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<CategoryData> categories = [];

  @override
  void initState() {
    getCategory();
    super.initState();
  }

  Future<void> getCategory() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('categories');
      if (data.isNotEmpty) {
        categories = [];
        for (var item in data) {
          categories.add(
            CategoryData.fromJson(item),
          );
        }
      } else {
        categories = [];
      }

      log('>>>>>>>>>>>>>>>>>$data');
    } catch (e) {
      categories = [];
      log('Error in get categories : $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () async {
              var res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) {
                    return const CategoryOps();
                  },
                ),
              );
              if (res ?? false) {
                getCategory();
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: categories.isEmpty
            ? const Center(child: Text('No Data'))
            : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  var res = categories[index];
                  return Card(
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
                            subtitle: Text(
                              res.description ?? 'No description',
                              style: TextStyle(
                                  color: primary.shade400,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await onUpdate(res);
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: primary,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await onDeleteCategory(res);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> onDeleteCategory(CategoryData category) async {
    try {
      var confirmDelete = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: primary.shade50,
              title: const Text('Delete Category'),
              content:
                  const Text('Are you sure you want to delete this category?'),
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
          'categories',
          where: 'id =?',
          whereArgs: [category.id],
        );
        getCategory();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Failed to delete this category : ${category.name}',
          ),
        ),
      );
    }
  }

  Future<void> onUpdate(CategoryData category) async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) {
          return CategoryOps(
            category: category,
          );
        },
      ),
    );
    if (res ?? false) {
      getCategory();
    }
  }
}
