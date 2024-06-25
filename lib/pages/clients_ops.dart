import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/helpers/sql_helper.dart';
import 'package:pos/models/client.dart';
import 'package:pos/utilities/app_elevated_button.dart';
import 'package:pos/utilities/app_text_field.dart';
import 'package:pos/utilities/my_palette.dart';
import 'package:sqflite/sqflite.dart';

class ClientsOps extends StatefulWidget {
  const ClientsOps({this.client, super.key});
  final Client? client;

  @override
  State<ClientsOps> createState() => _ClientsOpsState();
}

class _ClientsOpsState extends State<ClientsOps> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    nameController = TextEditingController(text: widget.client?.name ?? '');
    emailController = TextEditingController(text: widget.client?.email ?? '');
    phoneController = TextEditingController(text: widget.client?.phone ?? '');
    addressController =
        TextEditingController(text: widget.client?.address ?? '');
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client == null ? 'Add New Client' : 'Edit Client'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppTextField(
                controller: nameController,
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
                keyboardType: TextInputType.name,
              ),
              AppTextField(
                controller: emailController,
                label: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  } else if (!value.contains('@')) {
                    return 'Enter a valid email';
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
                keyboardType: TextInputType.emailAddress,
              ),
              AppTextField(
                controller: phoneController,
                label: 'Phone',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone is required';
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
                keyboardType: TextInputType.phone,
              ),
              AppTextField(
                controller: addressController,
                label: 'Address',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Address is required';
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
                keyboardType: TextInputType.streetAddress,
              ),
              AppElevatedButton(
                label: widget.client == null ? 'Submit' : 'Save changes',
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
        if (widget.client == null) {
          sqlHelper.db!
              .insert('clients', conflictAlgorithm: ConflictAlgorithm.replace, {
            'name': nameController.text,
            'email': emailController.text,
            'phone': phoneController.text,
            'address': addressController.text,
          });
        } else {
          await sqlHelper.db!.update(
              'clients',
              {
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
                'address': addressController.text,
              },
              where: 'id=?',
              whereArgs: [widget.client!.id]);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.client == null
                ? 'Client added successfully'
                : 'Client updated successfully'),
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
