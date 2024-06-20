import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/helpers/sql_helper.dart';
import 'package:pos/pages/main_page.dart';
import 'package:pos/utilities/app_text_field.dart';
import 'package:pos/utilities/my_palette.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController nameController;
  late TextEditingController passController;

  var formKey = GlobalKey<FormState>();

  bool isVisible = true;

  bool isLoading = true;
  bool result = false;

  @override
  void initState() {
    init();
    isLoading = false;
    nameController = TextEditingController();
    passController = TextEditingController();
    super.initState();
  }

  void init() async {
    result = await GetIt.I.get<SqlHelper>().createTables();
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary[500],
      body: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Welcome',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                isLoading
                    ? Transform.scale(
                        scale: 0.15,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : CircleAvatar(
                        radius: 10,
                        backgroundColor: result ? Colors.green : Colors.red,
                      ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Image.asset(
              'images/play_store_512.png',
              width: 100,
              height: 70,
            ),
            AppTextField(
              controller: nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name.';
                }
                return null;
              },
              label: 'name',
              border: getBorder(),
              enabledBorder: getBorder(),
              focusedBorder: getBorder(),
              color: Colors.white,
            ),
            AppTextField(
              controller: passController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                } else if (value.length < 10) {
                  return 'Password must be more than 10 characters';
                }
                return null;
              },
              label: 'Password',
              obscureText: isVisible,
              border: getBorder(),
              enabledBorder: getBorder(),
              focusedBorder: getBorder(),
              color: Colors.white,
              keyboardType: TextInputType.visiblePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  isVisible = !isVisible;
                  setState(() {});
                },
                icon: Icon(
                  isVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(double.maxFinite, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(20),
                  ),
                  onPressed: () {
                    try {
                      if (formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) {
                              return const MainPage();
                            },
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logged in successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                      setState(() {});
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to log in : $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Log In')),
            )
          ],
        ),
      ),
    );
  }

  InputBorder? getBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(5),
    );
  }
}
