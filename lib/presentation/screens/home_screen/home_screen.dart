import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/product_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/models/category_model.dart';
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

  final List<Color> _carouselColors = [
    Colors.amber,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.listenToCategory();
    provider.listenToProducts();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Background(
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
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withOpacity(0.7),
                          ),
                          child: const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
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
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.favorite,
                          color: KprimaryColor,
                          size: 30,
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: height * 0.02),

                  Stack(
                    children: [
                      CarouselSlider.builder(
                        carouselController: _carouselController,
                        itemCount: _carouselColors.length,
                        options: CarouselOptions(
                          height: height * 0.2,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          enlargeCenterPage: true,
                          viewportFraction: 0.8,
                          aspectRatio: 16 / 9,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                        ),
                        itemBuilder: (context, index, realIdx) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: _carouselColors[index]),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.06),
                                  child: Row(
                                    children: [
                                      Text(
                                        '50% \nDiscount!',
                                        style: TextStyle(
                                            fontFamily: "Urbanist",
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20),
                                      ),
                                      
                                    ],
                                  ),
                                ),
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
                                          Colors.black26,
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

                      // ⚪ Dots Indicator
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              _carouselColors.asMap().entries.map((entry) {
                            final isActive = entry.key == _currentIndex;
                            return GestureDetector(
                              onTap: () =>
                                  _carouselController.animateToPage(entry.key),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                height: 8,
                                width: isActive ? 20 : 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                  homeWidget(height, width),
                ],
              ),
            ),
          ),
        ),
      ),
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
            titleWidget("Categories", () {}),
            SizedBox(height: height * 0.02),
            SizedBox(
              height: height * 0.14,
              child: categories.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: categories.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return categoryWidget(categories[index], height);
                      },
                    ),
            ),

            SizedBox(height: height * 0.03),
            titleWidget("Products", () {
              context.push('/products');
            }),

            // You can implement product UI similarly by mapping provider.products
            SizedBox(height: height * 0.02),
            SizedBox(
              height: height * 0.3,
              child: ListView.builder(
                itemCount: provider.products.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return ProductWidget(provider.products[index], height, width);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryWidget(CategoryModel category, double height) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      width: 70,
      child: Column(
        children: [
          ClipOval(
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(color: Colors.white),
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
