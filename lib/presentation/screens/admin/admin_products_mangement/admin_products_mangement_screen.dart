import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/admin/productManagement_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AdminProductsMangementScreen extends StatefulWidget {
  const AdminProductsMangementScreen({super.key});

  @override
  State<AdminProductsMangementScreen> createState() =>
      _AdminProductsMangementScreenState();
}

class _AdminProductsMangementScreenState
    extends State<AdminProductsMangementScreen> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ProductmanagementProvider>()
          .fetchProducts(initialLoad: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductmanagementProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: adminCustomAppBar(
        context: context,
        title: "Products",
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_rounded, size: 20),
              ),
              onPressed: () => context.push('/admin/add-product'),
            ),
          )
        ],
        showBackButton: true,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SmartRefresher(
              controller: _refreshController,
              enablePullUp: true,
              onRefresh: () async {
                await provider.fetchProducts(initialLoad: true);
                _refreshController.refreshCompleted();
              },
              onLoading: () async {
                await provider.fetchProducts();
                if (!provider.hasMore) {
                  _refreshController.loadNoData();
                } else {
                  _refreshController.loadComplete();
                }
              },
              child: provider.products.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: provider.products.length,
                      itemBuilder: (context, index) {
                        final product = provider.products[index];
                        return _buildProductCard(
                          context,
                          product,
                          provider,
                          () {
                            context.push("/admin/analytics", extra: product.id);
                          },
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildProductCard(BuildContext context, product,
      ProductmanagementProvider provider, VoidCallback ontap) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: product.imageUrls.isNotEmpty
                        ? Image.network(
                            product.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                                size: 32),
                          )
                        : Icon(Icons.inventory_2_outlined,
                            color: Colors.grey[400], size: 32),
                  ),
                ),
                const SizedBox(width: 14),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              provider.getCategoryName(product.categoryId),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Menu
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded,
                        color: Colors.black54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    offset: const Offset(-10, 40),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        context.push('/admin/edit-product', extra: product);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, product, provider);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 20, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            const Text("Edit Product"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 20, color: Colors.red[700]),
                            const SizedBox(width: 12),
                            const Text("Delete"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Products Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first product',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, product, ProductmanagementProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await provider.deleteProduct(product.id!);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
