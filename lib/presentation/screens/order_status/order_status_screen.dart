import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/admin/order_management_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/models/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderStatusScreen extends StatelessWidget {
  const OrderStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return ChangeNotifierProvider(
      create: (_) => OrderManagementProvider()
        ..fetchOrderByUserAndStatus(userId, OrderStatus.placed),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: customAppBar(
            context: context,
            title: "Order History",
            showBackButton: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                // 🔹 Remove white background — AppBar’s image will show through
                color: Colors.transparent,
                child: const TabBar(
                  indicatorColor: KprimaryColor,
                  indicatorWeight: 3,
                  labelColor: KprimaryColor,
                  unselectedLabelColor: Color(0xFF636E72),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(text: "Placed"),
                    Tab(text: "Shipped"),
                    Tab(text: "Delivered"),
                    Tab(text: "Cancelled"),
                  ],
                ),
              ),
            ),
          ),
          body: Background(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                OrdersListView(status: OrderStatus.placed),
                OrdersListView(status: OrderStatus.shipped),
                OrdersListView(status: OrderStatus.delivered),
                OrdersListView(status: OrderStatus.cancelled),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrdersListView extends StatefulWidget {
  final OrderStatus status;
  OrdersListView({super.key, required this.status});
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  State<OrdersListView> createState() => _OrdersListViewState();
}

class _OrdersListViewState extends State<OrdersListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<OrderManagementProvider>()
          .fetchOrderByUserAndStatus(widget.userId, widget.status);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderManagementProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: KprimaryColor,
            ),
          );
        }

        final orders = provider.orders;
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  "No orders found",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: KprimaryColor,
          onRefresh: () => provider.fetchOrdersByStatus(widget.status),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _UserOrderCard(
                order: order,
              );
            },
          ),
        );
      },
    );
  }
}

class _UserOrderCard extends StatelessWidget {
  final OrderModel order;

  const _UserOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('MMM dd, yyyy • hh:mm a').format(order.orderDate.toDate());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900], // Dark grey background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Order #${order.orderId}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[100],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: order.orderStatus),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[700]),

          // Order Items Preview
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Items",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${order.cartItems.length}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Show first 2 items
                ...order.cartItems
                    .take(2)
                    .map((item) => _ProductItemPreview(item: item)),
                if (order.cartItems.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "+ ${order.cartItems.length - 2} more item${order.cartItems.length - 2 > 1 ? 's' : ''}",
                      style: TextStyle(
                        fontSize: 13,
                        color: KprimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[700]),

          // Footer Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: "${order.address.city}, ${order.address.country}",
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.payment_outlined,
                        text: order.paymentMethod.toUpperCase(),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: KprimaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "\$${order.totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: KprimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductItemPreview extends StatelessWidget {
  final dynamic item;

  const _ProductItemPreview({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.product.imageUrls.isNotEmpty
                  ? Image.network(
                      item.product.imageUrls[0],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: Color(0xFFB2BEC3),
                        size: 20,
                      ),
                    )
                  : const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFFB2BEC3),
                      size: 20,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Qty: ${item.quantity}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Price
          Text(
            "\$${(item.priceAtPurchase * item.quantity).toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF636E72)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF636E72),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
