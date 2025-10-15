import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.06,
              ),
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
                                Container(color: _carouselColors[index]),

                                // optional gradient overlay for better text/dot contrast
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

                      // ⚪ Dots Indicator (inside the container)
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
                  homeWidet(height, width),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget homeWidet(double height, double width) {
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
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return categoryWidget(height);
                },
                scrollDirection: Axis.horizontal,
              ),
            ),
            titleWidget("Products", () {}),
            SizedBox(height: height * 0.02),
            SizedBox(
              height: height * 0.3,
              child: ListView.builder(
                itemCount: 10,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return productWidget(height, width);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryWidget(double height) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      width: 70,
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: height * 0.01),
          const Text(
            "Title",
            style: TextStyle(
              color: KprimaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center, // ensure center inside available width
          ),
        ],
      ),
    );
  }

  Widget productWidget(double height, double width) {
    return Container(
      width: width * 0.35, // responsive card width
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼 Product Image
          Container(
            height: height * 0.18,
            width: width * 0.35,
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(16)),
          ),

          SizedBox(height: height * 0.008),

          // 🏷 Brand
          const Text(
            "Brand",
            style: TextStyle(
              fontSize: 12,
              color: KprimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),

          // 📦 Product Name
          const Text(
            "Product name",
            style: TextStyle(
              fontSize: 13,
              color: KprimaryColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),

          // 💲 Price
          const Text(
            "\$10.99",
            style: TextStyle(
              fontSize: 14,
              color: KprimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget titleWidget(String title, VoidCallback ontap) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
              color: KprimaryColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 10),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: KprimaryColor,
        )
      ],
    );
  }
}
