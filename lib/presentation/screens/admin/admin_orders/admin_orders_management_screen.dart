import 'package:ProductPlug/core/providers/admin/order_management_provider.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:ProductPlug/presentation/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
          backgroundColor: Colors.grey[50],
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
            physics: NeverScrollableScrollPhysics(),
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
              return _OrderCard(
                order: order,
                index: index,
              );
            },
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final int index;

  const _OrderCard({required this.order, required this.index});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('MMM dd, yyyy • hh:mm a').format(order.orderDate.toDate());

    return GestureDetector(
      onTap: () => context.push("/admin/single-order-screen", extra: order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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

            // Shipping Info Section (Only for Shipped Status)
            if (order.orderStatus == OrderStatus.shipped &&
                order.trackingNumber != null &&
                order.trackingNumber!.isNotEmpty)
              Column(
                children: [
                  const Divider(height: 1, color: Color(0xFFE8E8E8)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _ShippingInfoCard(order: order),
                  ),
                ],
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
                          text:
                              "${order.address.city}, ${order.address.country}",
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
                      color: KprimaryColor.withValues(alpha: 0.1),
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
        onSelected: (newStatus) {
          if (newStatus == OrderStatus.shipped) {
            // Show dialog for shipping details
            _showShippingDialog(context, provider);
          } else {
            provider.updateOrderStatus(order.orderId!, newStatus);
          }
        },
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

  void _showShippingDialog(
      BuildContext context, OrderManagementProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => _ShippingDialog(
        orderId: order.orderId!,
        provider: provider,
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
        return [];
      case OrderStatus.cancelled:
        return [];
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

// Shipping Info Card Widget
class _ShippingInfoCard extends StatelessWidget {
  final OrderModel order;

  const _ShippingInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 18,
                color: Color(0xFFFD79A8),
              ),
              SizedBox(width: 8),
              Text(
                "Shipping Information",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Delivery Partner Icon
              if (order.deliveryPartner != null)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                    ),
                  ),
                  child: SvgPicture.asset(
                    'assets/svgs/${order.deliveryPartner!.name}.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              const SizedBox(width: 12),
              // Tracking Number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.deliveryPartner != null
                          ? _capitalize(order.deliveryPartner!.name)
                          : "Delivery Partner",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.trackingNumber ?? "N/A",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3436),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Copy Button
              IconButton(
                onPressed: () {
                  if (order.trackingNumber != null &&
                      order.trackingNumber!.isNotEmpty) {
                    Clipboard.setData(
                        ClipboardData(text: order.trackingNumber!));
                    Fluttertoast.showToast(
                      msg: "Tracking number copied!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                },
                icon: const Icon(
                  Icons.copy_outlined,
                  size: 18,
                  color: KprimaryColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }
}

// Shipping Dialog Widget
class _ShippingDialog extends StatefulWidget {
  final String orderId;
  final OrderManagementProvider provider;

  const _ShippingDialog({
    required this.orderId,
    required this.provider,
  });

  @override
  State<_ShippingDialog> createState() => _ShippingDialogState();
}

class _ShippingDialogState extends State<_ShippingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _trackingController = TextEditingController();
  DeliveryPartner? _selectedPartner;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: KprimaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: KprimaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Mark as Shipped",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Delivery Partner Dropdown
              const Text(
                "Delivery Partner",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<DeliveryPartner>(
                value: _selectedPartner,
                decoration: InputDecoration(
                  hintText: "Select delivery partner",
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: KprimaryColor),
                  ),
                ),
                items: DeliveryPartner.values
                    .map((partner) => DropdownMenuItem(
                          value: partner,
                          child: Text(
                            _capitalize(partner.name),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPartner = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Please select a delivery partner";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tracking Number Field
              const Text(
                "Tracking Number",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _trackingController,
                decoration: InputDecoration(
                  hintText: "Enter tracking number",
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: KprimaryColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter tracking number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFE8E8E8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF636E72),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KprimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Confirm",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.provider.addOrderStatus(
        widget.orderId,
        _selectedPartner!.name,
        _trackingController.text.trim(),
      );

      // Update order status to shipped
      await widget.provider.updateOrderStatus(
        widget.orderId,
        OrderStatus.shipped,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
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
