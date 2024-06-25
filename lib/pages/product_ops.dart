import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/helpers/sql_helper.dart';
import 'package:pos/models/product_data.dart';
import 'package:pos/utilities/app_elevated_button.dart';
import 'package:pos/utilities/app_text_field.dart';
import 'package:pos/utilities/categorty_drop_down.dart';
import 'package:pos/utilities/my_palette.dart';
import 'package:sqflite/sqflite.dart';

class ProductOps extends StatefulWidget {
  const ProductOps({this.product, super.key});
  final ProductData? product;

  @override
  State<ProductOps> createState() => _ProductOpsState();
}

class _ProductOpsState extends State<ProductOps> {
  bool? isAvailable;
  int? selectedCategoryId;
  late TextEditingController productNameController;
  late TextEditingController productDescriptionController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController imageController;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    productNameController =
        TextEditingController(text: widget.product?.name ?? '');
    productDescriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    priceController =
        TextEditingController(text: '${widget.product?.price ?? ''}');
    stockController =
        TextEditingController(text: '${widget.product?.stock ?? ''}');
    imageController = TextEditingController(text: widget.product?.image ?? '');
    selectedCategoryId = widget.product?.categoryId;
    isAvailable = widget.product?.isAvailable;
    super.initState();
  }

  @override
  void dispose() {
    productNameController.dispose();
    productDescriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add New' : 'Edit Product'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppTextField(
                controller: productNameController,
                label: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
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
                controller: productDescriptionController,
                label: 'Description',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
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
                controller: imageController,
                label: 'Image URL',
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
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: priceController,
                      label: 'Price',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Price is required';
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
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  Expanded(
                    child: AppTextField(
                      controller: stockController,
                      label: 'Stock',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stock is required';
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
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              CategortyDropDown(
                selectedValue: selectedCategoryId,
                onChanged: (value) {
                  selectedCategoryId = value;
                  setState(() {});
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAvailable ?? false ? 'Available' : 'Not available',
                      style: TextStyle(
                          color:
                              isAvailable ?? false ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 18),
                    ),
                    Switch(
                      inactiveTrackColor: primary.shade200,
                      focusColor: primary,
                      value: isAvailable ?? false,
                      onChanged: (value) {
                        isAvailable = value;
                        setState(() {});
                      },
                    )
                  ],
                ),
              ),
              AppElevatedButton(
                label: widget.product == null ? 'Submit' : 'Edit Item',
                onPressed: () async {
                  await onSubmit();
                },
              ),
            ],
          ),
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
        if (widget.product == null) {
          sqlHelper.db!.insert(
              'products',
              conflictAlgorithm: ConflictAlgorithm.replace,
              {
                'name': productNameController.text,
                'description': productDescriptionController.text,
                'price': double.parse(priceController.text),
                'stock': int.parse(stockController.text),
                'image': imageController.text,
                'categoryId': selectedCategoryId,
                'isAvailable': isAvailable ?? false,
              });
        } else {
          await sqlHelper.db!.update(
              'products',
              {
                'name': productNameController.text,
                'description': productDescriptionController.text,
                'price': double.parse(priceController.text),
                'stock': int.parse(stockController.text),
                'image': imageController.text,
                'categoryId': selectedCategoryId,
                'isAvailable': isAvailable,
              },
              where: 'id=?',
              whereArgs: [widget.product!.id]);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null
                ? 'Item added successfully'
                : 'Item updated successfully'),
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
