import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

class GoldPricePage extends StatefulWidget {
  @override
  _GoldPricePageState createState() => _GoldPricePageState();
}

class _GoldPricePageState extends State<GoldPricePage> {
  final _formKey = GlobalKey<FormState>();
  final _gd24Controller = TextEditingController();
  final _gd21Controller = TextEditingController();
  final _gd18Controller = TextEditingController();
  final _gd14Controller = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  Future<void> _addGoldPrice() async {
    if (_formKey.currentState!.validate()) {
      try {
        // التعديل هنا: استخدام doc().set() لتحديث مستند ثابت باسم 'current_prices'
        await FirebaseFirestore.instance
            .collection('gold_prices')
            .doc('current_prices') // اسم المستند المحدد
            .set({
          'GD24': double.parse(_gd24Controller.text),
          'GD21': double.parse(_gd21Controller.text),
          'GD18': double.parse(_gd18Controller.text),
          'GD14': double.parse(_gd14Controller.text),
          'date': _dateController.text,
        });
        
        _gd24Controller.clear();
        _gd21Controller.clear();
        _gd18Controller.clear();
        _gd14Controller.clear();
        _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث أسعار الذهب بنجاح!'),
            backgroundColor: Color(0xFF6A5096),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تحديث السعر: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _gd24Controller.dispose();
    _gd21Controller.dispose();
    _gd18Controller.dispose();
    _gd14Controller.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 2 : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدخال أسعار الذهب',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6A5096),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'أدخل أسعار الذهب الجديدة',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A5096),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildDateField(_dateController, 'التاريخ'),
                  const SizedBox(height: 16),
                  
                  GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3.5,
                    children: [
                      _buildTextField(_gd24Controller, 'عيار 24'),
                      _buildTextField(_gd21Controller, 'عيار 21'),
                      _buildTextField(_gd18Controller, 'عيار 18'),
                      _buildTextField(_gd14Controller, 'عيار 14'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _addGoldPrice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A5096),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'إضافة السعر',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    const purpleColor = Color(0xFF6A5096);
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: purpleColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: purpleColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: purpleColor, width: 2.0),
        ),
        prefixIcon: const Icon(Icons.monetization_on, color: purpleColor),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال السعر';
        }
        if (double.tryParse(value) == null) {
          return 'الرجاء إدخال رقم صالح';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    const purpleColor = Color(0xFF6A5096);
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: purpleColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: purpleColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: purpleColor, width: 2.0),
        ),
        prefixIcon: const Icon(Icons.calendar_today, color: purpleColor),
      ),
    );
  }
}
