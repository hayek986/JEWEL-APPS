// هذا الملف تم تعديله ليتم استخدام Navigator.push بدلاً من pushNamed

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_product_page.dart';
import 'BackgroundWidget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'orders_page.dart';
import 'EditProductPage.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _configureFirebaseMessaging();
    _saveAdminFcmToken();
  }

  void _configureFirebaseMessaging() {
    _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification?.title} - ${message.notification?.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification?.body ?? 'إشعار جديد'),
            backgroundColor: const Color(0xFF6A5096),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      if (message.data['type'] == 'new_order') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersPage()));
      }
    });
  }

  Future<void> _saveAdminFcmToken() async {
    String? token = await _firebaseMessaging.getToken();

    if (token != null) {
      print('Admin FCM Token: $token');

      String adminDocId;
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        adminDocId = currentUser.uid;
      } else {
        adminDocId = 'main_admin_token';
      }

      await FirebaseFirestore.instance
          .collection('admin_tokens')
          .doc(adminDocId)
          .set({'fcmToken': token, 'timestamp': FieldValue.serverTimestamp()}, SetOptions(merge: true));

      print('Admin FCM Token saved to Firestore successfully for $adminDocId.');
    } else {
      print('Failed to get Admin FCM Token.');
    }
  }

  Stream<List<Map<String, dynamic>>> _getProducts() {
    return FirebaseFirestore.instance.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'price': doc['price'],
          'weight': doc['weight'],
          'image': doc['image'],
        };
      }).toList();
    });
  }

  void _editProduct(BuildContext context, String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(productId: productId),
      ),
    );
  }

  void _addProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPage(),
      ),
    );
  }

  void _viewOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrdersPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String webImageUrl =
        kIsWeb ? 'http://yourdomain.com/path/to/bk.png' : 'assets/bk.png';

    final double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    if (screenWidth > 900) {
      crossAxisCount = 4;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لوحة تحكم المنتجات',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6A5096),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _addProduct(context),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            onPressed: () => _viewOrders(context),
          ),
        ],
      ),
      body: BackgroundWidget(
        imageUrl: webImageUrl,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _getProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('لا توجد منتجات', style: TextStyle(color: Colors.white)));
            }

            final products = snapshot.data!;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.75,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              padding: const EdgeInsets.all(10),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(context, product);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => _editProduct(context, product['id']),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white.withOpacity(0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    product['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  // ✅ تعديل: تغيير المحاذاة إلى توسيط النصوص
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF6A5096),
                      ),
                      textAlign: TextAlign.center, // ✅ توسيط النص نفسه
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الوزن: ${product['weight']} جم',
                      style: const TextStyle(
                        color: Color(0xFF6A5096),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center, // ✅ توسيط النص نفسه
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'السعر: ${product['price']} د.أ',
                      style: const TextStyle(
                        color: Color(0xFF6A5096),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center, // ✅ توسيط النص نفسه
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
