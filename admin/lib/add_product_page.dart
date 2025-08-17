import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'BackgroundWidget.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _weightController = TextEditingController();
  Uint8List? _image;
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'خواتم';

  final List<String> _types = [
    'خواتم', 'ذبل', 'سحبات', 'أساور', 'عقد', 'حلق', 'بيبي', 'تعاليق', 'تشكيلة'
  ];

  // 🎨 الألوان المحدثة
  final Color _purpleColor = const Color(0xFF6A5096);
  final Color _whiteColor = Colors.white;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
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
        title: Text(
          'إضافة منتج',
          style: TextStyle(color: _whiteColor), // ✅ لون الكتابة أبيض
        ),
        centerTitle: true,
        backgroundColor: _purpleColor, // ✅ لون البار بنفسجي
        iconTheme: IconThemeData(color: _whiteColor), // ✅ لون أيقونة العودة أبيض
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
                              child: Center(child: Text('اضغط لاختيار صورة', style: TextStyle(color: _purpleColor)))) // ✅ لون الكتابة بنفسجي
                          : Image.memory(_image!,
                              height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: _purpleColor), // ✅ لون الكتابة بنفسجي
                      decoration: InputDecoration(
                        labelText: 'اسم المنتج',
                        labelStyle: TextStyle(color: _purpleColor), // ✅ لون الكتابة بنفسجي
                      ),
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
                      style: TextStyle(color: _purpleColor), // ✅ لون الكتابة بنفسجي
                      decoration: InputDecoration(
                        labelText: 'السعر',
                        labelStyle: TextStyle(color: _purpleColor), // ✅ لون الكتابة بنفسجي
                      ),
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
                      decoration: InputDecoration(
                        labelText: 'نوع المنتج',
                        labelStyle: TextStyle(color: _purpleColor), // ✅ لون الكتابة بنفسجي
                      ),
                      dropdownColor: _whiteColor, // ✅ لون خلفية القائمة المنسدلة
                      items: _types.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: TextStyle(color: _purpleColor), // ✅ لون خيارات القائمة بنفسجي
                          ),
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
                      style: TextStyle(color: _purpleColor), // ✅ لون الكتابة بنفسجي
                      decoration:
                          InputDecoration(
                            labelText: 'وزن المنتج (بالجرام)',
                            labelStyle: TextStyle(color: _purpleColor), // ✅ لون الكتابة بنفسجي
                          ),
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
                        backgroundColor: _purpleColor, // ✅ لون الزر بنفسجي
                      ),
                      child: Text(
                        'إضافة المنتج',
                        style: TextStyle(color: _whiteColor), // ✅ لون الكتابة أبيض
                      ),
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
