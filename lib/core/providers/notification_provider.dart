import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationProvider with ChangeNotifier {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _initialized = false;

  NotificationProvider() {
    // Listen for auth state changes to automatically register token on login
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        log("[Notification Provider] User logged in: ${user.uid}. Initializing notifications...");
        // Reset initialization flag to allow fresh setup for the new user
        _initialized = false;
        initNotifications();
      }
    });
  }

  // Public getter for notifications stream (used in NotificationScreen)
  Stream<QuerySnapshot<Map<String, dynamic>>> get notificationStream {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> initNotifications() async {
    if (_initialized) return;
    _initialized = true;

    // --- REQUEST PERMISSIONS ---
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final status = await Permission.notification.status;

      if (status != PermissionStatus.granted) {
        final result = await Permission.notification.request();
        if (result == PermissionStatus.granted) {
          log("[Notification Provider] Notification permission granted");
        } else {
          log("[Notification Provider] Notification permission denied");
        }
      }
    }

    // Get FCM token
    // Get FCM token
    String? token;
    if (kIsWeb) {
      // Handle web if needed, or skip
    } else if (Platform.isIOS) {
      final apnsToken = await _firebaseMessaging.getAPNSToken();
      if (apnsToken != null) {
        try {
          token = await _firebaseMessaging.getToken();
        } catch (e) {
          log('[NotificationProvider] Error getting FCM token: $e');
        }
      } else {
        log('[NotificationProvider] APNS token not yet available. Skipping FCM token.');
      }
    } else {
      token = await _firebaseMessaging.getToken();
    }

    log('[NotificationProvider] FCM Token: $token');

    // Save token to Firestore
    final user = _auth.currentUser;
    if (user != null && token != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        log("[ON TAP NOTIFICATION] $response");
        // Handle tap
      },
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Message received: ${message.notification?.title}');
      _showLocalNotification(message);
      _saveNotification(message);
    });
  }

  /// Show local notification (foreground)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const platformDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      platformDetails,
    );
  }

  /// Save notification in Firestore (for notification screen)
  Future<void> _saveNotification(RemoteMessage message) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .add({
      'title': message.notification?.title ?? 'Notification',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  /// --- MANUAL (LOCAL) NOTIFICATIONS ---

  Future<void> notifyAddedToCart(String productName) async {
    await _showManualNotification(
      'Added to Cart',
      'You added "$productName" to your cart.',
      type: 'cart',
    );
  }

  Future<void> notifyAddedToFavorite(String productName) async {
    await _showManualNotification(
      'Added to Favorites',
      'You added "$productName" to your favorites.',
      type: 'favorite',
    );
  }

  Future<void> _showManualNotification(String title, String body,
      {String? type}) async {
    const androidDetails = AndroidNotificationDetails(
      'manual_channel',
      'Manual Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const platformDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
    );

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
        'title': title,
        'body': body,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    }
  }

  Future<void> clearNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // 1. Remove from Firestore so server stops sending to this UID
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': FieldValue.delete(),
        });
        log("[Notification Provider] fcmToken removed from Firestore");
      }

      // 2. Delete the token from the device itself
      // This ensures the device won't receive messages even if sent to the old token
      await _firebaseMessaging.deleteToken();
      log("[Notification Provider] Device token deleted");

      _initialized = false;
    } catch (e) {
      log("[Notification Provider] Error clearing FCM data: $e");
    }
  }
}
