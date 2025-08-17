import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _weightController = TextEditingController();
  Uint8List? _image; // Changed to Uint8List to store image bytes
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'خواتم';

  final List<String> _types = [
    'خواتم', 'ذبل', 'سحبات', 'أساور', 'عقد', 'حلق', 'بيبي', 'تعاليق', 'تشكيلة'
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Read the image as bytes for all platforms
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _image = bytes;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('product_images/${DateTime.now().millisecondsSinceEpoch}');

    try {
      // Use putData for all platforms since _image is now Uint8List
      final uploadTask = storageRef.putData(_image!);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحميل الصورة: $e')));
      return null;
    }
  }

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('يرجى اختيار صورة للمنتج')));
        return;
      }
      
      String name = _nameController.text;
      double price = double.parse(_priceController.text);
      String type = _selectedType;
      double weight = double.parse(_weightController.text);

      String? imageUrl;
      try {
        imageUrl = await _uploadImage();
      } catch (e) {
        print('Failed to upload image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في تحميل الصورة. الرجاء المحاولة مرة أخرى.')));
        return;
      }

      if (imageUrl != null) {
        try {
          await FirebaseFirestore.instance.collection('products').add({
            'name': name,
            'price': price,
            'type': type,
            'weight': weight,
            'image': imageUrl,
          });

          print('Product added successfully!');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إضافة المنتج بنجاح')));
          Navigator.pop(context);
        } catch (e) {
          print('Failed to add product to Firestore: $e');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل في إضافة المنتج. تحقق من اتصالك بالإنترنت.')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل في الحصول على رابط الصورة.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String backgroundImageUrl = kIsWeb
        ? 'https://placehold.co/1080x1920/D3D3D3/000000?text=Background+Image'
        : 'assets/bk.png';
        
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة منتج'),
        centerTitle: true,
      ),
      body: BackgroundWidget(
        imageUrl: backgroundImageUrl,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: _image == null
                          ? Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: Center(child: Text('اضغط لاختيار صورة')))
                          : Image.memory(_image!,
                              height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'اسم المنتج'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال اسم المنتج';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'السعر'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال السعر';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(labelText: 'نوع المنتج'),
                      items: _types.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى اختيار نوع المنتج';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: 'وزن المنتج (بالجرام)'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال وزن المنتج';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4CAF50),
                        foregroundColor: Color(0xFFFFD700),
                      ),
                      child: Text('إضافة المنتج'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
