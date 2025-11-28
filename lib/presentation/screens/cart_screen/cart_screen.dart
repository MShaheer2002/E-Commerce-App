import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/cart_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/models/cartItem_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Set<String> selectedItems = {};
  bool selectAll = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void toggleSelectAll(List<CartItemModel> cartItems) {
    setState(() {
      selectAll = !selectAll;
      if (selectAll) {
        selectedItems =
            cartItems.map((item) => item.product.id as String).toSet();
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

  double calculateSelectedTotal(List<CartItemModel> cartItems) {
    return cartItems
        .where((item) => selectedItems.contains(item.product.id))
        .fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  void navigateToCheckout(List<CartItemModel> cartItems) {
    if (selectedItems.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Please select items to checkout',
          backgroundColor: Colors.black,
          textColor: Colors.white);
      return;
    }

    final selected = cartItems
        .where((item) => selectedItems.contains(item.product.id))
        .toList();

    final cartProvider = context.read<CartProvider>();
    cartProvider.setSelectedItems(selected);

    context.push("/checkout-screen");
  }

  Future<void> _refreshCart() async {
    final cartProvider = context.read<CartProvider>();
    await cartProvider.loadCart(); // Make sure your provider has this
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartService = context.watch<CartProvider>();
    final cartItems = cartService.items.values.toList();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Background(
        child: Column(
          children: [
            SizedBox(height: height * 0.02),
            SafeArea(
              child: Center(
                child: Image.asset(
                  "assets/images/titles/re_up_cleaned.png",
                  height: 40,
                ),
              ),
            ),
            if (cartItems.isEmpty)
              Expanded(
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
            else ...[
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
                      color: Colors.black.withValues(alpha: 0.04),
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
                            color:
                                selectAll ? KprimaryColor : Colors.grey[400]!,
                            width: 2,
                          ),
                          color: selectAll ? KprimaryColor : Colors.white,
                        ),
                        child: Icon(
                          Icons.check,
                          size: width * 0.04,
                          color: selectAll ? Colors.white : Colors.transparent,
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
                child: SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _refreshCart,
                  header: const WaterDropHeader(
                    waterDropColor: KprimaryColor,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final isSelected =
                          selectedItems.contains(item.product.id);

                      return buildCartItem(
                        context: context,
                        cartItem: item,
                        isSelected: isSelected,
                        onSelectToggle: () =>
                            toggleItemSelection(item.product.id ?? ''),
                        onDelete: () =>
                            cartService.removeFromCart(item.product.id ?? ''),
                        onQuantityChanged: (newQuantity) {
                          if (newQuantity > item.quantity) {
                            cartService.increaseQuantity(item.product.id ?? '');
                          } else {
                            cartService.decreaseQuantity(item.product.id ?? '');
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: cartItems.isEmpty
          ? null
          : Padding(
              padding: EdgeInsets.only(left: width * 0.06, right: width * 0.06),
              child: buildAddToBasketButton(
                width,
                height,
                'Total \$${selectedItems.isEmpty ? 0 : calculateSelectedTotal(cartItems).toStringAsFixed(2)} Checkout (${selectedItems.length})',
                () => navigateToCheckout(cartItems),
              ),
            ),
    );
  }
}

Widget buildCartItem({
  required BuildContext context,
  required CartItemModel cartItem,
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
          color: Colors.white.withValues(alpha: 0.04),
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
            child: cartItem.product.imageUrls.isNotEmpty
                ? Image.network(
                    cartItem.product.imageUrls[0],
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
                    Expanded(
                      child: Text(
                        cartItem.product.name,
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Delete Button
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: width * 0.06,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.006),
                Text(
                  '\$${cartItem.product.price.toStringAsFixed(2)}',
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
                      '\$${(cartItem.quantity * cartItem.product.price).toStringAsFixed(2)}',
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
