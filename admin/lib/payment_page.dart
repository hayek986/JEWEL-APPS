import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_model.dart'; // تأكد من وجود cart_model.dart في نفس المجلد
import 'order.dart'; // تأكد من وجود order.dart في نفس المجلد
import 'package:provider/provider.dart';
import 'BackgroundWidget.dart'; // تأكد من وجود BackgroundWidget.dart في نفس المجلد
import 'package:flutter/foundation.dart' show kIsWeb;

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = 'cash';
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController visaNumberController = TextEditingController();
  final TextEditingController visaExpiryController = TextEditingController();
  final TextEditingController visaCVCController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String webImageUrl =
        kIsWeb ? 'http://yourdomain.com/path/to/bk.png' : 'assets/bk.png';

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'خيارات الدفع',
            style: TextStyle(
              color: Color(0xFF6A5096),
            ),
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: BackgroundWidget(
        imageUrl: webImageUrl,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'معلومات العميل',
                      style: TextStyle(
                        fontSize: kIsWeb ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                        controller: customerNameController,
                        labelText: 'اسم العميل',
                        icon: Icons.person),
                    const SizedBox(height: 16),
                    Text(
                      'طريقة الدفع',
                      style: TextStyle(
                        fontSize: kIsWeb ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            value: 'cash',
                            groupValue: selectedPaymentMethod,
                            title: Text('الدفع عند الاستلام',
                                style: TextStyle(fontSize: kIsWeb ? 16 : 14)),
                            onChanged: (value) {
                              setState(() {
                                selectedPaymentMethod = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            value: 'visa',
                            groupValue: selectedPaymentMethod,
                            title: Text('الدفع بواسطة فيزا',
                                style: TextStyle(fontSize: kIsWeb ? 16 : 14)),
                            onChanged: (value) {
                              setState(() {
                                selectedPaymentMethod = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                        controller: addressController,
                        labelText: 'العنوان',
                        icon: Icons.location_on),
                    const SizedBox(height: 16),
                    _buildTextField(
                        controller: phoneController,
                        labelText: 'رقم الهاتف',
                        icon: Icons.phone),
                    if (selectedPaymentMethod == 'visa') ...[
                      const SizedBox(height: 16),
                      _buildTextField(
                          controller: visaNumberController,
                          labelText: 'رقم الفيزا',
                          icon: Icons.credit_card),
                      const SizedBox(height: 16),
                      _buildTextField(
                          controller: visaExpiryController,
                          labelText: 'تاريخ انتهاء الفيزا',
                          icon: Icons.date_range),
                      const SizedBox(height: 16),
                      _buildTextField(
                          controller: visaCVCController,
                          labelText: 'CVC',
                          icon: Icons.lock,
                          obscureText: true),
                    ],
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            if (customerNameController.text.isEmpty ||
                                addressController.text.isEmpty ||
                                phoneController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
                              );
                              return;
                            }

                            final cartItems = context.read<CartModel>().cartItems.map((item) {
                              // ✅ إصلاح: إضافة جميع حقول المنتج الضرورية هنا
                              return {
                                'name': item['name'] as String,
                                'price': item['price'].toString(),
                                'image': item['image'] as String? ?? 'https://placehold.co/600x400/E0E0E0/ffffff?text=صورة',
                                'quantity': item['quantity'] ?? 1,
                                'weight': item['weight'] ?? 0.0,
                              };
                            }).toList();
                            
                            if (cartItems.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('لا يوجد منتجات في سلة التسوق')),
                              );
                              return;
                            }
                            
                            // ✅ إصلاح: استخدام addDoc() لإنشاء وثيقة جديدة تلقائياً بمعرف فريد
                            await FirebaseFirestore.instance
                                .collection('orders')
                                .add({
                                  'customerDetails': {
                                    'name': customerNameController.text.trim(),
                                    'address': addressController.text,
                                    'phone': phoneController.text,
                                  },
                                  'paymentMethod': selectedPaymentMethod,
                                  'visaDetails': selectedPaymentMethod == 'visa' ? {
                                    'number': visaNumberController.text,
                                    'expiry': visaExpiryController.text,
                                    'cvc': visaCVCController.text,
                                  } : null,
                                  'items': cartItems, // ✅ إصلاح: تغيير cartItems إلى items
                                  'totalPrice': context.read<CartModel>().getTotalPrice(),
                                  'timestamp': FieldValue.serverTimestamp(),
                                });

                            context.read<CartModel>().clearCart();
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تمت معالجة الطلب بنجاح')),
                            );
                          } catch (e) {
                            print('An error occurred while processing the order: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('فشل في إرسال الطلب. يرجى المحاولة مرة أخرى.')),
                            );
                          }
                        },
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: Text(
                          'إرسال الطلب',
                          style: TextStyle(
                              color: Color(0xFF6A5096),
                              fontSize: kIsWeb ? 18 : 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: kIsWeb ? 20 : 16, horizontal: kIsWeb ? 40 : 32),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
