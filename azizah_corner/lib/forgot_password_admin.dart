import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'main.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    // Toggle the state of password visibility
    _obscurePassword = !_obscurePassword;
  }

  void _submitForm(BuildContext context) async {
    // Get values from controllers
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    // Basic validation
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sila masukkan nama pengguna, alamat e-mel, dan kata laluan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare data to send
    var data = {
      'username': username,
      'email': email,
      'password': password,
    };

    // URL of your API endpoint to update password
    var url = Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.forgotPasswordAdminPath}');

    try {
      // Send POST request
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      // Check response status code
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success']) {
          // Password updated successfully
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kata Laluan Berjaya Dikemaskini'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to previous page
          Navigator.pop(context); // Assuming this page was pushed from another page
        } else {
          // Handle error response from server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengemaskini kata laluan: ${jsonResponse['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Handle server error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghubungi pelayan untuk mengemaskini kata laluan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle any exceptions that occur during the HTTP request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ralat: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lupa Kata Laluan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nama Pengguna',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-mel',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Kata Laluan',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    // Toggle the password visibility
                    _togglePasswordVisibility();
                    // Update the state of the password field
                    // This will redraw the widget with the new visibility
                    // state of the password field.
                    (context as Element).markNeedsBuild();
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _submitForm(context);
              },
              child: Text('Kemaskini'),
            ),
          ],
        ),
      ),
    );
  }
}