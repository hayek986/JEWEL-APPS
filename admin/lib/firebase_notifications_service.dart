import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseNotificationsService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        await saveTokenToFirestore(token);
      }
    }
    
    // Listen for new FCM tokens
    _firebaseMessaging.onTokenRefresh.listen((token) async {
      print('FCM Token Refreshed: $token');
      await saveTokenToFirestore(token);
    });
  }

  Future<void> saveTokenToFirestore(String token) async {
    // This is where you save the token for the app owner.
    // In a real app, you would have a dedicated user ID for the admin.
    // For this example, we will use a static ID.
    // You must change this to a secure user ID in a production app.
    String appOwnerUserId = 'app_owner_123'; 
    await _firestore.collection('deviceTokens').doc(appOwnerUserId).set({
      'token': token,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('FCM token saved to Firestore for user: $appOwnerUserId');
  }
}
