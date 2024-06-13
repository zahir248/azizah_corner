import 'package:flutter/material.dart';

import 'admin_login.dart';
import 'customer_login.dart';

class AppConfig {

  static final String baseIpAddress = "10.200.69.172"; // <-- Tukar ip address di sini

  static final String addProductPath = "/api/add_product.php";
  static final String loginPath = "/api/login.php";
  static final String registerAdminPath = "/api/register_admin.php";
  static final String getCartItemsPath = "/api/get_cart_items.php";
  static final String deleteCartItemPath = "/api/delete_cart_item.php";
  static final String getCustomerDetailsPath = "/api/get_customer_details.php";
  static final String fetchProductsMenuPath = "/api/fetch_products_menu.php";
  static final String addToCartPath = "/api/add_to_cart.php";
  static final String getCartItemCountPath = "/api/get_cart_item_count.php";
  static final String customerLoginPath = "/api/customer_login.php";
  static final String registerCustomerPath = "/api/register_customer.php";
  static final String forgotPasswordAdminPath = "/api/forgot_password_admin.php";
  static final String forgotPasswordCustomerPath = "/api/forgot_password_customer.php";
  static final String fetchOrdersPath = "/api/fetch_orders.php";
  static final String deleteOrderPath = "/api/delete_order.php";
  static final String updateOrderStatusPath = "/api/update_order_status.php";
  static final String fetchProductsPath = "/api/fetch_products.php";
  static final String updateProductPath = "/api/update_products.php";
  static final String deleteProductPath = "/api/delete_product.php";
  static final String insertOrderPath = "/api/insert_order.php";
  static final String updateImagePath = "/api/update_image.php";
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Utama'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/store.jpg',
              width: 300,
              height: 300,
            ),
            SizedBox(height: 10),
            Text(
              'Pilih Peranan anda:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: screenWidth * 0.8,
              child: ElevatedButton(
                onPressed: () {
                  // Handle button 1 action
                  // Navigate to CustomerDashboardPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CustomerLoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                ),
                child: Text('Pelanggan'),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: screenWidth * 0.8,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to AdminLoginPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminLoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                ),
                child: Text('Pentadbir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}