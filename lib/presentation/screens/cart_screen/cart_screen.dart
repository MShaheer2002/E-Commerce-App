import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/cart_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Set<String> selectedItems = {};
  bool selectAll = false;

  void toggleSelectAll(List cartItems) {
    setState(() {
      selectAll = !selectAll;
      if (selectAll) {
        selectedItems = cartItems.map((item) => item.id as String).toSet();
      } else {
        selectedItems.clear();
      }
    });
  }

  void toggleItemSelection(String id) {
    setState(() {
      if (selectedItems.contains(id)) {
        selectedItems.remove(id);
        selectAll = false;
      } else {
        selectedItems.add(id);
      }
    });
  }

  double calculateSelectedTotal(List cartItems) {
    return cartItems
        .where((item) => selectedItems.contains(item.id))
        .fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    final cartService = context.watch<CartProvider>();
    final cartItems = cartService.items.values.toList();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: "Shopping Cart (${cartItems.length})",
        showBackButton: false,
      ),
      body: Background(
        child: cartItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: width * 0.25,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: height * 0.02),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: width * 0.05,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Select All Bar
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: height * 0.015,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: height * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => toggleSelectAll(cartItems),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: EdgeInsets.all(width * 0.005),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectAll
                                    ? KprimaryColor
                                    : Colors.grey[400]!,
                                width: 2,
                              ),
                              color: selectAll ? KprimaryColor : Colors.white,
                            ),
                            child: Icon(
                              Icons.check,
                              size: width * 0.04,
                              color:
                                  selectAll ? Colors.white : Colors.transparent,
                            ),
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Text(
                          'Select All',
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (selectedItems.isNotEmpty)
                          Text(
                            '${selectedItems.length} selected',
                            style: TextStyle(
                              fontSize: width * 0.035,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Cart Items List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final isSelected = selectedItems.contains(item.id);

                        return buildCartItem(
                          context: context,
                          cartItem: item,
                          isSelected: isSelected,
                          onSelectToggle: () => toggleItemSelection(item.id),
                          onDelete: () => cartService.removeFromCart(item.id),
                          onQuantityChanged: (newQuantity) {
                            if (newQuantity > item.quantity) {
                              cartService.increaseQuantity(item.id);
                            } else {
                              cartService.decreaseQuantity(item.id);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: cartItems.isEmpty
          ? null
          // : Container(
          //     padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          //     child: Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         // Total Summary Card
          //         Container(
          //           padding: EdgeInsets.all(width * 0.04),
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: BorderRadius.circular(16),
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.black.withOpacity(0.08),
          //                 blurRadius: 16,
          //                 offset: const Offset(0, -4),
          //               ),
          //             ],
          //           ),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: [
          //               Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text(
          //                     'Total',
          //                     style: TextStyle(
          //                       fontSize: width * 0.035,
          //                       color: Colors.grey[600],
          //                     ),
          //                   ),
          //                   SizedBox(height: height * 0.005),
          //                   Text(
          //                     'Rs. ${selectedItems.isEmpty ? 0 : calculateSelectedTotal(cartItems).toStringAsFixed(2)}',
          //                     style: TextStyle(
          //                       fontSize: width * 0.055,
          //                       fontWeight: FontWeight.bold,
          //                       color: Colors.black87,
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //               ElevatedButton(
          //                 onPressed: selectedItems.isEmpty
          //                     ? null
          //                     : () {
          //                         final selected = cartItems
          //                             .where((item) =>
          //                                 selectedItems.contains(item.id))
          //                             .toList();
          //                         // Pass selected items to checkout
          //                         print('Checkout items: $selected');
          //                       },
          //                 style: ElevatedButton.styleFrom(
          //                   backgroundColor: selectedItems.isEmpty
          //                       ? Colors.grey[300]
          //                       : Colors.blue[600],
          //                   foregroundColor: Colors.white,
          //                   padding: EdgeInsets.symmetric(
          //                     horizontal: width * 0.1,
          //                     vertical: height * 0.02,
          //                   ),
          //                   shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(12),
          //                   ),
          //                   elevation: 0,
          //                 ),
          //                 child: Text(
          //                   'Checkout (${selectedItems.length})',
          //                   style: TextStyle(
          //                     fontSize: width * 0.04,
          //                     fontWeight: FontWeight.w600,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          : Padding(
              padding: EdgeInsets.only(left: width * 0.06, right: width * 0.06),
              child: buildAddToBasketButton(
                width,
                height,
                'Total ${selectedItems.isEmpty ? 0 : calculateSelectedTotal(cartItems).toStringAsFixed(2)} Checkout (${selectedItems.length})',
                () {
                  final selected = cartItems
                      .where((item) => selectedItems.contains(item.id))
                      .toList();

                  if (selected.isEmpty) {
                    return;
                  } else {
                    context.push("/checkout-screen", extra: selected);
                  }
                },
              ),
            ),
    );
  }
}

Widget buildCartItem({
  required BuildContext context,
  required cartItem,
  required bool isSelected,
  required VoidCallback onSelectToggle,
  required VoidCallback onDelete,
  required Function(int) onQuantityChanged,
}) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;

  return Container(
    margin: EdgeInsets.symmetric(
      horizontal: width * 0.04,
      vertical: height * 0.008,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // Checkbox
        InkWell(
          onTap: onSelectToggle,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: EdgeInsets.all(width * 0.005),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? KprimaryColor : Colors.white,
            ),
            child: Icon(
              Icons.check,
              size: width * 0.04,
              color: isSelected ? Colors.white : Colors.transparent,
            ),
          ),
        ),
        SizedBox(width: width * 0.03),

        // Product Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: width * 0.2,
            height: width * 0.2,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: cartItem.imageUrl.isNotEmpty
                ? Image.network(
                    cartItem.imageUrl[0],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.image_not_supported_outlined,
                      size: width * 0.08,
                      color: Colors.grey[400],
                    ),
                  )
                : Icon(
                    Icons.shopping_bag_outlined,
                    size: width * 0.08,
                    color: Colors.grey[400],
                  ),
          ),
        ),
        SizedBox(width: width * 0.03),

        // Product Details
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: height * 0.005),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      cartItem.name,
                      style: TextStyle(
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    // Delete Button
                    Container(
                      child: Container(
                        child: InkWell(
                          onTap: onDelete,
                          borderRadius: BorderRadius.circular(8),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                            size: width * 0.06,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.006),
                Text(
                  '${cartItem.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: width * 0.038,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: height * 0.012),

                // Quantity Controls
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (cartItem.quantity > 1) {
                                onQuantityChanged(cartItem.quantity - 1);
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: EdgeInsets.all(width * 0.02),
                              child: Icon(
                                Icons.remove,
                                size: width * 0.04,
                                color: cartItem.quantity > 1
                                    ? Colors.black87
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.035,
                            ),
                            child: Text(
                              '${cartItem.quantity}',
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              onQuantityChanged(cartItem.quantity + 1);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: EdgeInsets.all(width * 0.02),
                              child: Icon(
                                Icons.add,
                                size: width * 0.04,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${cartItem.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
