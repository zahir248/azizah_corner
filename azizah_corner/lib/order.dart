import 'package:flutter/material.dart';

import 'cart_item.dart';
import 'payment.dart'; // Import the payment page

class OrderPage extends StatelessWidget {
  final List<CartItem> cartItems;
  final double totalPrice;
  final int customerId; // Add customerId parameter

  OrderPage({required this.cartItems, required this.totalPrice, required this.customerId}); // Modify constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Ringkasan Pesanan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.quantity} x RM ${item.price.toStringAsFixed(2)}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white, // Set background color to white
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Jumlah : RM ${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(width: 20), // Add some space between the total price and the button
              TextButton(
                onPressed: () {
                  _showConfirmationDialog(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0), // Adjust padding as needed
                  child: Text(
                    'Sahkan Pesanan',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _tableNumberController = TextEditingController();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Masukkan Maklumat Pelanggan'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nama Pelanggan'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sila masukkan nama pelanggan';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _tableNumberController,
                  decoration: InputDecoration(labelText: 'Nombor Meja'),
                  keyboardType: TextInputType.number, // Restrict input to numeric only
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sila masukkan nombor meja';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  _goToPaymentPage(
                    context,
                    _nameController.text,
                    _tableNumberController.text,
                  );
                }
              },
              child: Text('Sahkan'),
            ),
          ],
        );
      },
    );
  }

  void _goToPaymentPage(BuildContext context, String customerName, String tableNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          cartItems: cartItems,
          totalPrice: totalPrice,
          customerName: customerName,
          tableNumber: tableNumber,
          customerId: customerId,
        ),
      ),
    );
  }
}