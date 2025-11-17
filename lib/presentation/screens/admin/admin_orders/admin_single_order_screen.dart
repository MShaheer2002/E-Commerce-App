import 'dart:developer';

import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AdminSingleOrderScreen extends StatelessWidget {
  final OrderModel order;
  const AdminSingleOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    log("[Single Order Screen] ${order.toJson()}");

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF2D3436), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Order Details",
          style: TextStyle(
            color: Color(0xFF2D3436),
            fontSize: 20,
            fontFamily: "Urbanist",
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Order ID & Status Section
            _buildOrderHeader(context),

            const SizedBox(height: 12),

            // Order Items Section
            _buildOrderItemsSection(),

            const SizedBox(height: 12),

            // Payment Summary Section
            _buildPaymentSummary(),

            const SizedBox(height: 12),

            // Delivery Address Section
            _buildDeliveryAddress(),

            const SizedBox(height: 12),

            // Payment Information Section
            _buildPaymentInfo(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Order ID",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF636E72),
                  fontWeight: FontWeight.w500,
                ),
              ),
              _StatusBadge(status: order.orderStatus),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  "#${order.orderId}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ),
              IconButton(
                icon:
                    const Icon(Icons.copy, size: 18, color: Color(0xFF636E72)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: order.orderId ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order ID copied to clipboard'),
                      duration: Duration(seconds: 2),
                      backgroundColor: KprimaryColor,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE8E8E8)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Color(0xFF636E72)),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMMM dd, yyyy • hh:mm a')
                    .format(order.orderDate.toDate()),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF636E72),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 18, color: Color(0xFF636E72)),
              const SizedBox(width: 8),
              Text(
                "Customer: ${order.address.name}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF636E72),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  size: 20, color: KprimaryColor),
              const SizedBox(width: 8),
              const Text(
                "Order Items",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
              const Spacer(),
              Text(
                "${order.cartItems.length} ${order.cartItems.length == 1 ? 'item' : 'items'}",
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF636E72),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...order.cartItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (index > 0)
                  const Divider(height: 24, color: Color(0xFFE8E8E8)),
                _OrderItemCard(item: item),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final itemsTotal = order.cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.priceAtPurchase * item.quantity),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, size: 20, color: KprimaryColor),
              SizedBox(width: 8),
              Text(
                "Payment Summary",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SummaryRow(
              label: "Subtotal", value: "\$${itemsTotal.toStringAsFixed(2)}"),
          const SizedBox(height: 12),
          _SummaryRow(label: "Shipping", value: "\$0.00"),
          const SizedBox(height: 12),
          _SummaryRow(label: "Tax", value: "\$0.00"),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE8E8E8)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436),
                ),
              ),
              Text(
                "\$${order.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: KprimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 20, color: KprimaryColor),
              SizedBox(width: 8),
              Text(
                "Delivery Address",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AddressInfoRow(label: "Name", value: order.address.name),
          const SizedBox(height: 10),
          _AddressInfoRow(label: "Phone", value: order.address.phone),
          const SizedBox(height: 10),
          _AddressInfoRow(
            label: "Address",
            value: order.address.addressLine2 != null &&
                    order.address.addressLine2!.isNotEmpty
                ? "${order.address.addressLine1}, ${order.address.addressLine2}"
                : order.address.addressLine1,
          ),
          const SizedBox(height: 10),
          _AddressInfoRow(
            label: "City",
            value:
                "${order.address.city}, ${order.address.state} ${order.address.zip}",
          ),
          const SizedBox(height: 10),
          _AddressInfoRow(label: "Country", value: order.address.country),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment_outlined, size: 20, color: KprimaryColor),
              SizedBox(width: 8),
              Text(
                "Payment Information",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AddressInfoRow(
            label: "Payment Method",
            value: order.paymentMethod.toUpperCase(),
          ),
          const SizedBox(height: 10),
          _AddressInfoRow(
            label: "Transaction ID",
            value: order.paymentIntentId,
          ),
        ],
      ),
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  final dynamic item;

  const _OrderItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE8E8E8),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.product.imageUrls.isNotEmpty
                ? Image.network(
                    item.product.imageUrls[0],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFFB2BEC3),
                      size: 30,
                    ),
                  )
                : const Icon(
                    Icons.shopping_bag_outlined,
                    color: Color(0xFFB2BEC3),
                    size: 30,
                  ),
          ),
        ),
        const SizedBox(width: 14),
        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                "Quantity: ${item.quantity}",
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF636E72),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "\$${item.priceAtPurchase.toStringAsFixed(2)} each",
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF636E72),
                ),
              ),
            ],
          ),
        ),
        // Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "\$${(item.priceAtPurchase * item.quantity).toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3436),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF636E72),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }
}

class _AddressInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _AddressInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF636E72),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3436),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _getColor(),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case OrderStatus.placed:
        return const Color(0xFF0984E3);
      case OrderStatus.shipped:
        return const Color(0xFFFD79A8);
      case OrderStatus.delivered:
        return const Color(0xFF00B894);
      case OrderStatus.cancelled:
        return const Color(0xFFD63031);
    }
  }
}
