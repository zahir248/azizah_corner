import 'package:flutter/material.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:http/http.dart' as http;

import 'customer_dashboard.dart';
import 'cart_item.dart';
import 'main.dart';

class PaymentPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;
  final String customerName;
  final String tableNumber;
  final int customerId; // Add customerId parameter

  PaymentPage({
    required this.cartItems,
    required this.totalPrice,
    required this.customerName,
    required this.tableNumber,
    required this.customerId,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  late Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    // Initialize Razorpay instance
    razorpay = Razorpay();
    // Set up event handlers
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, errorHandler);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, successHandler);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, externalWalletHandler);
  }

  void insertOrderToDatabase() async {
    var url = 'http://${AppConfig.baseIpAddress}${AppConfig.insertOrderPath}';

    // Extract item names, cartIds, prices, and quantities from cartItems
    List<String> itemNames = [];
    List<int> cartIds = [];
    List<double> prices = [];
    List<int> quantities = []; // Hold quantities as int

    for (var item in widget.cartItems) {
      itemNames.add(item.name);
      cartIds.add(item.cartId);
      prices.add(item.price);
      quantities.add(item.quantity); // Capture quantity for each item
    }

    // Debug: Print the values being sent to the server
    print('Customer Name: ${widget.customerName}');
    print('Total Price: ${widget.totalPrice}');
    print('Table Number: ${widget.tableNumber}');
    print('Item Names: ${itemNames.join(', ')}');
    print('Cart IDs: ${cartIds.join(', ')}');
    print('Prices: ${prices.join(', ')}');
    print('Quantities: ${quantities.join(', ')}'); // Debug print for item quantities

    // Convert totalPrice to a String for HTTP POST
    String totalPriceString = widget.totalPrice.toString();

    var response = await http.post(Uri.parse(url), body: {
      'customerName': widget.customerName,
      'totalPrice': totalPriceString, // Convert total price to a String
      'tableNumber': widget.tableNumber,
      'itemNames': itemNames.join(', '), // Convert item names to a comma-separated string
      'cartIds': cartIds.join(', '), // Convert cartIds to a comma-separated string
      'prices': prices.map((double price) => price.toString()).join(', '), // Convert prices to a comma-separated string
      'quantities': quantities.join(', '), // Convert quantities to a comma-separated string
    });

    if (response.statusCode == 200) {
      // Successful insertion
      print('Order inserted successfully');
    } else {
      // Error handling
      print('Failed to insert order: ${response.body}');
    }
  }

  void errorHandler(PaymentFailureResponse response) {
    // Display a red-colored SnackBar with the error message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response.message!),
      backgroundColor: Colors.red,
    ));
  }

  void successHandler(PaymentSuccessResponse response) {
    // Display a green-colored SnackBar with a custom message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Pembayaran Berjaya Dilakukan. Hidangan anda sedang di proses.'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 5),
    ));

    // Insert order into database
    insertOrderToDatabase();

    // Redirect to CustomerDashboardPage after a short delay
    Future.delayed(Duration(seconds: 2), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CustomerDashboardPage(customerId: widget.customerId)),
      );
    });
  }

  void externalWalletHandler(ExternalWalletResponse response) {
    // Display a green-colored SnackBar with the name of the external wallet used
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response.walletName!),
      backgroundColor: Colors.green,
    ));
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_ioqix0rVQYiyCH",
      "amount": (widget.totalPrice * 100).toInt(), // Convert totalPrice to integer cents
      "name": "Pembayaran Pesanan Di Azizah Corner",
      "description": "This is the test payment",
      "timeout": "180",
      "currency": "MYR",
      "prefill": {
        "contact": "1234567890",
        "email": "test@abc.com",
      }
    };
    razorpay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Ringkasan Pembayaran',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama Pelanggan: ${widget.customerName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nombor Meja: ${widget.tableNumber}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return Card(
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.quantity} x RM ${item.price.toStringAsFixed(2)}'),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Jumlah: RM ${widget.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(width: 20), // Add some space between the total price and the button
                TextButton(
                  onPressed: () {
                    openCheckout();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0), // Adjust padding as needed
                    child: Text(
                      'Buat Pembayaran',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}