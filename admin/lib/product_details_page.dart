import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'BackgroundWidget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProductDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productDetails =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final productName = productDetails['name']!;
    final productPrice =
        double.tryParse(productDetails['price'].toString()) ?? 0.0;
    final productImage = productDetails['image']!;
    final productType = productDetails['type']!;
    final productWeight = productDetails['weight']!;

    final String webImageUrl =
        kIsWeb ? 'http://yourdomain.com/path/to/bk.png' : 'assets/bk.png';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل المنتج',
          style: TextStyle(
            color: Color(0xFF6A5096),
          ),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: BackgroundWidget(
        imageUrl: webImageUrl,
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Padding( // تم إزالة الـ `Center` من هنا
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // تم التعديل هنا
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FullScreenImagePage(imageUrl: productImage),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            productImage,
                            width: kIsWeb ? 300 : 250,
                            height: kIsWeb ? 300 : 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      productName,
                      style: TextStyle(
                        fontSize: kIsWeb ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.right, // تم التعديل هنا
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'السعر: د.أ ${productPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: kIsWeb ? 22 : 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.right, // تم التعديل هنا
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'النوع: $productType',
                      style: TextStyle(
                        fontSize: kIsWeb ? 22 : 20,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.right, // تم التعديل هنا
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'الوزن: $productWeight',
                      style: TextStyle(
                        fontSize: kIsWeb ? 22 : 20,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.right, // تم التعديل هنا
                    ),
                    const SizedBox(height: 20),
                    _buildElevatedButton(
                      onPressed: () {
                        context
                            .read<CartModel>()
                            .addToCart(productName, productPrice, productImage, productType, productWeight);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('تمت الإضافة إلى السلة')),
                        );
                      },
                      label: 'إضافة إلى السلة',
                    ),
                    const SizedBox(height: 16),
                    _buildElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      label: 'العودة إلى صفحة المنتجات',
                    ),
                    const SizedBox(height: 16),
                    _buildElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/cart');
                      },
                      label: 'الذهاب إلى السلة',
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

  Widget _buildElevatedButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 50 : 40, vertical: kIsWeb ? 16 : 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: kIsWeb ? 20 : 18, color: Colors.white),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  FullScreenImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صورة المنتج',
            style: TextStyle(color: Color(0xFF6A5096))),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}