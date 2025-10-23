import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/payment_intent.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel> selectedItems;

  const CheckoutScreen({
    super.key,
    required this.selectedItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedDelivery = 'standard';
  String selectedPayment = 'card'; // Changed default to card
  TextEditingController promoController = TextEditingController();
  bool promoApplied = false;
  double promoDiscount = 0.0;
  bool isProcessingPayment = false; // Add loading state

  double calculateSubtotal() {
    return widget.selectedItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double calculateShipping() {
    if (selectedDelivery == 'standard') return 0.0;
    if (selectedDelivery == 'express') return 5.0;
    return 10.0;
  }

  double calculateTaxes() {
    return calculateSubtotal() * 0.10; // 10% tax
  }

  double calculateTotal() {
    return calculateSubtotal() +
        calculateShipping() +
        calculateTaxes() -
        promoDiscount;
  }

  void applyPromoCode() {
    if (promoController.text.isNotEmpty) {
      setState(() {
        promoApplied = true;
        promoDiscount = 5.0; // Example discount
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promo code applied successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> handlePlaceOrder() async {
    // Validate shipping address (you can add your own validation)
    // For now, we'll skip this check

    final total = calculateTotal();

    if (selectedPayment == 'card') {
      // Show Stripe payment sheet for card payment
      setState(() {
        isProcessingPayment = true;
      });

      try {
        // This will show the Stripe payment UI
        // await showPaymentSheet(total);
        await showPaymentSheet(total);

        // Payment successful
        if (mounted) {
          _showOrderConfirmation(context);
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Payment failed';
          if (e.toString().contains('cancelled')) {
            errorMessage = 'Payment cancelled';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isProcessingPayment = false;
          });
        }
      }
    } else {
      // Cash on Delivery - no payment processing needed
      _showOrderConfirmation(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      // appBar: customAppBar(
      //   context: context,
      //   title: "Checkout",
      //   showBackButton: true,
      // ),
      body: Background(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              width * 0.04, height * 0.02, width * 0.04, height * 0.12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(height: height * 0.1),
                  // Centered Image
                  Center(
                    child: Image.asset(
                      "assets/images/titles/re_up_cleaned.png",
                      height: 40,
                    ),
                  ),
                  // Left Arrow
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: KprimaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              // Shipping Section
              _buildSectionHeader(context, 'SHIPPING', width),
              SizedBox(height: height * 0.015),
              _buildInfoCard(
                context: context,
                title: 'Add shipping address',
                icon: Icons.arrow_forward_ios,
                onTap: () {
                  // Navigate to address selection
                },
                width: width,
                height: height,
              ),
              SizedBox(height: height * 0.025),

              // Delivery Section
              _buildSectionHeader(context, 'DELIVERY', width),
              SizedBox(height: height * 0.015),
              _buildDeliveryOptions(width, height),
              SizedBox(height: height * 0.025),

              // Payment Section
              _buildSectionHeader(context, 'PAYMENT', width),
              SizedBox(height: height * 0.015),
              _buildPaymentOptions(width, height),
              SizedBox(height: height * 0.025),

              // Promo Code Section
              _buildSectionHeader(context, 'PROMOS', width),
              SizedBox(height: height * 0.015),
              _buildPromoCodeField(width, height),
              SizedBox(height: height * 0.025),

              // Items Section
              _buildSectionHeader(context, 'ITEMS', width),
              SizedBox(height: height * 0.015),
              _buildItemsList(width, height),
              SizedBox(height: height * 0.025),

              // Order Summary
              _buildOrderSummary(width, height),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.06),
        child: isProcessingPayment
            ? Container(
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(width: width * 0.04),
                    const Text(
                      'Processing...',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : buildAddToBasketButton(
                width,
                height,
                selectedPayment == 'card'
                    ? 'Pay \$${calculateTotal().toStringAsFixed(2)}'
                    : 'Place Order',
                handlePlaceOrder,
              ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, double width) {
    return Text(
      title,
      style: TextStyle(
        fontSize: width * 0.04,
        fontWeight: FontWeight.w600,
        color: KprimaryColor,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required double width,
    required double height,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.018,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: width * 0.04,
                      color: KprimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: height * 0.005),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: width * 0.035,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              icon,
              color: KprimaryColor,
              size: width * 0.045,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryOptions(double width, double height) {
    return Column(
      children: [
        _buildDeliveryOption(
          'Free',
          'Standard (3-7 days)',
          'standard',
          width,
          height,
        ),
        SizedBox(height: height * 0.012),
        _buildDeliveryOption(
          '\$5.00',
          'Express (1-2 days)',
          'express',
          width,
          height,
        ),
        SizedBox(height: height * 0.012),
        _buildDeliveryOption(
          '\$10.00',
          'Next Day',
          'nextday',
          width,
          height,
        ),
      ],
    );
  }

  Widget _buildDeliveryOption(
    String price,
    String description,
    String value,
    double width,
    double height,
  ) {
    bool isSelected = selectedDelivery == value;
    return InkWell(
      onTap: () {
        setState(() {
          selectedDelivery = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.018,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? KprimaryColor.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? KprimaryColor : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: width * 0.05,
              height: width * 0.05,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? KprimaryColor
                      : Colors.white.withOpacity(0.4),
                  width: 2,
                ),
                color: isSelected ? KprimaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: width * 0.03,
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: isSelected ? KprimaryColor : Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: width * 0.04,
                color: KprimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions(double width, double height) {
    return Column(
      children: [
        _buildPaymentOption(
          'Credit/Debit Card',
          'card',
          Icons.credit_card,
          width,
          height,
        ),
        SizedBox(height: height * 0.012),
        _buildPaymentOption(
          'Cash on Delivery',
          'cod',
          Icons.money,
          width,
          height,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    String title,
    String value,
    IconData icon,
    double width,
    double height,
  ) {
    bool isSelected = selectedPayment == value;
    return InkWell(
      onTap: () {
        setState(() {
          selectedPayment = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.018,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? KprimaryColor.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? KprimaryColor : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: width * 0.05,
              height: width * 0.05,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? KprimaryColor
                      : Colors.white.withOpacity(0.4),
                  width: 2,
                ),
                color: isSelected ? KprimaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: width * 0.03,
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(width: width * 0.03),
            Icon(
              icon,
              color: isSelected ? KprimaryColor : Colors.white.withOpacity(0.6),
              size: width * 0.05,
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: isSelected ? KprimaryColor : Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeField(double width, double height) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.012,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: promoController,
              style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.04,
              ),
              decoration: InputDecoration(
                hintText: 'Apply promo code',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: width * 0.04,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          InkWell(
            onTap: applyPromoCode,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.01,
              ),
              decoration: BoxDecoration(
                color: KprimaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Apply',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(double width, double height) {
    return Column(
      children: [
        // Header Row
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: height * 0.015,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'DESCRIPTION',
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w600,
                    color: KprimaryColor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'PRICE',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w600,
                    color: KprimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Items
        ...widget.selectedItems.asMap().entries.map((entry) {
          int index = entry.key;
          CartModel item = entry.value;
          bool isLast = index == widget.selectedItems.length - 1;

          return Container(
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              border: Border(
                bottom: BorderSide(
                  color: isLast
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              borderRadius: isLast
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    )
                  : BorderRadius.zero,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: width * 0.15,
                    height: width * 0.15,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: item.imageUrl.isNotEmpty
                        ? Image.network(
                            item.imageUrl[0],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.image_not_supported_outlined,
                              size: width * 0.06,
                              color: Colors.grey[400],
                            ),
                          )
                        : Icon(
                            Icons.shopping_bag_outlined,
                            size: width * 0.06,
                            color: Colors.grey[400],
                          ),
                  ),
                ),
                SizedBox(width: width * 0.03),
                // Details
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Brand',
                        style: TextStyle(
                          fontSize: width * 0.032,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      SizedBox(height: height * 0.003),
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height * 0.005),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: width * 0.032,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      SizedBox(height: height * 0.005),
                      Text(
                        'Quantity: ${item.quantity}',
                        style: TextStyle(
                          fontSize: width * 0.035,
                          color: KprimaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Price
                Expanded(
                  child: Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: KprimaryColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildOrderSummary(double width, double height) {
    double subtotal = calculateSubtotal();
    double shipping = calculateShipping();
    double taxes = calculateTaxes();
    double total = calculateTotal();

    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Subtotal (${widget.selectedItems.length})',
            '\$${subtotal.toStringAsFixed(2)}',
            width,
            false,
          ),
          SizedBox(height: height * 0.015),
          _buildSummaryRow(
            'Shipping total',
            shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(2)}',
            width,
            false,
          ),
          SizedBox(height: height * 0.015),
          _buildSummaryRow(
            'Taxes',
            '\$${taxes.toStringAsFixed(2)}',
            width,
            false,
          ),
          if (promoApplied) ...[
            SizedBox(height: height * 0.015),
            _buildSummaryRow(
              'Promo Discount',
              '-\$${promoDiscount.toStringAsFixed(2)}',
              width,
              false,
              color: Colors.green,
            ),
          ],
          SizedBox(height: height * 0.02),
          Divider(
            color: Colors.white.withOpacity(0.2),
            thickness: 1,
          ),
          SizedBox(height: height * 0.02),
          _buildSummaryRow(
            'Total',
            '\$${total.toStringAsFixed(2)}',
            width,
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    double width,
    bool isTotal, {
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? width * 0.045 : width * 0.038,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: color ??
                (isTotal ? Colors.white : Colors.white.withOpacity(0.7)),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? width * 0.05 : width * 0.04,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: color ?? KprimaryColor,
          ),
        ),
      ],
    );
  }

  void _showOrderConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            SizedBox(height: 16),
            Text(
              'Order Placed!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          selectedPayment == 'card'
              ? 'Your payment was successful and order has been placed.'
              : 'Your order has been placed successfully.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: TextStyle(color: KprimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    promoController.dispose();
    super.dispose();
  }
}
