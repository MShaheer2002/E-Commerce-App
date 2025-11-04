import 'package:e_commerce_app/presentation/models/promo_model.dart';

class GlobalSettings {
  final List<PromoCode>? promoCodes;

  const GlobalSettings({this.promoCodes});

  Map<String, dynamic> toMap() {
    return {
      'promoCodes': promoCodes?.map((e) => e.toMap()).toList(),
    };
  }

  factory GlobalSettings.fromMap(Map<String, dynamic> map) {
    return GlobalSettings(
      promoCodes: map['promoCodes'] != null
          ? List<PromoCode>.from((map['promoCodes'] as List)
              .map((x) => PromoCode.fromMap(Map<String, dynamic>.from(x))))
          : null,
    );
  }
}
