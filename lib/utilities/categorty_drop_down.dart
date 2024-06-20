import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/helpers/sql_helper.dart';
import 'package:pos/models/category_data.dart';
import 'package:pos/utilities/my_palette.dart';

class CategortyDropDown extends StatefulWidget {
  const CategortyDropDown(
      {required this.onChanged, this.selectedValue, super.key});
  final int? selectedValue;
  final void Function(int?)? onChanged;

  @override
  State<CategortyDropDown> createState() => _CategortyDropDownState();
}

class _CategortyDropDownState extends State<CategortyDropDown> {
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
    return categories.isEmpty
        ? const Center(
            child: Text(
              'No categories found',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: primary),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: DropdownButton(
                        value: widget.selectedValue,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: primary.shade50,
                        hint: Text(
                          'Choose Category',
                          style: TextStyle(color: primary.shade400),
                        ),
                        iconEnabledColor: primary,
                        items: [
                          for (var item in categories)
                            DropdownMenuItem(
                              value: item.id,
                              child: Text(
                                item.name ?? 'No Name',
                                style: const TextStyle(
                                  color: primary,
                                ),
                              ),
                            ),
                        ],
                        onChanged: widget.onChanged,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
