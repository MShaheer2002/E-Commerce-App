import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../presentation/models/user_model.dart';

class UserManagementProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserModel> _users = [];
  bool _isLoading = false;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('users').get();
      _users = snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList();
    } catch (e) {
      Fluttertoast.showToast(msg: "something went wrong");
      log('Error fetching users: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> blockUser(String uid, bool block) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'isBlocked': block});
      final index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isBlocked: block);
        notifyListeners();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "something went wrong");
      log('Error blocking user: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      _users.removeWhere((u) => u.uid == uid);
      notifyListeners();
    } catch (e) {
      Fluttertoast.showToast(msg: "something went wrong");
      log('Error deleting user: $e');
    }
  }
}
