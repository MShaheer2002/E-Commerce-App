import 'package:ProductPlug/core/common_widgets.dart/common_widgets.dart';
import 'package:ProductPlug/core/providers/admin/banner_provider.dart';
import 'package:ProductPlug/core/providers/product_provider.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:ProductPlug/presentation/models/category_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Schedule initialization after the first frame to avoid context issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      productProvider.init();

      // Fetch banners from Firebase
      final bannerProvider =
          Provider.of<BannerProvider>(context, listen: false);
      bannerProvider.userFetchBanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Stack(
            children: [
              // Background
              SizedBox(height: height * 0.02),

              Positioned(
                top: height * 0.02,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    "assets/images/titles/exclusive_cleaned.png",
                    height: 40,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: height * 0.07),
                child: SingleChildScrollView(
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: Column(
                        children: [
                          // 🔍 Search + Favorite row
                          SizedBox(height: height * 0.02),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    context.push('/search-screen',
                                        extra: false);
                                  },
                                  child: Container(
                                    height: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                    ),
                                    child: const Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Icon(
                                            Icons.search,
                                            size: 28,
                                            color: KprimaryColor,
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
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: height * 0.02),

                          // Firebase Banner Carousel
                          _buildBannerCarousel(height, width),

                          homeWidget(height, width),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel(double height, double width) {
    final bannerProvider = Provider.of<BannerProvider>(context);
    final banners = bannerProvider.banners;

    // Show loading indicator while fetching
    if (bannerProvider.isLoading) {
      return Container(
        height: height * 0.2,
        width: width * 0.8,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: SmallLoader(backgroundColor: KprimaryColor, strokeWidth: 2),
        ),
      );
    }

    // If no banners, show placeholder
    if (banners.isEmpty) {
      return Container(
        height: height * 0.2,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                'No banners available',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: banners.length,
          options: CarouselOptions(
            height: height * 0.2,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: 0.85,
            aspectRatio: 16 / 9,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIdx) {
            final banner = banners[index];

            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Banner Image from Firebase
                  Image.network(
                    banner.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                            child: SmallLoader(
                                backgroundColor: KprimaryColor,
                                strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Gradient overlay for better dot visibility
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black38,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Dots Indicator
        if (banners.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: banners.asMap().entries.map((entry) {
                final isActive = entry.key == _currentIndex;
                return GestureDetector(
                  onTap: () => _carouselController.animateToPage(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: isActive ? 24 : 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget homeWidget(double height, double width) {
    final provider = Provider.of<ProductProvider>(context);
    final categories = provider.categories;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.02),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleWidget("Categories", () {
              context.push('/category-screen');
            }),
            SizedBox(height: height * 0.02),
            SizedBox(
              height: height * 0.15,
              child: categories.isEmpty
                  ? Center(
                      child: SmallLoader(
                          backgroundColor: KprimaryColor, strokeWidth: 2))
                  : ListView.builder(
                      itemCount: categories.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return categoryWidget(categories[index], height);
                      },
                    ),
            ),
            titleWidget("Products", () {
              context.push('/products');
            }),
            SizedBox(height: height * 0.02),
            SizedBox(
              height: height * 0.3,
              child: ListView.builder(
                itemCount: provider.products.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: width * 0.45,
                    child: ProductWidget(
                        provider.products[index], height, width, context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryWidget(CategoryModel category, double height) {
    return GestureDetector(
      onTap: () => context.push('/product-by-category', extra: category),
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        width: 70,
        child: Column(
          children: [
            ClipOval(
              child: Container(
                height: 70,
                width: 70,
                decoration: const BoxDecoration(color: Colors.white),
                child: cacheImage(
                  category.imageUrl,
                ),
              ),
            ),
            SizedBox(height: height * 0.01),
            Text(
              category.name,
              style: const TextStyle(
                color: KprimaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget titleWidget(String title, VoidCallback ontap) {
    return GestureDetector(
      onTap: ontap,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: KprimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: KprimaryColor,
          )
        ],
      ),
    );
  }
}
