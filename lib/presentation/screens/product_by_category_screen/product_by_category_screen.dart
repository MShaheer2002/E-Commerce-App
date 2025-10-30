import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/category_provider.dart';
import 'package:e_commerce_app/presentation/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    // Trigger fetch only once when screen opens
    Future.microtask(() {
      context
          .read<CategoryProvider>()
          .fetchProductsByCategory(widget.categoryModel.id);
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
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: categoryProvider.productsByCategory.length,
                    itemBuilder: (context, index) {
                      final product =
                          categoryProvider.productsByCategory[index];
                      return ProductWidget(product, height, width, context);
                    },
                  ),
      ),
    );
  }
}
