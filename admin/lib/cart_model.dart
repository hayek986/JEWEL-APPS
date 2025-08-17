import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  // قائمة لحفظ العناصر الموجودة في السلة؛ كل عنصر عبارة عن خريطة تحتوي على اسم المنتج وسعره.
  List<Map<String, dynamic>> _cartItems = [];

  // دالة getter للحصول على العناصر الموجودة في السلة.
  List<Map<String, dynamic>> get cartItems => _cartItems;

  // دالة لإضافة عنصر إلى السلة
  void addToCart(String productName, double productPrice , String productImage) {
    _cartItems.add({
      'name': productName,
      'price': productPrice, // تأكد من تمرير السعر كـ double
      'image': productImage, // إضافة رابط الصورة


    });
    notifyListeners(); // إخطار الواجهة بالتغييرات
  }

  // دالة لحذف عنصر من السلة بناءً على الفهرس
  void removeItem(int index) {
    _cartItems.removeAt(index);
    notifyListeners(); // إخطار الواجهة بالتغييرات
  }

  // دالة لحساب السعر الإجمالي لكل العناصر الموجودة في السلة
  double getTotalPrice() {
    double total = 0.0;
    for (var item in _cartItems) {
      double price = item['price']; // تأكد من أن السعر هو نوع double
      print('سعر المنتج: $price'); // طباعة لتتبع الأسعار
      total += price; // إضافة السعر إلى الإجمالي
    }
    print('الإجمالي: $total'); // طباعة للإجمالي
    return total;
  }

  // دالة لإفراغ السلة
  void clearCart() {
    _cartItems.clear();
    notifyListeners(); // إخطار الواجهة بالتغييرات
  }
}
