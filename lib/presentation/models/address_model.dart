
class AddressModel {
  final String name;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String zip;
  final String country;

  AddressModel({
    required this.name,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
  });

  /// Convert AddressModel → Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
    };
  }

  /// Convert Map → AddressModel
  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      addressLine1: map['addressLine1'] ?? '',
      addressLine2: map['addressLine2'],
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zip: map['zip'] ?? '',
      country: map['country'] ?? '',
    );
  }

  /// For Firestore compatibility (optional)
  Map<String, dynamic> toJson() => toMap();
}
