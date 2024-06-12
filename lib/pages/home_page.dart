import 'package:flutter/material.dart';
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

  @override
  void initState() {
    nameController = TextEditingController();
    passController = TextEditingController();
    super.initState();
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
            const Text(
              'Welcome',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w300),
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
              style: const TextStyle(fontSize: 16, color: Colors.white),
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
              style: const TextStyle(fontSize: 16, color: Colors.white),
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
            ElevatedButton(
                style: ElevatedButton.styleFrom(
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
                child: const Text('Log In'))
          ],
        ),
      ),
    );
  }

  InputBorder? getBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(20),
    );
  }
}
