import 'package:ProductPlug/core/common_widgets.dart/common_widgets.dart';
import 'package:ProductPlug/core/providers/product_provider.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    // Initial fetch if list is empty or force refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts(initialLoad: true);
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: customAppBar(context: context, title: "Products"),
      body: Background(
        showBackButton: false,
        child: provider.isLoading && provider.products.isEmpty
            ? Center(
                child:
                    SmallLoader(backgroundColor: KprimaryColor, strokeWidth: 2))
            : SmartRefresher(
                controller: _refreshController,
                enablePullUp: true,
                header: const WaterDropHeader(waterDropColor: KprimaryColor),
                onRefresh: () async {
                  await provider.fetchProducts(initialLoad: true);
                  _refreshController.refreshCompleted();
                  _refreshController.resetNoData();
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
                          height: height * 0.7,
                          alignment: Alignment.center,
                          child: const Text(
                            "No products found",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      )
                    : GridView.builder(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        itemCount: provider.products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          return ProductWidget(
                            provider.products[index],
                            height,
                            width,
                            context,
                          );
                        },
                      ),
              ),
      ),
    );
  }
}
