import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'main.dart';

class ManageOrderPage extends StatefulWidget {
  @override
  _ManageOrderPageState createState() => _ManageOrderPageState();
}

class _ManageOrderPageState extends State<ManageOrderPage> {
  List<dynamic> orders = []; // List to hold orders

  @override
  void initState() {
    super.initState();
    fetchOrders(); // Fetch orders when page initializes
  }

  void fetchOrders() async {
    final url = Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.fetchOrdersPath}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse JSON data
      setState(() {
        orders = json.decode(response.body);
      });
    } else {
      // If there is an error fetching data, print error message
      print('Failed to load orders');
    }
  }

  void showOrderDetails(int index) {
    // Parse 'price' and 'quantity' from String to double
    double price = double.parse(orders[index]['price'].toString());
    int quantity = int.parse(orders[index]['quantity'].toString());

    // Calculate total price
    double totalPrice = price * quantity;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Resit Pembayaran'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8),
              Text('ID Pesanan: ${orders[index]['order_id']}'),
              SizedBox(height: 8),
              Text('Tarikh: ${orders[index]['created_at']}'),
              SizedBox(height: 30),
              Text('Nama Pelanggan: ${orders[index]['customer_name']}'),
              SizedBox(height: 8),
              Text('Harga: RM ${price.toStringAsFixed(2)}'), // Format price to two decimal places
              SizedBox(height: 8),
              Text('Kuantiti: $quantity'),
              SizedBox(height: 30),
              Text('Jumlah Bayaran: RM ${totalPrice.toStringAsFixed(2)}'), // Format total price to two decimal places
              SizedBox(height: 8),
              Text('Status: Sudah Buat Pembayaran'),
              SizedBox(height: 16),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void showOrderInformation(int index) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Maklumat Pesanan'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8),
              Text('Nama Pelanggan: ${orders[index]['customer_name']}'),
              SizedBox(height: 8),
              Text('Meja: ${orders[index]['table']}'),
              SizedBox(height: 30),
              Text('Nama Produk: ${orders[index]['name']}'),
              SizedBox(height: 8),
              Text('Kuantiti: ${orders[index]['quantity']}'),
              SizedBox(height: 30),
              Text('Status: ${orders[index]['status']}'),
              SizedBox(height: 16),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteOrder(int index) async {
    final orderId = orders[index]['order_id']; // Retrieve order_id from orders list

    try {
      final url = Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.deleteOrderPath}');

      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'order_id': orderId}),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // If deletion is successful, remove the order from the list
        setState(() {
          orders.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan berjaya dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // If there is an error deleting the order, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus pesanan')),
        );
      }
    } catch (e) {
      print('Error deleting order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ralat: Gagal menghapus pesanan')),
      );
    }
  }

  void updateOrderStatus(int index, String newStatus) async {
    final orderId = orders[index]['order_id'];

    try {
      final url = Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.updateOrderStatusPath}');

      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'order_id': orderId, 'status': newStatus}),
      );

      if (response.statusCode == 200) {
        // If update is successful, update the status in the orders list
        setState(() {
          orders[index]['status'] = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status Pesanan Berjaya Dikemaskini'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // If there is an error updating the status, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengemaskini status pesanan')),
        );
      }
    } catch (e) {
      print('Error updating order status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ralat: Gagal mengemaskini status pesanan')),
      );
    }
  }

  void showEditStatusDialog(int index) {
    bool isServed = false; // Initial state of the checkbox

    showDialog(
      barrierDismissible: false, // Prevents dialog from being dismissed when clicking outside
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Kemaskini Status Pesanan'),
              content: Row(
                children: [
                  Checkbox(
                    value: isServed,
                    onChanged: (bool? value) {
                      setState(() {
                        isServed = value!;
                      });
                    },
                  ),
                  Text('Sudah Dihidang'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Kemaskini'),
                  onPressed: isServed
                      ? () {
                    String newStatus = isServed ? 'Sudah Dihidang' : 'Belum Dihidang';
                    updateOrderStatus(index, newStatus);
                    Navigator.of(context).pop();
                  }
                      : null, // Disable button if checkbox is not ticked
                  style: TextButton.styleFrom(
                    primary: isServed ? null : Colors.grey, // Change color to indicate disabled state
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengurusan Pesanan'),
      ),
      body: orders.isEmpty
          ? Center(child: Text('Tiada Pesanan Buat Masa Sekarang')) // Display message if no orders
          : Padding(
        padding: const EdgeInsets.only(top: 8.0),
        // Adjust the top padding as needed
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(orders[index]['customer_name']),
                // Display customer name
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text('Harga: RM ${orders[index]['price']}'),
                    // Display price
                    SizedBox(height: 4),
                    Text('Status: ${orders[index]['status']}'),
                    // Display status
                    SizedBox(height: 8),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.receipt), // Receipt icon
                      onPressed: () {
                        // Handle receipt action
                        showOrderDetails(
                            index); // Call method to show details
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.info), // Order Information icon
                      onPressed: () {
                        // Handle order information action
                        showOrderInformation(index);
                        // Call method to show order information
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit), // Edit icon
                      onPressed: () {
                        // Handle edit action
                        showEditStatusDialog(index);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete), // Delete icon
                      onPressed: () {
                        // Handle delete action
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Padam Pesanan'),
                              content: Text(
                                  'Anda pasti untuk padam pesanan ini?'),
                              actions: [
                                TextButton(
                                  child: Text('Tidak'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Ya'),
                                  onPressed: () {
                                    deleteOrder(index);
                                    Navigator.of(context).pop();
                                  },
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
    );
  }
}