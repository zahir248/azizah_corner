import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'product.dart';
import 'add_product.dart';
import 'admin_dashboard.dart';
import 'update_image.dart';
import 'main.dart';

class ManageProductPage extends StatefulWidget {
  @override
  _ManageProductPageState createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  late Future<List<Product>> futureProducts;

  Future<List<Product>> fetchProducts() async {
    try {
      final url = Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.fetchProductsPath}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((product) => Product.fromJson(product)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to load products');
    }
  }

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  Future<void> updateProduct(int productId, String name, String category, double price, {File? imageFile}) async {
    String? base64Image;
    if (imageFile != null) {
      base64Image = base64Encode(await imageFile.readAsBytes());
    }

    try {
      final url = Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.updateProductPath}');

      final response = await http.post(
        url,
        body: jsonEncode(<String, dynamic>{
          'id': productId,
          'name': name,
          'category': category,
          'price': price,
          if (base64Image != null) 'image': base64Image,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produk Berjaya Dikemaskinikan'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          futureProducts = fetchProducts();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal untuk kemaskini maklumat produk. Sila cuba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error updating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ralat: Gagal mengemaskini produk'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengurusan Produk'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<Product>>(
          future: futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: MediaQuery.of(context).size.height,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final product = snapshot.data![index];
                    final imageBytes = base64Decode(product.imageUrl.split(',').last);

                    return Card(
                      child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.memory(
                            imageBytes,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(product.name),
                        subtitle: Text('${product.category} - RM${product.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.image),
                              onPressed: () async {
                                final updatedImage = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateImagePage(product: product),
                                  ),
                                );

                                if (updatedImage != null) {
                                  // Update product with new image
                                  updateProduct(product.id, product.name, product.category, product.price, imageFile: updatedImage);
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    TextEditingController nameController = TextEditingController(text: product.name);
                                    TextEditingController categoryController = TextEditingController(text: product.category);
                                    TextEditingController priceController = TextEditingController(text: product.price.toStringAsFixed(2));

                                    return AlertDialog(
                                      title: Text('Perbaharui Maklumat Produk'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          buildTextField('Nama', nameController),
                                          buildTextField('Kategori', categoryController),
                                          buildTextField('Harga', priceController),
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
                                          child: Text('Simpan'),
                                          onPressed: () {
                                            String editedName = nameController.text;
                                            String editedCategory = categoryController.text;
                                            double editedPrice = double.parse(priceController.text);

                                            Navigator.of(context).pop();

                                            updateProduct(product.id, editedName, editedCategory, editedPrice);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
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
                                      title: Text('Buang Produk'),
                                      content: Text('Apakah anda pasti ingin membuang produk ini daripada senarai menu?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Batal'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Buang'),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            final url = Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.deleteProductPath}');

                                            final deleteResponse = await http.post(
                                              url,
                                              body: jsonEncode(<String, dynamic>{
                                                'id': product.id,
                                              }),
                                              headers: <String, String>{
                                                'Content-Type': 'application/json; charset=UTF-8',
                                              },
                                            );
                                            if (deleteResponse.statusCode == 200) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Produk Berjaya Dibuang'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                              setState(() {
                                                futureProducts = fetchProducts();
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Gagal untuk membuang produk. Sila cuba lagi.'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
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
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to load products'));
            } else {
              return Center(child: Text('Something went wrong'));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          ).then((value) {
            if (value == true) {
              setState(() {
                futureProducts = fetchProducts();
              });
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}