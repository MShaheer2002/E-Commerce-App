import 'package:cloud_firestore/cloud_firestore.dart';

class PromoCode {
  final String code;
  final double discountPercent;
  final Timestamp startTime;
  final Timestamp endTime;
  final bool isActive;

  const PromoCode({
    required this.code,
    required this.discountPercent,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discountPercent': discountPercent,
      'startTime': startTime,
      'endTime': endTime,
      'isActive': isActive,
    };
  }

  factory PromoCode.fromMap(Map<String, dynamic> map) {
    return PromoCode(
      code: map['code'] ?? '',
      discountPercent: (map['discountPercent'] ?? 0).toDouble(),
      startTime: map['startTime'] ?? Timestamp.now(),
      endTime: map['endTime'] ?? Timestamp.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  bool get hasExpired => endTime.toDate().isBefore(DateTime.now());

  bool get isCurrentlyValid =>
      isActive && !hasExpired && startTime.toDate().isBefore(DateTime.now());
}
