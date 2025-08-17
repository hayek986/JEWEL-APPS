import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order.dart'; // تأكد من وجود ملف order.dart
import 'order_details_page.dart'; // تأكد من وجود ملف order_details_page.dart

// ✅ تم تحويل OrdersPage إلى StatefulWidget
class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  
  // ✅ دالة جديدة لتحديث حالة الطلب إلى "مقروء"
  Future<void> _updateOrderAsRead(String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'isNew': false,
      });
      print("تم تحديث حالة الطلب $orderId إلى 'مقروء'.");
    } catch (e) {
      print("حدث خطأ أثناء تحديث حالة الطلب: $e");
    }
  }

  CustomOrder _orderFromDoc(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    double totalPrice = 0.0;
    final dynamic totalPriceData = data['totalPrice'];
    if (totalPriceData is String) {
      totalPrice = double.tryParse(totalPriceData) ?? 0.0;
    } else if (totalPriceData is num) {
      totalPrice = totalPriceData.toDouble();
    }

    List<dynamic>? cartItemsData = data['cartItems'] as List<dynamic>?;
    List<Map<String, String>> cartItems = [];
    if (cartItemsData != null) {
      cartItems = cartItemsData.map<Map<String, String>>((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return {
          'name': map['name']?.toString() ?? '',
          'price': map['price']?.toString() ?? '0',
          'imageUrl': map['imageUrl']?.toString() ?? '',
          'weight': map['weight']?.toString() ?? '',
        };
      }).toList();
    }

    return CustomOrder(
      customerName: data['customerName'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      visaNumber: data['visaNumber'] ?? '',
      visaExpiry: data['visaExpiry'] ?? '',
      visaCVC: data['visaCVC'] ?? '',
      cartItems: cartItems,
      totalPrice: totalPrice,
    );
  }

  void _deleteOrder(String docId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الطلب بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الحذف: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF6A5096),
          title: const Text(
            'طلباتي',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bk.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                // ✅ الترتيب أولاً حسب 'isNew' (الطلبات الجديدة أولاً) ثم 'timestamp'
                .orderBy('isNew', descending: true)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('حدث خطأ: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('لا توجد طلبات سابقة.'));
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final order = _orderFromDoc(doc);
                  // ✅ الحصول على حالة isNew من المستند
                  final bool isNew = (doc.data() as Map<String, dynamic>)['isNew'] ?? false;

                  return InkWell(
                    // ✅ تم تعديل onTap لاستدعاء دالة التحديث ثم الانتقال
                    onTap: () {
                      _updateOrderAsRead(doc.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailsPage(order: order, orderId: doc.id),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      // ✅ تغيير لون البطاقة إذا كان الطلب جديداً
                      color: isNew ? Colors.purple.shade50 : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // ✅ إضافة أيقونة "جديد" إذا كان الطلب جديداً
                            if (isNew)
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(Icons.fiber_new, color: Colors.red),
                              ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'اسم العميل: ${order.customerName}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF6A5096)),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'رقم الهاتف: ${order.phone}',
                                style: const TextStyle(
                                    color: Color(0xFF6A5096)),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'العنوان: ${order.address}',
                                style: const TextStyle(
                                    color: Color(0xFF6A5096)),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'طريقة الدفع: ${order.paymentMethod}',
                                style: const TextStyle(
                                    color: Color(0xFF6A5096)),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'السعر الإجمالي: ${order.totalPrice.toStringAsFixed(2)} د.أ',
                                style: const TextStyle(
                                    color: Color(0xFF6A5096)),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('تأكيد الحذف'),
                                      content: const Text(
                                          'هل أنت متأكد أنك تريد حذف هذا الطلب؟'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          child: const Text('إلغاء'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                            _deleteOrder(doc.id, context);
                                          },
                                          child: const Text('حذف'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.delete),
                                label: const Text('حذف الطلب'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
