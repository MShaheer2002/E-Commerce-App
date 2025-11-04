import 'package:e_commerce_app/core/cache.dart';
import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/admin/global_analytics_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<GlobalAnalyticsProvider>().generateAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 56),
        child: adminCustomAppBar(
          context: context,
          title: "Dashboard",
          showBackButton: false,
          actions: [
            GestureDetector(
              onTap: () async {
                await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    bool isLoggingOut = false;

                    return StatefulBuilder(
                      builder: (context, setState) => AlertDialog(
                        title: const Text('Are you sure you want to logout?'),
                        content: isLoggingOut
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(strokeWidth: 2),
                                  SizedBox(width: 12),
                                  Text('Logging out...'),
                                ],
                              )
                            : const Text('This action cannot be undone.'),
                        actions: isLoggingOut
                            ? []
                            : <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('Yes, Logout'),
                                  onPressed: () async {
                                    setState(() => isLoggingOut = true);

                                    try {
                                      await context
                                          .read<AuthProvider>()
                                          .logout(context);

                                      final cache = CacheService();
                                      await cache.clearCache();

                                      if (context.mounted) {
                                        context.pop();
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('Logout failed: $e')),
                                        );
                                      }
                                      setState(() => isLoggingOut = false);
                                    }
                                  },
                                ),
                              ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.only(right: 15),
                child: const Icon(
                  Iconsax.logout4,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---- Dashboard Cards ----
            Consumer<GlobalAnalyticsProvider>(
              builder: (context, value, child) {
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    dashboardCard(
                      context,
                      icon: Iconsax.graph,
                      value:
                          "\$${(value.analytics?.totalRevenue ?? 0).toStringAsFixed(2)}",
                      title: "Today Sales",
                      gradientColors: [Colors.purple, Colors.purpleAccent],
                      isLoading: value.isLoading,
                    ),
                    dashboardCard(
                      context,
                      icon: Iconsax.box,
                      value: "${value.ordersPending}",
                      title: "Pending Orders",
                      gradientColors: [Colors.pinkAccent, Colors.pink],
                      isLoading: value.isLoading,
                    ),
                    dashboardCard(
                      context,
                      icon: Iconsax.layer,
                      value: "${value.analytics?.totalStock ?? 0}",
                      title: "Stock Available",
                      gradientColors: [Colors.cyan, Colors.lightBlueAccent],
                      isLoading: value.isLoading,
                    ),
                    dashboardCard(
                      context,
                      icon: Iconsax.shopping_cart,
                      value: "${value.todaySales}",
                      title: "Today Orders",
                      gradientColors: [Colors.orangeAccent, Colors.amber],
                      isLoading: value.isLoading,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            /// ---- Section: Management ----
            Text(
              "Management",
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            /// ---- Customers Section ----
            sectionTile(
              context,
              title: "Customers",
              subtitle: "View and manage registered users",
              icon: Iconsax.user,
              routeName: "/admin/customers",
            ),

            const SizedBox(height: 16),

            /// ---- Products Section ----
            sectionTile(
              context,
              title: "Products",
              subtitle: "View, edit or delete products",
              icon: Iconsax.box,
              routeName: "/admin/products",
            ),

            const SizedBox(height: 16),

            /// ---- Orders Section ----
            sectionTile(
              context,
              title: "Orders",
              subtitle: "Track and manage customer orders",
              icon: Iconsax.shopping_bag,
              routeName: "/admin/orders",
            ),

            const SizedBox(height: 16),

            /// ---- Analytics Section ----
            sectionTile(
              context,
              title: "Analytics",
              subtitle: "View sales and product performance",
              icon: Iconsax.chart,
              routeName: "/admin/global-analytics",
            ),
          ],
        ),
      ),
    );
  }

  /// ---- Dashboard Card ----
  Widget dashboardCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String title,
    required List<Color> gradientColors,
    required bool isLoading,
  }) {
    double width = MediaQuery.of(context).size.width;
    double cardWidth = (width - 60) / 2; // fits 2 per row

    return InkWell(
      onTap: () async {},
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 120,
        width: cardWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha:0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLoading == true
                      ? SizedBox(
                          height: 15,
                          width: 15,
                          child: SmallLoader(
                              backgroundColor: Colors.white, strokeWidth: 1))
                      : Text(
                          value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

  /// ---- Section Tile ----
  Widget sectionTile(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required String routeName}) {
    return InkWell(
      onTap: () => context.push(routeName),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha:0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: KprimaryColor.withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: KprimaryColor, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 24, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
