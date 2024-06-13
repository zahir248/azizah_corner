import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import 'manage_product.dart';
import 'main.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  File? _image;

  bool _validateInputs() {
    if (nameController.text.isEmpty ||
        categoryController.text.isEmpty ||
        priceController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tolong isi semua ruangan termasuk gambar'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> addProduct() async {
    if (!_validateInputs()) {
      return;
    }

    try {
      String base64Image = base64Encode(await _image!.readAsBytes());

      final response = await http.post(
        Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.addProductPath}'),
        body: jsonEncode(<String, dynamic>{
          'name': nameController.text,
          'category': categoryController.text,
          'price': double.parse(priceController.text),
          'image': base64Image, // Send base64 encoded image data
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Product added successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produk Berjaya Ditambah'),
            backgroundColor: Colors.green,
          ),
        );
        print('Product added successfully');

        // Navigate to ManageProductPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManageProductPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal untuk menambah produk dengan kod status: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
        print('Failed to add product with status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal untuk menambah produk: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error adding product: $e');
    }
  }

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 10,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Produk Baru'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Produk'),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Kategori'),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Harga (RM)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 24.0),
              _image == null
                  ? ElevatedButton(
                onPressed: _getImage,
                child: Text('Selitkan Gambar'),
              )
                  : Image.file(
                _image!,
                height: 200.0,
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: addProduct,
                child: Text('Tambah Produk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}