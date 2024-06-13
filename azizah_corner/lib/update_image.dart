import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'product.dart';
import 'manage_product.dart';
import 'main.dart';

class UpdateImagePage extends StatefulWidget {
  final Product product;

  const UpdateImagePage({Key? key, required this.product}) : super(key: key);

  @override
  _UpdateImagePageState createState() => _UpdateImagePageState();
}

class _UpdateImagePageState extends State<UpdateImagePage> {
  File? _imageFile;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> updateProductImage(int productId, String base64Image) async {
    final url = Uri.parse('http://${AppConfig.baseIpAddress}${AppConfig.updateImagePath}');
    final body = jsonEncode(<String, dynamic>{
      'id': productId,
      'image': base64Image,
    });

    print('Request Body: $body'); // Print the request body for debugging

    final response = await http.post(
      url,
      body: body,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // Handle success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gambar Berjaya Dikemaskinikan'),
          backgroundColor: Colors.green,
        ),
      );

      // Redirect to ManageProductPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ManageProductPage()),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal Mengemaskini Gambar. Sila Cuba Lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kemaskini Gambar Produk'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            _imageFile == null
                ? Text('Tiada gambar yang dipilih')
                : Image.file(_imageFile!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getImage,
              child: Text('Pilih Imej'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_imageFile != null) {
                  // Encode the image to base64
                  String base64Image = base64Encode(_imageFile!.readAsBytesSync());

                  // Call function to update product image
                  updateProductImage(widget.product.id, base64Image);
                } else {
                  // Handle case where no image is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sila pilih gambar terlebih dahulu'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Kemaskini Gambar '),
            ),
          ],
        ),
      ),
    );
  }
}