import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/admin/settings_provider.dart';
import 'package:e_commerce_app/core/providers/admin/state_tax_provider.dart';
import 'package:e_commerce_app/core/providers/cart_provider.dart';
import 'package:e_commerce_app/core/providers/checkout_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/models/address_model.dart';
import 'package:e_commerce_app/presentation/models/cartItem_model.dart';
import 'package:e_commerce_app/presentation/models/order_model.dart';
import 'package:e_commerce_app/presentation/models/promo_model.dart';
import 'package:e_commerce_app/presentation/models/tax_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/payment_intent.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedDelivery = 'standard';
  String selectedPayment = 'card';
  TextEditingController promoController = TextEditingController();
  bool promoApplied = false;
  double promoDiscount = 0.0;
  double stateShippingTax = 0.0;
  bool isProcessingPayment = false;

  // Address fields
  Map<String, dynamic>? selectedAddress;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressLine1Controller = TextEditingController();
  TextEditingController addressLine2Controller = TextEditingController();
  TextEditingController zipController = TextEditingController();

  // Dropdown values
  String? selectedCountry = 'United States';
  String? selectedState;
  String? selectedCity;

  List<String> availableStates = [];
  List<String> availableCities = [];

  List<CartItemModel> cartItems = [];

  @override
  void initState() {
    super.initState();
    _initializeData();

    if (kDebugMode) {
      promoController.text = "Summer20";
      nameController.text = "Muhammad Shaheer";
      phoneController.text = "+923113304672";
    }
  }

  Future<void> _initializeData() async {
    await UsStatesCitiesData.loadData();
    setState(() {
      availableStates = UsStatesCitiesData.getStates();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().fetchGlobalPromo();
      context.read<SettingsProvider>().fetchTaxes();
    });
  }

  double calculateSubtotal() {
    return cartItems.fold(
        0.0, (sum, item) => sum + (item.quantity * item.product.price));
  }

  double calculateShipping() {
    double total = 0.0;

    for (int i = 0; i < cartItems.length; i++) {
      total += double.parse(cartItems[i].product.shippingCharges);
    }

    return total;
  }

  Future<void> getStateSaleTax(String name) async {
    final shippingTax =
        await context.read<StateTaxProvider>().fetchSelectedStateTax(name);
    setState(() {
      stateShippingTax = (shippingTax?.taxRate ?? 0.0) * cartItems.length;
    });
  }

  double calculateTaxes() {
    final settingsProvider = context.read<SettingsProvider>();
    final taxes = settingsProvider.taxes;

    if (taxes.isEmpty) return 0.0;

    double totalTax = 0.0;
    final subtotal = calculateSubtotal();

    for (var tax in taxes) {
      if (tax.isActive) {
        totalTax += tax.calculateTax(subtotal);
      }
    }

    return totalTax;
  }

  double calculateTotal() {
    return calculateSubtotal() +
        calculateShipping() +
        calculateTaxes() +
        stateShippingTax -
        promoDiscount;
  }

  void applyPromoCode(List<PromoCode> promoCodes) {
    final enteredCode = promoController.text.trim().toUpperCase();

    if (enteredCode.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter a promo code",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }

    PromoCode? matchingPromo;
    try {
      matchingPromo = promoCodes.firstWhere(
        (promo) =>
            promo.code.toUpperCase() == enteredCode.toUpperCase() &&
            promo.isCurrentlyValid,
      );
    } catch (_) {
      matchingPromo = null;
    }

    if (matchingPromo == null) {
      Fluttertoast.showToast(
        msg: "Invalid or expired promo code",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      promoApplied = true;
      promoDiscount = matchingPromo?.discountPercent ?? 0;
    });

    Fluttertoast.showToast(
      msg: "Promo code applied: ${matchingPromo.discountPercent}% off",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _showAddAddressDialog() {
    nameController.clear();
    phoneController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    zipController.clear();
    selectedCountry = 'United States';
    selectedState = null;
    selectedCity = null;
    availableCities = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Add Shipping Address',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAddressTextField('Full Name', nameController),
                const SizedBox(height: 12),
                _buildAddressTextField('Phone Number', phoneController),
                const SizedBox(height: 12),

                // Country Dropdown
                _buildDropdownField(
                  label: 'Country',
                  value: selectedCountry,
                  items: ['United States'],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCountry = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // State Dropdown
                _buildDropdownField(
                  label: 'State',
                  value: selectedState,
                  items: availableStates,
                  onChanged: (value) async {
                    log("[State change] $value");
                    setDialogState(() {
                      selectedState = value;
                      selectedCity = null;
                      availableCities = value != null
                          ? UsStatesCitiesData.getCitiesForState(value)
                          : [];
                    });
                    await getStateSaleTax(value ?? '');
                  },
                ),
                const SizedBox(height: 12),

                // City Dropdown
                _buildDropdownField(
                  label: 'City',
                  value: selectedCity,
                  items: availableCities,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCity = value;
                    });
                  },
                  enabled: selectedState != null,
                ),
                const SizedBox(height: 12),

                _buildAddressTextField(
                    'Address Line 1', addressLine1Controller),
                const SizedBox(height: 12),
                _buildAddressTextField(
                    'Address Line 2 (Optional)', addressLine2Controller),
                const SizedBox(height: 12),
                _buildAddressTextField('ZIP/Postal Code', zipController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_validateAddress()) {
                  setState(() {
                    selectedAddress = {
                      'name': nameController.text,
                      'phone': phoneController.text,
                      'country': selectedCountry,
                      'state': selectedState,
                      'city': selectedCity,
                      'addressLine1': addressLine1Controller.text,
                      'addressLine2': addressLine2Controller.text,
                      'zip': zipController.text,
                    };
                  });
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(
                    msg: 'Address added successfully!',
                    backgroundColor: Colors.green,
                  );
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      dropdownColor: Colors.grey[850],
      style: const TextStyle(color: Colors.white),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }

  Widget _buildAddressTextField(
      String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
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
        selectedCountry == null ||
        selectedState == null ||
        selectedCity == null ||
        addressLine1Controller.text.isEmpty ||
        zipController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please fill all required fields',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
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
      cartItems: cartItems,
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
    log('[checkout] ${order.toJson().toString()}');

    context.read<CheckoutProvider>().handlePurchase(context, order);
  }

  Future<void> handlePlaceOrder(CheckoutProvider checkoutprovider) async {
    if (selectedAddress == null) {
      Fluttertoast.showToast(
        msg: 'Please add a shipping address',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final total = calculateTotal();

    if (selectedPayment == 'card') {
      setState(() {
        isProcessingPayment = true;
      });

      try {
        final paymentindentId = await showPaymentSheet(
            total, context.read<CheckoutProvider>().getCurrUserEmail());
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
    final cartProvider = context.watch<CartProvider>();
    cartItems = cartProvider.selectedItems.toList();

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final checkoutProvider = Provider.of<CheckoutProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  Center(
                    child: Image.asset("assets/images/titles/re_up_cleaned.png",
                        height: 40),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: KprimaryColor, size: 20),
                    ),
                  ),
                ],
              ),
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
              _buildSectionHeader(context, 'PROMOS', width),
              SizedBox(height: height * 0.015),
              _buildPromoCodeField(width, height),
              SizedBox(height: height * 0.025),
              _buildSectionHeader(context, 'ITEMS', width),
              SizedBox(height: height * 0.015),
              _buildItemsList(width, height),
              SizedBox(height: height * 0.025),
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
                    const Text('Processing...',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600)),
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
            horizontal: width * 0.04, vertical: height * 0.018),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: width * 0.04,
                          color: Colors.white,
                          fontWeight: FontWeight.w500)),
                  if (subtitle != null) ...[
                    SizedBox(height: height * 0.005),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: width * 0.035,
                            color: Colors.white.withValues(alpha: 0.6))),
                  ],
                ],
              ),
            ),
            Icon(icon, color: Colors.white, size: width * 0.045),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeField(double width, double height) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.04, vertical: height * 0.012),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: promoController,
              style: TextStyle(color: Colors.white, fontSize: width * 0.04),
              decoration: InputDecoration(
                hintText: 'Apply promo code',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: width * 0.04),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Consumer<SettingsProvider>(
            builder: (context, value, child) {
              return InkWell(
                onTap: () =>
                    applyPromoCode(value.globalSettings?.promoCodes ?? []),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04, vertical: height * 0.01),
                  decoration: BoxDecoration(
                      color: KprimaryColor,
                      borderRadius: BorderRadius.circular(8)),
                  child: value.isLoading == true
                      ? Center(
                          child: SmallLoader(
                              backgroundColor: Colors.white, strokeWidth: 2))
                      : Text('Apply',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w600)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(double width, double height) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.04, vertical: height * 0.015),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('DESCRIPTION',
                    style: TextStyle(
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
              Expanded(
                child: Text('PRICE',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
        ...cartItems.asMap().entries.map((entry) {
          int index = entry.key;
          CartItemModel item = entry.value;
          bool isLast = index == cartItems.length - 1;

          return Container(
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              border: Border(
                  bottom: BorderSide(
                      color: isLast
                          ? Colors.transparent
                          : Colors.white.withValues(alpha: 0.05),
                      width: 1)),
              borderRadius: isLast
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12))
                  : BorderRadius.zero,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: width * 0.15,
                    height: width * 0.15,
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8)),
                    child: item.product.imageUrls.isNotEmpty
                        ? Image.network(item.product.imageUrls[0],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.image_not_supported_outlined,
                                size: width * 0.06,
                                color: Colors.grey[400]))
                        : Icon(Icons.shopping_bag_outlined,
                            size: width * 0.06, color: Colors.grey[400]),
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Brand',
                          style: TextStyle(
                              fontSize: width * 0.032,
                              color: Colors.white.withOpacity(0.5))),
                      SizedBox(height: height * 0.003),
                      Text(item.product.name,
                          style: TextStyle(
                              fontSize: width * 0.038,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: height * 0.005),
                      Text('Quantity: ${item.quantity}',
                          style: TextStyle(
                              fontSize: width * 0.035,
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                      '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOrderSummary(double width, double height) {
    double subtotal = calculateSubtotal();
    double shipping = calculateShipping();
    double total = calculateTotal();

    final settingsProvider = context.watch<SettingsProvider>();
    final taxList =
        settingsProvider.taxes.where((tax) => tax.isActive).toList();

    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Subtotal (${cartItems.length})',
              '\$${subtotal.toStringAsFixed(2)}', width, false),
          SizedBox(height: height * 0.015),
          _buildSummaryRow(
              'Shipping total',
              shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(2)}',
              width,
              false),
          if (stateShippingTax != 0.0) ...[
            SizedBox(height: height * 0.015),
            _buildSummaryRow(
                "State Sales tax (${stateShippingTax / cartItems.length}%)",
                '\$${stateShippingTax.toStringAsFixed(2)}',
                width,
                false),
          ],
          if (taxList.isNotEmpty) ...[
            SizedBox(height: height * 0.015),
            ...taxList.map((tax) {
              double taxAmount = tax.calculateTax(subtotal);
              String taxLabel = tax.type == TaxType.percentage
                  ? '${tax.name} (${tax.rate}%)'
                  : tax.name;
              return Padding(
                padding: EdgeInsets.only(bottom: height * 0.015),
                child: _buildSummaryRow(taxLabel,
                    '\$${taxAmount.toStringAsFixed(2)}', width, false),
              );
            }),
          ],
          if (promoApplied) ...[
            SizedBox(height: height * 0.015),
            _buildSummaryRow('Promo Discount',
                '-\$${promoDiscount.toStringAsFixed(2)}', width, false,
                color: Colors.green),
          ],
          SizedBox(height: height * 0.02),
          Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),
          SizedBox(height: height * 0.02),
          _buildSummaryRow(
              'Total', '\$${total.toStringAsFixed(2)}', width, true,
              color: KprimaryColor),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
      String label, String value, double width, bool isTotal,
      {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? width * 0.045 : width * 0.038,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: color ??
                (isTotal ? Colors.white : Colors.white.withValues(alpha: 0.7)),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? width * 0.05 : width * 0.04,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.white,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text('Order Placed!',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          selectedPayment == 'card'
              ? 'Your payment was successful and order has been placed.'
              : 'Your order has been placed successfully.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
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
    zipController.dispose();
    super.dispose();
  }
}
