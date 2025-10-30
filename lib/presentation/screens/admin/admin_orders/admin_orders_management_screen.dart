import 'package:e_commerce_app/core/providers/admin/order_management_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce_app/presentation/models/order_model.dart';

class AdminOrdersManagementScreen extends StatelessWidget {
  const AdminOrdersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          OrderManagementProvider()..fetchOrdersByStatus(OrderStatus.placed),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
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
              "Order Management",
              style: TextStyle(
                color: Color(0xFF2D3436),
                fontSize: 20,
                fontFamily: "Urbanist",
                fontWeight: FontWeight.w600,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
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
          body: const TabBarView(
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
    );
  }
}

class OrdersListView extends StatefulWidget {
  final OrderStatus status;
  const OrdersListView({super.key, required this.status});

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
          .fetchOrdersByStatus(widget.status);
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
              return _OrderCard(order: order);
            },
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('MMM dd, yyyy • hh:mm a').format(order.orderDate.toDate());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                          Text(
                            "Order #${order.orderId}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3436),
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
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusMenu(context),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE8E8E8)),

          // Products Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ordered Items",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 12),
                ...order.cartItems.map((item) => _ProductItem(item: item)),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE8E8E8)),

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
                    color: KprimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF636E72),
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

  Widget _buildStatusMenu(BuildContext context) {
    final provider = context.read<OrderManagementProvider>();
    final availableStatuses = _getAvailableStatuses(order.orderStatus);

    if (availableStatuses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<OrderStatus>(
        icon: const Icon(Icons.more_horiz, color: Color(0xFF636E72)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        offset: const Offset(0, 8),
        onSelected: (newStatus) =>
            provider.updateOrderStatus(order.orderId!, newStatus),
        itemBuilder: (context) {
          return availableStatuses
              .map((status) => PopupMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Mark as ${_capitalize(status.name)}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ))
              .toList();
        },
      ),
    );
  }

  List<OrderStatus> _getAvailableStatuses(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.placed:
        return [
          OrderStatus.shipped,
          OrderStatus.delivered,
          OrderStatus.cancelled,
        ];
      case OrderStatus.shipped:
        return [
          OrderStatus.placed,
          OrderStatus.delivered,
          OrderStatus.cancelled,
        ];
      case OrderStatus.delivered:
        return []; // Cannot change from delivered
      case OrderStatus.cancelled:
        return []; // Cannot change from cancelled
    }
  }

  Color _getStatusColor(OrderStatus status) {
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

  String _capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _ProductItem extends StatelessWidget {
  final dynamic item;

  const _ProductItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE8E8E8),
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
                      ),
                    )
                  : const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFFB2BEC3),
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
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Price
          Text(
            "\$${item.priceAtPurchase.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 15,
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
        color: _getColor().withOpacity(0.1),
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
