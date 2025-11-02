import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/checkout_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/models/address_model.dart';
import 'package:e_commerce_app/presentation/models/cartItem_model.dart';
import 'package:e_commerce_app/presentation/models/order_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/payment_intent.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemModel> selectedItems;

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

  // Address fields
  Map<String, dynamic>? selectedAddress;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressLine1Controller = TextEditingController();
  TextEditingController addressLine2Controller = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  double calculateSubtotal() {
    return widget.selectedItems
        .fold(0.0, (sum, item) => sum + (item.quantity * item.product.price));
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
      Fluttertoast.showToast(
          msg: 'Promo code applied successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white);
    }
  }

  void _showAddAddressDialog() {
    // Clear previous values
    nameController.clear();
    phoneController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    cityController.clear();
    stateController.clear();
    zipController.clear();
    countryController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Add Shipping Address',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAddressTextField('Full Name', nameController),
              const SizedBox(height: 12),
              _buildAddressTextField('Phone Number', phoneController),
              const SizedBox(height: 12),
              _buildAddressTextField('Address Line 1', addressLine1Controller),
              const SizedBox(height: 12),
              _buildAddressTextField(
                  'Address Line 2 (Optional)', addressLine2Controller),
              const SizedBox(height: 12),
              _buildAddressTextField('City', cityController),
              const SizedBox(height: 12),
              _buildAddressTextField('State/Province', stateController),
              const SizedBox(height: 12),
              _buildAddressTextField('ZIP/Postal Code', zipController),
              const SizedBox(height: 12),
              _buildAddressTextField('Country', countryController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_validateAddress()) {
                setState(() {
                  selectedAddress = {
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'addressLine1': addressLine1Controller.text,
                    'addressLine2': addressLine2Controller.text,
                    'city': cityController.text,
                    'state': stateController.text,
                    'zip': zipController.text,
                    'country': countryController.text,
                  };
                });
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                    msg: 'Address added successfully!',
                    backgroundColor: Colors.green);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: KprimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTextField(
      String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: KprimaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  bool _validateAddress() {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressLine1Controller.text.isEmpty ||
        cityController.text.isEmpty ||
        stateController.text.isEmpty ||
        zipController.text.isEmpty ||
        countryController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Please fill all required fields',
          backgroundColor: Colors.red,
          textColor: Colors.white);
      return false;
    }
    return true;
  }

  String _getAddressPreview() {
    if (selectedAddress == null) return 'Add shipping address';
    return '${selectedAddress!['name']}, ${selectedAddress!['addressLine1']}, ${selectedAddress!['city']}, ${selectedAddress!['state']} ${selectedAddress!['zip']}';
  }

  void _printOrderDetails(CheckoutProvider provider, String paymentIndentId) {
    AddressModel addressModel = AddressModel.fromMap(selectedAddress!);
    final OrderModel order = OrderModel(
      userId: provider.userId,
      cartItems: widget.selectedItems,
      totalAmount: double.parse(calculateTotal().toStringAsFixed(2)),
      orderDate: Timestamp.now(),
      paymentIntentId: paymentIndentId,
      paymentMethod: 'card',
      address: addressModel,
      orderStatus: OrderStatus.placed,
    );

    log('========================================');
    log('ORDER CONFIRMATION');
    log('========================================');
    log('Order Date: ${DateTime.now()}');
    log('');
    log("[checkout] ${order.toJson().toString()}");

    context.read<CheckoutProvider>().handlePurchase(context, order);
  }

  Future<void> handlePlaceOrder(CheckoutProvider checkoutprovider) async {
    // Validate shipping address
    if (selectedAddress == null) {
      Fluttertoast.showToast(
          msg: 'Please add a shipping address',
          backgroundColor: Colors.red,
          textColor: Colors.white);
      return;
    }

    final total = calculateTotal();

    if (selectedPayment == 'card') {
      // Show Stripe payment sheet for card payment
      setState(() {
        isProcessingPayment = true;
      });

      try {
        // This will show the Stripe payment UI
        // await showPaymentSheet(total);
        final paymentindentId = await showPaymentSheet(total);

        // Payment successful - Print order details
        _printOrderDetails(checkoutprovider, paymentindentId);

        if (mounted) {
          _showOrderConfirmation(context);
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Payment failed';
          if (e.toString().contains('cancelled')) {
            errorMessage = 'Payment cancelled';
          }

          Fluttertoast.showToast(
              msg: errorMessage, backgroundColor: Colors.red);
        }
      } finally {
        if (mounted) {
          setState(() {
            isProcessingPayment = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      nameController.text = "Muhammad Shaheer";
      phoneController.text = "+923113304672";
      addressLine1Controller.text = "house no 907, airport road unit no 11";
      cityController.text = "Hyderbad";
      stateController.text = "Sindh";
      zipController.text = "17000";
      countryController.text = "Pakistan";
    }
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final checkoutProvider = Provider.of<CheckoutProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      icon: const Icon(
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
                title: selectedAddress == null
                    ? 'Add shipping address'
                    : _getAddressPreview(),
                subtitle: selectedAddress != null ? 'Tap to change' : null,
                icon: selectedAddress == null ? Icons.add : Icons.edit,
                onTap: _showAddAddressDialog,
                width: width,
                height: height,
              ),
              SizedBox(height: height * 0.025),

              // // Delivery Section
              // _buildSectionHeader(context, 'DELIVERY', width),
              // SizedBox(height: height * 0.015),
              // _buildDeliveryOptions(width, height),
              // SizedBox(height: height * 0.025),

              // // Payment Section
              // _buildSectionHeader(context, 'PAYMENT', width),
              // SizedBox(height: height * 0.015),
              // _buildPaymentOptions(width, height),
              // SizedBox(height: height * 0.025),

              // // Promo Code Section
              // _buildSectionHeader(context, 'PROMOS', width),
              // SizedBox(height: height * 0.015),
              // _buildPromoCodeField(width, height),
              // SizedBox(height: height * 0.025),

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
                () => handlePlaceOrder(checkoutProvider),
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
          CartItemModel item = entry.value;
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
                    child: item.product.imageUrls.isNotEmpty
                        ? Image.network(
                            item.product.imageUrls[0],
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
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      SizedBox(height: height * 0.003),
                      Text(
                        item.product.name,
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
                    '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
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
            shipping == 0 ? 'Free' : '\${shipping.toStringAsFixed(2)}',
            width,
            false,
          ),
          SizedBox(height: height * 0.015),
          _buildSummaryRow(
            'Taxes',
            '\${taxes.toStringAsFixed(2)}',
            width,
            false,
          ),
          if (promoApplied) ...[
            SizedBox(height: height * 0.015),
            _buildSummaryRow(
              'Promo Discount',
              '\$${promoDiscount.toStringAsFixed(2)}',
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
        title: const Column(
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
            child: const Text(
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
    nameController.dispose();
    phoneController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    countryController.dispose();
    super.dispose();
  }
}
