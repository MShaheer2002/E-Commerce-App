import 'package:ProductPlug/core/common_widgets.dart/common_widgets.dart';
import 'package:ProductPlug/core/providers/admin/productManagement_provider.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
          ? Center(
              child:
                  SmallLoader(backgroundColor: KprimaryColor, strokeWidth: 2))
          : SmartRefresher(
              controller: _refreshController,
              enablePullUp: true,
              onRefresh: () async {
                await provider.fetchProducts(initialLoad: true);
                _refreshController.refreshCompleted();
                _refreshController
                    .resetNoData(); // Reset to allow loadmore again
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
                  ? SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: _buildEmptyState(),
                      ),
                    )
                  : ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: provider.products.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Search Box as a Header item
                          return GestureDetector(
                            onTap: () {
                              context.push('/search-screen', extra: true);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withValues(alpha: 0.7),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Row(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Icon(
                                      Icons.search,
                                      size: 28,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "Search...",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }

                        final product = provider.products[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: buildProductCard(
                            context,
                            product,
                            provider,
                            () {
                              context.push("/admin/analytics",
                                  extra: product.id);
                            },
                          ),
                        );
                      },
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

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
