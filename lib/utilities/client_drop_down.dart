import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/helpers/sql_helper.dart';
import 'package:pos/models/client.dart';
import 'package:pos/utilities/my_palette.dart';

class ClientDropDown extends StatefulWidget {
  const ClientDropDown(
      {required this.onChanged, this.selectedValue, super.key});
  final int? selectedValue;
  final void Function(int?)? onChanged;

  @override
  State<ClientDropDown> createState() => _ClientDropDownState();
}

class _ClientDropDownState extends State<ClientDropDown> {
  List<Client> clients = [];
  bool isAscending = true;

  @override
  void initState() {
    getClient();
    super.initState();
  }

  Future<void> getClient() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('clients');
      if (data.isNotEmpty) {
        clients = [];
        for (var item in data) {
          clients.add(
            Client.fromJson(item),
          );
        }
      } else {
        clients = [];
      }

      log('>>>>>>>>>>>>>>>>>$data');
    } catch (e) {
      clients = [];

      log('Error in get the client : $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return clients.isEmpty
        ? const Center(
            child: Text(
              'No Clients Found',
              style: TextStyle(
                color: Colors.black,
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
                      border: Border.all(color: Colors.black),
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
                        hint: const Text(
                          'Choose Client',
                          style: TextStyle(color: Colors.black),
                        ),
                        iconEnabledColor: Colors.black,
                        items: [
                          for (var item in clients)
                            DropdownMenuItem(
                              value: item.id,
                              child: Text(
                                item.name ?? 'No Name',
                                style: const TextStyle(
                                  color: Colors.black,
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
