// class CartModel {
//   final String id;
//   final String name;
//   final List<String> imageUrl;
//   final double price;
//   int quantity;

//   CartModel({
//     required this.id,
//     required this.name,
//     required this.imageUrl,
//     required this.price,
//     this.quantity = 1,
//   });

//   double get totalPrice => price * quantity;

//   Map<String, dynamic> toMap() => {
//         'id': id,
//         'name': name,
//         'imageUrl': imageUrl,
//         'price': price,
//         'quantity': quantity,
//       };

//   factory CartModel.fromMap(Map<String, dynamic> map) => CartModel(
//         id: map['id'],
//         name: map['name'],
//         imageUrl: List<String>.from(map['imageUrl'] ?? []), // ✅ FIX HERE
//         price: (map['price']).toDouble(),
//         quantity: map['quantity'] ?? 1,
//       );
// }
