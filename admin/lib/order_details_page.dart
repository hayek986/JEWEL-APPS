import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order.dart';

class OrderDetailsPage extends StatelessWidget {
  final CustomOrder order;
  final String orderId;

  const OrderDetailsPage({Key? key, required this.order, required this.orderId})
      : super(key: key);

  void _deleteOrder(BuildContext context) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // تعريف اللون البنفسجي الرئيسي
    const purpleColor = Color(0xFF6A5096);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: purpleColor,
          title: const Text(
            'تفاصيل الطلب',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _deleteOrder(context),
              tooltip: 'حذف الطلب',
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bk.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('اسم العميل:', order.customerName),
                    _buildDetailRow('رقم الهاتف:', order.phone),
                    _buildDetailRow('العنوان:', order.address),
                    _buildDetailRow('طريقة الدفع:', order.paymentMethod),
                    _buildDetailRow(
                        'المبلغ الإجمالي:', '${order.totalPrice.toStringAsFixed(2)} د.أ'),
                    const SizedBox(height: 20),
                    const Text(
                      'عناصر الطلب:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: purpleColor, // 💜 لون النص بنفسجي
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...order.cartItems.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item['imageUrl'] != null &&
                                  item['imageUrl']!.isNotEmpty)
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(item['imageUrl']!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[200],
                                  ),
                                ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: purpleColor), // 💜 لون النص بنفسجي
                                    ),
                                    Text(
                                      'السعر: ${item['price']} د.أ',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: purpleColor), // 💜 لون النص بنفسجي
                                    ),
                                    if (item['weight'] != null)
                                      Text(
                                        'الوزن: ${item['weight']}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: purpleColor), // 💜 لون النص بنفسجي
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // تم تعديل هذه الدالة لتطبيق اللون البنفسجي على جميع النصوص
  Widget _buildDetailRow(String label, String value) {
    const purpleColor = Color(0xFF6A5096);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: purpleColor, // 💜 لون النص بنفسجي
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: purpleColor), // 💜 لون النص بنفسجي
            ),
          ),
        ],
      ),
    );
  }
}