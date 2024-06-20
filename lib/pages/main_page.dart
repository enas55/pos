import 'package:flutter/material.dart';
import 'package:pos/pages/all_sales_page.dart';
import 'package:pos/pages/category_page.dart';
import 'package:pos/pages/clients_page.dart';
import 'package:pos/pages/new_sale_page.dart';
import 'package:pos/pages/products_page.dart';
import 'package:pos/utilities/grid_view_items.dart';
import 'package:pos/utilities/my_palette.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
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
                  getCard('Exchange rate', '1 EUR = 11,712 UZS'),
                  const SizedBox(
                    height: 10,
                  ),
                  getCard('Today\'s sales', '110,000.00 UZS'),
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
                              return const NewSalePage();
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
}
