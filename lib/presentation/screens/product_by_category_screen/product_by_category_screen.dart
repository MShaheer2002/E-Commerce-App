import 'package:ProductPlug/core/common_widgets.dart/common_widgets.dart';
import 'package:ProductPlug/core/providers/category_provider.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:ProductPlug/presentation/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductByCategoryScreen extends StatefulWidget {
  final CategoryModel categoryModel;

  const ProductByCategoryScreen({
    super.key,
    required this.categoryModel,
  });

  @override
  State<ProductByCategoryScreen> createState() =>
      _ProductByCategoryScreenState();
}

class _ProductByCategoryScreenState extends State<ProductByCategoryScreen> {
  final RefreshController _refreshController = RefreshController();
  @override
  void initState() {
    super.initState();
    // Trigger fetch only once when screen opens
    Future.microtask(() {
      context.read<CategoryProvider>().fetchProductsByCategory(
          categoryId: widget.categoryModel.id, isInitalFetch: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: customAppBar(context: context, title: widget.categoryModel.name),
      body: Background(
        showBackButton: false,
        child: categoryProvider.isloading
            ? Center(child: SmallLoader())
            : categoryProvider.productsByCategory.isEmpty
                ? const Center(
                    child: Text(
                      "No products found in this category.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : SmartRefresher(
                    controller: _refreshController,
                    enablePullUp: true,
                    header:
                        const WaterDropHeader(waterDropColor: KprimaryColor),
                    onRefresh: () async {
                      await categoryProvider.fetchProductsByCategory(
                          categoryId: widget.categoryModel.id,
                          isInitalFetch: true);
                      _refreshController.refreshCompleted();
                      _refreshController.resetNoData();
                    },
                    onLoading: () async {
                      await categoryProvider.fetchProductsByCategory(
                          categoryId: widget.categoryModel.id);
                      if (!categoryProvider.hasMore) {
                        _refreshController.loadNoData();
                      } else {
                        _refreshController.loadComplete();
                      }
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: categoryProvider.productsByCategory.length,
                      itemBuilder: (context, index) {
                        final product =
                            categoryProvider.productsByCategory[index];
                        return ProductWidget(product, height, width, context);
                      },
                    ),
                  ),
      ),
    );
  }
}
