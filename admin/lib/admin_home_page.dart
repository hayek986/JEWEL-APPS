import 'package:flutter/material.dart';
import 'ProductListPage.dart';
import 'orders_page.dart';
import 'gold_price_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _newOrdersCount = 0;
  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  @override
  void initState() {
    super.initState();
    _listenToNewOrders();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }

  void _listenToNewOrders() {
    _ordersSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('isNew', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _newOrdersCount = snapshot.docs.length;
      });
    }, onError: (error) {
      print("Error listening to new orders: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لوحة تحكم المسؤول',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6A5096),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6E6FA), // Lavender
              Color(0xFFD8BFD8), // Thistle
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildControlPanelButton(
                  context,
                  'إدارة المنتجات',
                  ProductListPage(),
                ),
                const SizedBox(height: 12),
                _buildControlPanelButton(
                  context,
                  'عرض الطلبات',
                  OrdersPage(),
                  newOrdersCount: _newOrdersCount,
                ),
                const SizedBox(height: 12),
                _buildControlPanelButton(
                  context,
                  'سعر الذهب',
                  GoldPricePage(),
                ),
                const SizedBox(height: 12),
                _buildControlPanelButton(
                  context,
                  'تسجيل الخروج',
                  null,
                  isLogout: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanelButton(BuildContext context, String title, Widget? page, {bool isLogout = false, int newOrdersCount = 0}) {
    // ✅ تم استبدال SizedBox بـ Material و Container
    return Material(
      color: Colors.transparent, // لجعل تأثير التظليل مرئياً
      child: InkWell(
        onTap: () {
          if (isLogout) {
            Navigator.pop(context);
          } else if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        },
        // ✅ إضافة Container لتحديد الحجم والشكل
        child: Container(
          width: 280,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF6A5096),
            borderRadius: BorderRadius.circular(30),
            // ✅ إضافة التظليل المطلوب
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (newOrdersCount > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$newOrdersCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
