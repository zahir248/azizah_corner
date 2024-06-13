import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'customer_dashboard.dart';
import 'customer_registration.dart';
import 'forgot_password_customer.dart';
import 'main.dart';

class CustomerLoginPage extends StatefulWidget {
  @override
  _CustomerLoginPageState createState() => _CustomerLoginPageState();
}

class _CustomerLoginPageState extends State<CustomerLoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  Future<void> login(BuildContext context) async {
    // Get the values entered by the user
    String username = usernameController.text;
    String password = passwordController.text;

    // Check if username or password is empty
    if (username.isEmpty || password.isEmpty) {
      // Display a Snackbar for empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tolong masukkan nama dan kata laluan anda'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Return from the function
    }

    // Replace with your actual URL for customer login API
    String url = 'http://${AppConfig.baseIpAddress}${AppConfig.customerLoginPath}';

    try {
      // Send the data to the server
      var response = await http.post(
        Uri.parse(url),
        body: {'username': username, 'password': password},
      );

      // Check the response from the server
      if (response.statusCode == 200) {
        // Parse the JSON response
        var responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          // Show a success Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Log masuk berjaya'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to the customer dashboard page with customer_id
          int customer_id = responseData['customer_id'];
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CustomerDashboardPage(customerId: customer_id)),
          );
        } else {
          // Show an error Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Log masuk tidak berjaya'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Request failed
        print('Failed to login. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle exception/error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Masuk Pelanggan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Nama Pengguna',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Kata Laluan',
                border: OutlineInputBorder(),
                suffixIcon: GestureDetector(
                  onTap: () {
                    // Toggle password visibility
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56.0,
              child: ElevatedButton(
                onPressed: () {
                  // Call the login function and pass the BuildContext
                  login(context);
                },
                child: Text('Log Masuk'),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tiada akaun? ',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1!.color,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomerRegistrationPage()),
                    );
                    },
                  child: Text(
                    'Daftar',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                );              },
              child: Text(
                'Lupa Kata Laluan',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}