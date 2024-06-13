import 'package:flutter/material.dart';
import 'manage_product.dart';
import 'manage_order.dart';

import 'admin_registration.dart'; // Import the AdminRegistrationPage

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back arrow button
        title: Text('Halaman Pentadbir'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Add the logout icon
            onPressed: () {
              // Show an alert dialog to confirm logout
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Sahkan Log Keluar'),
                    content: Text('Adakah anda pasti anda mahu log keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate back to HomePage() and remove all routes until HomePage
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                                (route) => false, // Remove all routes
                          );
                        },
                        child: Text('Log Keluar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 50), // Add space between appbar and sections
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to the ManageProductPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ManageProductPage()),
                          );
                        },
                        child: SizedBox(
                          height: 150, // Set the height of the white section
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart, size: 40), // Set icon size to 40
                                SizedBox(height: 10),
                                Text(
                                  'Pengurusan Produk',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20), // Add space between sections
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to the ManageOrderPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ManageOrderPage()), // Replace with your ManageOrderPage
                          );
                        },
                        child: SizedBox(
                          height: 150, // Set the height of the white section
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.assignment, size: 40), // Set icon size to 40
                                SizedBox(height: 10),
                                Text(
                                  'Pengurusan Pesanan',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20), // Add space between rows
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to the AdminRegistrationPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AdminRegistrationPage()),
                          );
                        },
                        child: SizedBox(
                          height: 150, // Set the height of the white section
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add, size: 40), // Set icon size to 40
                                SizedBox(height: 10),
                                Text(
                                  'Pendaftaran Pentadbir',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20), // Add space for symmetry, if you plan to add more sections
                    Expanded(
                      child: SizedBox.shrink(), // Placeholder for future use
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
