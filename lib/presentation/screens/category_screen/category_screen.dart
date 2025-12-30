import 'package:ProductPlug/core/common_widgets.dart/common_widgets.dart';
import 'package:ProductPlug/core/providers/product_provider.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:ProductPlug/presentation/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    RefreshController _refreshController =
        RefreshController(initialRefresh: false);
    // Using MediaQuery for responsive sizing
    final width = MediaQuery.of(context).size.width;
    final productProvider = context.read<ProductProvider>();

    // Calculate grid properties
    const crossAxisCount = 2;
    const itemSpacing = 16.0;

    // Responsive size for each grid item (approximate 1:1 aspect ratio)
    final double itemSize =
        (width - (width * 0.08) - (itemSpacing * (crossAxisCount - 1))) /
            crossAxisCount;

    return Scaffold(
      appBar: customAppBar(
          context: context,
          title: "Categories",
          showBackButton: true), // Changed title per image
      resizeToAvoidBottomInset: false,
      body: Background(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SmartRefresher(
                  controller: _refreshController,
                  header: const WaterDropHeader(waterDropColor: KprimaryColor),
                  onRefresh: () {
                    productProvider.listenToCategory();
                    _refreshController.refreshCompleted();
                  },
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    itemCount: productProvider.categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => context.push('/product-by-category',
                            extra: productProvider.categories[index]),
                        child: CategoryItem(
                          category: productProvider.categories[index],
                          itemSize: itemSize,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final double itemSize;

  const CategoryItem(
      {super.key, required this.category, required this.itemSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: itemSize * 0.8,
          width: itemSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: cacheImage(
              category.imageUrl,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          category.name,
          style: const TextStyle(
            color: KprimaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
