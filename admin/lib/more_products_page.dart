import 'package:flutter/material.dart';
import 'filtered_products_page.dart'; // تأكد من استيراد الصفحة الثانية
import 'BackgroundWidget.dart'; // تأكد من استيراد الـ BackgroundWidget
import 'home_page.dart'; // استيراد الصفحة الرئيسية
import 'cart_page.dart'; // تأكد من استيراد صفحة السلة

class MoreProductsPage extends StatelessWidget {
  // دالة للانتقال إلى صفحة المنتجات المفلترة بناءً على النوع المختار
  void _openFilteredProductsPage(BuildContext context, String filterType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredProductsPage(filterType: filterType),
      ),
    );
  }

  // دالة للانتقال إلى الصفحة الرئيسية
  void _goToHomePage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()), // الصفحة الرئيسية
      (Route<dynamic> route) => false, // إزالة جميع الصفحات السابقة
    );
  }

  // دالة للانتقال إلى صفحة السلة
  void _goToCartPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage()), // انتقل إلى صفحة السلة
    );
  }

  // دالة لعرض الأزرار بتصميم متناسق مع الصفحة الرئيسية
  Widget _buildFilterButton(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: ElevatedButton(
        onPressed: () => _openFilteredProductsPage(context, label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF50C878), // لون الخلفية مطابق للصفحة الرئيسية
          foregroundColor: Colors.white, // لون الأيقونة أو النص
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          minimumSize: const Size(200, 50), // تحديد حجم الزر
        ),
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF00008B)), // لون النص مطابق للصفحة الرئيسية
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اختر نوع المنتجات',
          style: TextStyle(
            color: Color(0xFF00008B), // تعيين لون النص ليتناسب مع الصفحة الرئيسية
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        backgroundColor: const Color(0xFF50C878), // لون الـ AppBar مطابق للصفحة الرئيسية
        centerTitle: true, // محاذاة النص في المنتصف
        elevation: 0, // إزالة الظل أسفل الـ AppBar
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // إذا كانت الحركة من اليسار إلى اليمين (drag من اليسار)
          if (details.primaryVelocity! > 0) {
            _goToHomePage(context);
          }
        },
        child: BackgroundWidget(
          imageUrl: 'assets/bk.png', // تم إضافة imageUrl هنا
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // عرض الأزرار في منتصف الصفحة
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    _buildFilterButton(context, 'خواتم'),
                    _buildFilterButton(context, 'ذبل'),
                    _buildFilterButton(context, 'سحبات'),
                    _buildFilterButton(context, 'أساور'),
                    _buildFilterButton(context, 'عقد'),
                    _buildFilterButton(context, 'حلق'),
                    _buildFilterButton(context, 'بيبي'),
                    _buildFilterButton(context, 'تعاليق'),
                    _buildFilterButton(context, 'تشكيلة'),
                  ],
                ),
                const SizedBox(height: 20.0), // إضافة مساحة فارغة قبل الزر
                _buildButton(context, 'الذهاب إلى السلة', Icons.shopping_cart, () => _goToCartPage(context)),
                const SizedBox(height: 20.0),
                _buildButton(context, 'العودة إلى الصفحة الرئيسية', Icons.home, () => _goToHomePage(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة لإنشاء زر بتصميم متناسق مع الصفحة الرئيسية
  Widget _buildButton(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 25, color: const Color(0xFF00008B)),
      label: Text(
        label,
        style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00008B)), // لون النص مطابق
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF50C878), // لون الخلفية مطابق
        minimumSize: const Size(200, 50), // تحديد حجم الزر
      ),
    );
  }
}
