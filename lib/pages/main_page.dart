import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/helpers/sql_helper.dart';
import 'package:pos/pages/all_sales_page.dart';
import 'package:pos/pages/category_page.dart';
import 'package:pos/pages/home_page.dart';
import 'package:pos/utilities/drawer_text_button.dart';
import 'clients_page.dart';
import 'package:pos/pages/products_page.dart';
import 'package:pos/pages/sales_ops_page.dart';
import 'package:pos/utilities/grid_view_items.dart';
import 'package:pos/utilities/my_palette.dart';

class MainPage extends StatefulWidget {
  const MainPage({required this.userName, super.key});
  final String userName;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double todaysSales = 0;
  double egpToUsdRate = 0;
  TextEditingController textFieldController = TextEditingController();
  bool isLoggedIn = true;

  Future<double> calcTodaySales() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();

      var result = await sqlHelper.db!
          .rawQuery("SELECT SUM(totalPrice) as totalSales FROM orders");

      if (result.isNotEmpty && result.first['totalSales'] != null) {
        double totalSales = (result.first['totalSales'] as double).toDouble();
        log('Today\'s sales: $totalSales');
        return totalSales;
      } else {
        log('No sales data found for today');
        return 0.0;
      }
    } catch (e) {
      log('Error in calculating today\'s sales: $e');
      return 0.0;
    }
  }

  Future<void> getTodaySales() async {
    try {
      double sales = await calcTodaySales();
      todaysSales = sales;
      setState(() {});
    } catch (e) {
      log('Error in today\'s sales: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getTodaySales();
    getExchangeRate();
  }

  Future<void> getExchangeRate() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      await sqlHelper.db!.rawQuery("""
      INSERT INTO exchangeRate (currency, exchangeRate) VALUES 
        ('EGP', 0.021); 
      """);

      var data = await sqlHelper.db!.query(
        'exchangeRate',
        where: 'currency = ?',
        whereArgs: ['EGP'],
      );

      if (data.isNotEmpty) {
        String exchangeRateString = data.first['exchangeRate'] as String;
        egpToUsdRate = double.parse(exchangeRateString);
        setState(() {});
        log('EGP to USD exchange rate: $egpToUsdRate');
      } else {
        log('No exchange rate found for EGP');
      }
    } catch (e) {
      log('Error in getting exchange rate: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primary.shade100,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      foregroundColor: primary.shade100,
                      child: const Icon(Icons.person),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Welcome, ${widget.userName}.',
                      style: const TextStyle(
                        color: primary,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DrawerTextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icons.home,
              data: 'Home',
            ),
            DrawerTextButton(
              onPressed: () {
                logout();
              },
              icon: Icons.logout,
              data: 'Log Out',
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          Container(
            color: primary[800],
            height: MediaQuery.of(context).size.height / 3,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Point of sale',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  getCard('Exchange rate',
                      '1 EGP = ${egpToUsdRate.toString()} USD'),
                  const SizedBox(
                    height: 10,
                  ),
                  getCard(
                      'Today\'s sales', '\$ ${todaysSales.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                color: Colors.white,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    GridViewItems(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) {
                              return const AllSalesPage();
                            },
                          ),
                        );
                      },
                      label: 'All sales',
                      icon: Icons.calculate,
                      color: Colors.orange,
                    ),
                    GridViewItems(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) {
                              return const ProductsPage();
                            },
                          ),
                        );
                      },
                      label: 'Products',
                      icon: Icons.inventory,
                      color: Colors.pink,
                    ),
                    GridViewItems(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) {
                              return const ClientsPage();
                            },
                          ),
                        );
                      },
                      label: 'Clients',
                      icon: Icons.group,
                      color: Colors.lightBlue,
                    ),
                    GridViewItems(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) {
                              return const SalesOpsPage();
                            },
                          ),
                        );
                      },
                      label: 'New sale',
                      icon: Icons.point_of_sale,
                      color: Colors.green,
                    ),
                    GridViewItems(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) {
                              return const CategoryPage();
                            },
                          ),
                        );
                      },
                      label: 'Category',
                      icon: Icons.category,
                      color: Colors.yellow,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getCard(String label, String text) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: primary.shade400.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: primary.shade50,
          title: const Text(
            'Log Out',
            style: TextStyle(color: primary),
          ),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Log Out'),
              onPressed: () {
                isLoggedIn = false;
                setState(() {});
                textFieldController.clear();
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) {
                      return const HomePage();
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
