import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/helpers/sql_helper.dart';
import 'package:pos/models/category_data.dart';
import 'package:pos/utilities/app_elevated_button.dart';
import 'package:pos/utilities/app_text_field.dart';
import 'package:pos/utilities/my_palette.dart';
import 'package:sqflite/sqflite.dart';

class CategoryOps extends StatefulWidget {
  const CategoryOps({this.category, super.key});
  final CategoryData? category;

  @override
  State<CategoryOps> createState() => _CategoryOpsState();
}

class _CategoryOpsState extends State<CategoryOps> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    nameController = TextEditingController(text: widget.category?.name ?? '');
    descriptionController =
        TextEditingController(text: widget.category?.description ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add New' : 'Edit Category'),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            AppTextField(
              controller: nameController,
              label: 'Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
              border: getBorder(),
              focusedBorder: getBorder().copyWith(
                borderSide: BorderSide(
                  color: primary.shade400,
                  width: 2,
                ),
              ),
              enabledBorder: getBorder(),
              color: primary[400],
            ),
            AppTextField(
              controller: descriptionController,
              label: 'Description',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
              border: getBorder(),
              focusedBorder: getBorder().copyWith(
                borderSide: BorderSide(
                  color: primary.shade400,
                  width: 2,
                ),
              ),
              enabledBorder: getBorder(),
              color: primary[400],
            ),
            AppElevatedButton(
              label: widget.category == null ? 'Submit' : 'Edit Item',
              onPressed: () async {
                await onSubmit();
              },
            ),
          ],
        ),
      ),
    );
  }

  InputBorder getBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: primary),
      borderRadius: BorderRadius.circular(5),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.category == null) {
          sqlHelper.db!.insert(
              'categories',
              conflictAlgorithm: ConflictAlgorithm.replace,
              {
                'name': nameController.text,
                'description': descriptionController.text,
              });
        } else {
          await sqlHelper.db!.update(
              'categories',
              {
                'name': nameController.text,
                'description': descriptionController.text,
              },
              where: 'id=?',
              whereArgs: [widget.category!.id]);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.category == null
                ? 'Item added successfully'
                : 'Iten updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
