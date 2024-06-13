import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'customer_login.dart';
import 'main.dart';

class CustomerRegistrationPage extends StatefulWidget {
  @override
  _CustomerRegistrationPageState createState() => _CustomerRegistrationPageState();
}

class _CustomerRegistrationPageState extends State<CustomerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isObscure = true; // State variable to toggle password visibility

  String _errorMessage = ''; // State variable to hold error message

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  Future<void> _registerCustomer() async {
    if (_formKey.currentState!.validate()) {
      // Prepare data to send
      var data = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      // Replace with your API endpoint for customer registration
      var url = Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.registerCustomerPath}');

      try {
        // Send POST request
        var response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );

        // Handle response
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['success']) {
            // Registration successful
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Pendaftaran Pelanggan Berjaya'),
                backgroundColor: Colors.green,
              ),
            );
            _usernameController.clear();
            _passwordController.clear();
            _emailController.clear();

            // Navigate to Customer DashboardPage on success
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomerLoginPage()),
            );
          } else {
            // Registration failed due to username already existing or other reason
            setState(() {
              _errorMessage = jsonResponse['message'] ?? 'Gagal mendaftar pelanggan';
            });
          }
        } else {
          // Failed to connect to server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mendaftar pelanggan'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pendaftaran Pelanggan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Nama Pengguna'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sila masukkan nama pengguna';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'E-mel'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sila masukkan alamat e-mel';
                  }
                  // Simple email validation
                  if (!value.contains('@')) {
                    return 'Sila masukkan alamat e-mel yang sah';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Kata Laluan',
                  suffixIcon: GestureDetector(
                    onTap: _togglePasswordVisibility,
                    child: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                ),
                obscureText: _isObscure,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sila masukkan kata laluan';
                  }
                  return null;
                },
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity, // Set width to match parent width
                child: ElevatedButton(
                  onPressed: _registerCustomer,
                  child: Text('Daftar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}