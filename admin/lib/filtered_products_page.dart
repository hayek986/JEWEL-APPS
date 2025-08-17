import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'BackgroundWidget.dart';
import 'more_products_page.dart';

class FilteredProductsPage extends StatelessWidget {
  final String filterType;

  FilteredProductsPage({required this.filterType});

  Stream<List<Map<String, dynamic>>> _getFilteredProducts() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('type', isEqualTo: filterType)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'price': doc['price'],
          'image': doc['image'],
          'type': doc['type'],
          'weight': doc['weight'],
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // تحديد عنوان URL للصورة على الويب
    final String webImageUrl =
        kIsWeb ? 'http://yourdomain.com/path/to/bk.png' : 'assets/bk.png';

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'منتجات $filterType',
            style: TextStyle(color: Color(0xFF6A5096)),
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: BackgroundWidget(
        imageUrl: webImageUrl,
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 1200), // تحديد أقصى عرض للويب
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getFilteredProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد منتجات حالياً',
                      style: TextStyle(color: Color(0xFF6A5096), fontSize: kIsWeb ? 24 : 18),
                    ),
                  );
                }

                final products = snapshot.data!;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: kIsWeb ? 4 : 2, // 4 أعمدة للويب، 2 للجوال
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  padding: EdgeInsets.all(kIsWeb ? 20 : 10), // حواف أكبر للويب
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/productDetails',
                          arguments: {
                            'name': product['name'],
                            'price': product['price'],
                            'image': product['image'],
                            'type': product['type'],
                            'weight': product['weight'],
                          },
                        );
                      },
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                              child: Image.network(
                                product['image'],
                                height: kIsWeb ? 200 : 150, // ارتفاع أكبر للويب
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  product['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: kIsWeb ? 18 : 14,
                                    color: Colors.green,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'السعر: ${product['price']} د.أ',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                  fontSize: kIsWeb ? 16 : 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}