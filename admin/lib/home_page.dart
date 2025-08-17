import 'dart:async'; // لاستيراد Timer
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart'; // لاستيراد SharedPreferences
import 'gold_price_service.dart'; // تأكد من استيراد ملف الخدمة
import 'more_products_page.dart'; // استيراد صفحة المنتجات الإضافية
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // تأكد من أنك قمت باستيراد هذه الحزمة
import 'order.dart';
import 'home_page.dart';
import 'cart_page.dart';
import 'payment_page.dart';
import 'more_products_page.dart';
import 'product_details_page.dart';
import 'gold_price_service.dart';
import 'cart_model.dart'; // تأكد من استيراد CartModel هنا
import 'twilio_service.dart'; // استيراد خدمة Twilio
import 'login_page.dart'; // استيراد صفحة تسجيل الدخول
import 'add_product_page.dart'; // ا
import 'EditProductPage.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pressCount = 0;
  ScrollController _scrollController = ScrollController();
  late Timer _timer;
  List<String> _productImages = [];
  Map<String, double> _goldPrices = {}; // تأكد من تعريف هذه المتغيرات

  @override
  void initState() {
    super.initState();
    _loadPressCount(); // تحميل العداد عند بدء الصفحة

    // تحميل الصور وأسعار الذهب وحفظها مؤقتًا
    _loadProductImages();
    _loadGoldPrices();

    // بدء التحريك التلقائي للصور بشكل مستمر دون توقف
    _timer = Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.offset;
        double delta = 6.0; // مقدار التحريك في كل مرة

        if (currentScroll + delta >= maxScroll) {
          _scrollController.jumpTo(0.0); // العودة للبداية فور الوصول للنهاية
        } else {
          _scrollController.jumpTo(currentScroll + delta);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // إلغاء المؤقت عند إغلاق الصفحة
    _scrollController.dispose();
    _clearSharedPreferences(); // مسح البيانات من SharedPreferences عند غلق التطبيق
    super.dispose();
  }

  // تحميل الصور من Firestore أو من SharedPreferences
  Future<void> _loadProductImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // مسح الكاش القديم إذا كان موجودًا
    prefs.remove('productImages');

    // تحميل الصور الجديدة من Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('products').get();
    List<String> imageUrls = snapshot.docs.map((doc) => doc['image'] as String).toList();

    // حفظ الصور الجديدة في SharedPreferences
    await prefs.setStringList('productImages', imageUrls);

    // تحديث واجهة المستخدم
    setState(() {
      _productImages = imageUrls;
    });
  }

  // تحميل أسعار الذهب من API أو من SharedPreferences
  Future<void> _loadGoldPrices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedPrices = prefs.getString('goldPrices');

    if (cachedPrices != null) {
      // إذا كانت الأسعار موجودة في SharedPreferences
      Map<String, double> goldPrices = Map<String, double>.fromEntries(
        cachedPrices.split('|').map((entry) {
          var parts = entry.split(':');
          return MapEntry(parts[0], double.parse(parts[1]));
        }),
      );
      setState(() {
        _goldPrices = goldPrices;
      });
    } else {
      // إذا لم تكن الأسعار موجودة في SharedPreferences، جلبها من خدمة GoldPriceService
      Map<String, double> goldPrices = await GoldPriceService.fetchGoldPrices();

      // حفظ الأسعار في SharedPreferences
      String pricesString = goldPrices.entries.map((e) => '${e.key}:${e.value}').join('|');
      await prefs.setString('goldPrices', pricesString);

      setState(() {
        _goldPrices = goldPrices;
      });
    }
  }

  // دالة لزيادة العداد وعرض صفحة تسجيل الدخول عند الوصول إلى 7 ضغطات
  void _incrementCounter() async {
    setState(() {
      _pressCount++;
    });

    // حفظ قيمة العداد باستخدام SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('pressCount', _pressCount);

    if (_pressCount >= 7) {
      // إعادة تعيين العداد إلى الصفر بعد فتح صفحة تسجيل الدخول
      prefs.setInt('pressCount', 0);
      _pressCount = 0;

      // الانتقال إلى صفحة تسجيل الدخول
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  // تحميل العداد من SharedPreferences عند بداية الصفحة
  _loadPressCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _pressCount = prefs.getInt('pressCount') ?? 0;
    });
  }

  // دالة لإغلاق التطبيق
  void _closeApp() {
    SystemNavigator.pop();
  }

  // دالة لمسح SharedPreferences
  Future<void> _clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // مسح جميع البيانات المخزنة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('متجر مجوهرات ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFF00008B)
        )),
        backgroundColor:Color(0xFF50C878),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: _incrementCounter,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bk.png'), // الصورة التي تم تحميلها
              fit: BoxFit.cover, // ملء الشاشة بالصورة
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 25), // المسافة بين العنوان وشريط عرض الصور المتحركة

              // شريط عرض الصور المتحركة في أعلى الصفحة
              _productImages.isNotEmpty
                  ? Container(
                height: 100,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _productImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: CachedNetworkImage(
                        imageUrl: _productImages[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    );
                  },
                ),
              )
                  : const CircularProgressIndicator(), // إذا كانت الصور غير محملة بعد

              SizedBox(height: 135), // المسافة بين التاب والأزرار

              // هنا تم التعديل: عند الضغط على زر "المنتجات"، سيتم الانتقال إلى MoreProductsPage
              _buildButton(context, "المنتجات", Icons.shop, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MoreProductsPage()),
                );
              }),
              SizedBox(height: 18), // المسافة بين الأزرار
              _buildButton(context, "السلة", Icons.shopping_cart, () {
                Navigator.pushNamed(context, "/cart");
              }),
              SizedBox(height: 18), // المسافة بين الأزرار
              _buildButton(context, "الدفع", Icons.payment, () {
                Navigator.pushNamed(context, "/payment");
              }),
              SizedBox(height: 18), // المسافة بين الأزرار
              _buildButton(context, "من نحن", Icons.info, () {
                Navigator.pushNamed(context, "/aboutus");
              }),
              SizedBox(height: 18), // المسافة بين الأزرار
              _buildButton(context, "إغلاق التطبيق", Icons.exit_to_app, () {
                _closeApp();
              }, isCloseButton: true),

              SizedBox(height: 27), // إضافة مسافة بين الأزرار وشريط أسعار الذهب

              // شريط عرض أسعار الذهب في أسفل الصفحة
              _goldPrices.isNotEmpty
                  ? Container(
                color: Color(0xFFF5F5DC),
                height: 50,
                child: Marquee(
                  text: _goldPrices.entries.map((entry) {
                    return '${entry.key}: ${entry.value.toStringAsFixed(2)} د.أ';
                  }).join('    |    '),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                  scrollAxis: Axis.horizontal,
                  blankSpace: 20.0,
                  velocity: 100.0,
                  pauseAfterRound: Duration(seconds: 0),
                ),
              )
                  : const CircularProgressIndicator(), // إذا كانت الأسعار غير محملة بعد
            ],
          ),
        ),
      ),
    );
  }

  // دالة لإنشاء زر
  Widget _buildButton(BuildContext context, String label, IconData icon, VoidCallback onPressed, {bool isCloseButton = false}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 25),
      label: Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00008B))), // تغيير لون النص هنا
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF50C878), // اللون الأساسي
        foregroundColor: Colors.white, // لون النص (غير مستخدم هنا لأنه سيتم تحديده في TextStyle)
        minimumSize: Size(200, 50), // تحديد حجم الزر
      ),
    );
  }
}
