// cart_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'customer_dashboard.dart';
import 'order.dart';  // Import the OrderPage
import 'cart_item.dart';  // Import the CartItem
import 'main.dart';

class CartPage extends StatefulWidget {
  final int customerId; // Add customer_id parameter

  CartPage({required this.customerId}); // Modify constructor to accept customer_id

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];
  bool isLoading = false;
  String? errorMessage; // Add a variable to hold error message

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null; // Reset error message
    });
    var url = Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.getCartItemsPath}?customer_id=${widget.customerId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          cartItems = responseData.map((item) => CartItem.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch cart items: ${response.reasonPhrase}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching cart items: $error'; // Update error message
      });
      // Handle error
      print(errorMessage);
    }
  }

  Future<void> deleteCartItem(int cartId) async {
    var url = Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.deleteCartItemPath}');
    try {
      final response = await http.post(
        url,
        body: {
          'cart_id': cartId.toString(),
          'customer_id': widget.customerId.toString(), // Include customer_id
        },
      );
      if (response.statusCode == 200) {
        // Item deleted successfully, display a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item Berjaya Dibuang Daripada Troli'),
            duration: Duration(seconds: 3), // Adjust duration as needed
            backgroundColor: Colors.green,
          ),
        );
        // Remove the item from the list
        setState(() {
          cartItems.removeWhere((item) => item.cartId == cartId);
        });
      } else {
        throw Exception('Failed to delete cart item: ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle error
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting cart item: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
      print('Error deleting cart item: $error');
    }
  }

  double getTotalPrice() {
    double totalPrice = 0.0;
    for (var item in cartItems) {
      totalPrice += item.price * item.quantity;
    }
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Troli'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomerDashboardPage(customerId: widget.customerId)),
            );
          },
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : errorMessage != null
          ? Center(
        child: Text(errorMessage!),
      )
          : cartItems.isEmpty
          ? Center(
        child: Text('Tiada item di dalam troli'),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(cartItems[index].name),
                    subtitle: Text('RM ${cartItems[index].price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (cartItems[index].quantity > 1) {
                                cartItems[index].quantity--;
                              }
                            });
                          },
                        ),
                        Text(
                          cartItems[index].quantity.toString(),
                          style: TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              cartItems[index].quantity++;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Kepastian'),
                                  content: Text('Adakah anda pasti ingin membuang item ini daripada troli?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Call deleteCartItem function
                                        deleteCartItem(cartItems[index].cartId);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Buang'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white, // Set background color to white
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Jumlah : RM ${getTotalPrice().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(width: 20), // Add some space between the total price and the button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderPage(
                          cartItems: cartItems,
                          totalPrice: getTotalPrice(),
                          customerId: widget.customerId, // Pass customerId
                        ),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0), // Adjust padding as needed
                    child: Text(
                      'Buat Pesanan',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 20), // Add space between the text and the button
              ],
            ),
          ),
        ],
      ),
    );
  }
}