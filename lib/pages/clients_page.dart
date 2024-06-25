import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/helpers/sql_helper.dart';
import 'package:pos/models/client.dart';
import 'package:pos/pages/clients_ops.dart';
import 'package:pos/utilities/my_palette.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  List<Client> clients = [];
  bool isAscending = true;
  String filterClients = '';

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

      log('Error in get categories : $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
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
                    return const ClientsOps();
                  },
                ),
              );
              if (res ?? false) {
                getClient();
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
            Row(children: [
              Expanded(
                flex: 4,
                child: TextFormField(
                  onChanged: (text) async {
                    if (text == '') {
                      await getClient();
                      return;
                    }

                    var sqlHelper = GetIt.I.get<SqlHelper>();
                    var data = await sqlHelper.db!.rawQuery("""
                      Select * from clients
                      where name like '%$text%'
                      """);
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
                    sortClients();
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
            ]),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: clients.isEmpty
                  ? const Center(child: Text('No Clients'))
                  : ListView.builder(
                      itemCount: clients.length,
                      itemBuilder: (context, index) {
                        var res = clients[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          color: primary.shade50,
                          child: Row(children: [
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      'Email: ${res.email ?? 'No email found'}',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Phone: ${res.phone ?? 'No Phone found'}',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Address: ${res.address ?? 'No address found'}',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                  ],
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primary.shade50,
                                  child: const Icon(Icons.person),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: primary),
                                      onPressed: () async {
                                        await onUpdateClient(res);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: primary),
                                      onPressed: () async {
                                        await onDeleteClient(res);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onDeleteClient(Client client) async {
    try {
      var confirmDelete = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: primary.shade50,
              title: const Text('Delete Client'),
              content:
                  const Text('Are you sure you want to delete this client?'),
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
          'clients',
          where: 'id =?',
          whereArgs: [client.id],
        );
        getClient();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Failed to delete this client : ${client.name}',
          ),
        ),
      );
    }
  }

  Future<void> onUpdateClient(Client client) async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) {
          return ClientsOps(
            client: client,
          );
        },
      ),
    );
    if (res ?? false) {
      getClient();
    }
  }

  void sortClients() {
    clients.sort((a, b) {
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

  Future<void> filteredCat(String filter) async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var result = await sqlHelper.db!.rawQuery("""
      SELECT * FROM clients 
      WHERE name LIKE '%$filter%' OR address LIKE '%$filter%'
      """);
      if (result.isNotEmpty) {
        clients = [];
        for (var item in result) {
          clients.add(Client.fromJson(item));
        }
      } else {
        clients = [];
      }
      setState(() {});
    } catch (e) {
      clients = [];
      log('Error in filtering clients : $e');
    }
  }

  void filterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String filterInput = filterClients;

        return AlertDialog(
          backgroundColor: primary.shade50,
          title: const Text(
            'Filter Categories',
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
                filterClients = filterInput;
                setState(() {});
                filteredCat(filterInput);
              },
            ),
          ],
        );
      },
    );
  }
}
