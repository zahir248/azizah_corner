import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'admin_dashboard.dart';
import 'forgot_password_admin.dart'; // Import your ForgotPasswordPage
import 'main.dart';

class AdminLoginPage extends StatefulWidget {
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
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

    // URL of your PHP server
    String url = 'http://${AppConfig.baseIpAddress}${AppConfig.loginPath}';

    // Send the data to the server
    var response = await http.post(
      Uri.parse(url),
      body: {'username': username, 'password': password},
    );

    // Check the response from the server
    if (response.statusCode == 200) {
      // Request was successful
      // Handle the response data here
      print('Response: ${response.body}');

      if (response.body == 'Login successful') {
        // Show a success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Log masuk berjaya'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to the dashboard page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Masuk Pentadbir'),
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
              width: double.infinity, // Set the button width to fill available space
              height: 56.0, // Set the height to match the text fields
              child: ElevatedButton(
                onPressed: () {
                  // Call the login function and pass the BuildContext
                  login(context);
                },
                child: Text('Log Masuk'),
              ),
            ),
            SizedBox(height: 20), // Add spacing between the texts
            GestureDetector(
              onTap: () {
                // Navigate to Forgot Password Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                );
              },
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