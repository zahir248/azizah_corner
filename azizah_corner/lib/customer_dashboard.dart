import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'cart.dart';
import 'main.dart';

class CustomerDashboardPage extends StatefulWidget {
  final int customerId; // Accept customer_id as a parameter

  CustomerDashboardPage({required this.customerId});

  @override
  _CustomerDashboardPageState createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  List<dynamic> products = [];
  bool isLoading = false;
  int cartItemCount = 0; // Added cart item count
  String username = ''; // Variable to store username

  @override
  void initState() {
    super.initState();
    fetchCustomerDetails(); // Fetch customer details on init
    fetchProducts();
    fetchCartItemCount(); // Fetch cart item count on init
  }

  Future<void> fetchCustomerDetails() async {
    var url = Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.getCustomerDetailsPath}?customer_id=${widget.customerId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          username = jsonData['username']; // Assuming the API response has a 'username' field
        });
        print('Username received from server: $username'); // Debug line to print username
      } else {
        throw Exception('Failed to load customer details');
      }
    } catch (error) {
      // Handle error
      print('Error fetching customer details: $error');
    }
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.fetchProductsMenuPath}'));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // Handle error
      print(error.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to load products. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> addToCart(String productName, double productPrice) async {
    final url = Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.addToCartPath}');
    try {
      final response = await http.post(
        url,
        body: {
          'customer_id': widget.customerId.toString(),
          'name': productName,
          'price': productPrice.toString(),
        },
      );
      if (response.statusCode == 200) {
        // Product added successfully, display a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$productName Telah Ditambah Ke Dalam Troli'),
            duration: Duration(seconds: 3), // Adjust duration as needed
            backgroundColor: Colors.green,
          ),
        );
        // Increment cart item count when a product is added
        setState(() {
          cartItemCount++;
        });
      } else {
        throw Exception('Gagal untuk ditambah ke dalam troli');
      }
    } catch (error) {
      // Handle error
      print('Error adding product to cart: $error');
    }
  }

  Future<void> fetchCartItemCount() async {
    final url = Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.getCartItemCountPath}?customer_id=${widget.customerId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          cartItemCount = int.parse(response.body);
        });
        print('Cart item count received from server: $cartItemCount');
      } else {
        throw Exception('Failed to fetch cart item count');
      }
    } catch (error) {
      // Handle error
      print('Error fetching cart item count: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Menu Produk - $username'), // Display username in the title
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  // Navigate to the cart page with customer_id
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(customerId: widget.customerId),
                    ),
                  );
                },
              ),
              Positioned(
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Text(
                    cartItemCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Show logout confirmation dialog
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
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // You can adjust the number of columns as needed
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4, // Add elevation to the card
            child: Container(
              height: 500, // Increase height to 400 (adjust as needed)
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(4.0), // Reduce padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Display product image if available
                      products[index]['image'] != null
                          ? Image.memory(
                        base64Decode(products[index]['image']),
                        width: 90, // Adjust width as needed
                        height: 90, // Adjust height as needed
                        fit: BoxFit.cover,
                      )
                          : Container(), // Placeholder if image is not available
                      SizedBox(height: 3), // Add space between image and text
                      Text(
                        products[index]['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // Reduce font size
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2), // Add space between text and price
                      Text(
                        'RM ${products[index]['price']}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12, // Reduce font size
                        ),
                        textAlign: TextAlign.center,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Show alert message before adding to cart
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Tambah Ke Troli'),
                                content: Text(
                                    'Adakah anda mahu tambah ${products[index]['name']} ke dalam troli?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Call addToCart function
                                      addToCart(
                                        products[index]['name'],
                                        double.parse(products[index]['price']),
                                      );
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: Text('Tambah'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Tambah ke Troli'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}