import 'package:ProductPlug/core/common_widgets.dart/common_widgets.dart';
import 'package:ProductPlug/core/providers/admin/analytics_provider.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:ProductPlug/presentation/models/product_analytics_model.dart';
import 'package:ProductPlug/presentation/models/sale_entry_model.dart';
import 'package:ProductPlug/presentation/screens/admin/admin_product_sales_history/admin_product_sales_history_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminProductAnalyticsScreen extends StatefulWidget {
  final String productId;
  const AdminProductAnalyticsScreen({super.key, required this.productId});

  @override
  State<AdminProductAnalyticsScreen> createState() =>
      _ProductAnalyticsScreenState();
}

class _ProductAnalyticsScreenState extends State<AdminProductAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().getProductAnalytics(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // appBar: AppBar(
      //   title: const Text("Product Analytics"),
      //   backgroundColor: KprimaryColor,
      //   foregroundColor: Colors.white,
      //   elevation: 0,
      //   actions: [
      //     TextButton(
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (_) => AdminProductSalesHistoryScreen(
      //               productId: widget.productId,
      //             ),
      //           ),
      //         );
      //       },
      //       child: const Text(
      //         "Sales History",
      //         style: TextStyle(color: Colors.white, fontSize: 14),
      //       ),
      //     ),
      //     const SizedBox(width: 8),
      //   ],
      // ),
      appBar: adminCustomAppBar(
          context: context,
          title: 'Product Analytics',
          showBackButton: true,
          titleColor: Colors.black,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminProductSalesHistoryScreen(
                      productId: widget.productId,
                    ),
                  ),
                );
              },
              child: const Text(
                "Sales History",
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
          ]),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: KprimaryColor),
            );
          }

          final analytics = provider.analytics;
          final filteredSales = provider.filteredSales; // ✅ Use filtered sales

          if (analytics == null) {
            return const Center(
              child: Text(
                "No analytics data available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Row
                _buildFilterRow(provider),
                const SizedBox(height: 20),

                // KPI Cards Grid - Using overall analytics
                _buildKPICards(analytics),
                const SizedBox(height: 24),

                // Show filtered data info
                if (filteredSales.isEmpty)
                  _buildNoDataMessage()
                else ...[
                  // Revenue Trend Chart - Using filtered sales
                  _buildSectionTitle("Revenue Trend (${provider.filter})"),
                  const SizedBox(height: 12),
                  _buildRevenueChart(filteredSales),
                  const SizedBox(height: 24),

                  // Overview Chart
                  _buildSectionTitle("Performance Overview"),
                  const SizedBox(height: 12),
                  _buildOverviewChart(analytics),
                  const SizedBox(height: 24),

                  // Units Sold Over Time - Using filtered sales
                  _buildSectionTitle(
                      "Units Sold Over Time (${provider.filter})"),
                  const SizedBox(height: 12),
                  _buildQuantityChart(filteredSales),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 48),
            SizedBox(height: 12),
            Text(
              "No sales data for selected period",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildFilterRow(AnalyticsProvider provider) {
    final filters = ['Week', 'Month', 'Year', 'All Time'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = provider.filter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                provider.setFilter(filter);
              },
              selectedColor: KprimaryColor,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              elevation: isSelected ? 3 : 1,
              pressElevation: 5,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKPICards(ProductAnalytics analytics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                "Total Revenue",
                "\$${analytics.totalRevenue.toStringAsFixed(2)}",
                Icons.attach_money,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                "Total Sales",
                "${analytics.totalSales}",
                Icons.shopping_bag,
                KprimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                "Added to Cart",
                "${analytics.totalAddToCart}",
                Icons.shopping_cart_outlined,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                "Favorited",
                "${analytics.totalAddToFav}",
                Icons.favorite_border,
                Colors.pink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewChart(ProductAnalytics analytics) {
    final totalInteractions = analytics.totalAddToCart +
        analytics.totalAddToFav +
        analytics.totalSales;

    if (totalInteractions == 0) {
      return _buildEmptyChart();
    }

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem("Cart", Colors.orange),
                _buildLegendItem("Favorites", Colors.pink),
                _buildLegendItem("Sales", KprimaryColor),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxValue([
                        analytics.totalAddToCart.toDouble(),
                        analytics.totalAddToFav.toDouble(),
                        analytics.totalSales.toDouble(),
                      ]),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String label = '';
                            switch (group.x) {
                              case 0:
                                label =
                                    '${analytics.totalAddToCart} Added to Cart';
                                break;
                              case 1:
                                label = '${analytics.totalAddToFav} Favorited';
                                break;
                              case 2:
                                label = '${analytics.totalSales} Sold';
                                break;
                            }
                            return BarTooltipItem(
                              label,
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const labels = ['Cart', 'Favorites', 'Sales'];
                              if (value.toInt() >= 0 &&
                                  value.toInt() < labels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    labels[value.toInt()],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[200]!,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        _buildBarGroup(0, analytics.totalAddToCart.toDouble(),
                            Colors.orange),
                        _buildBarGroup(
                            1, analytics.totalAddToFav.toDouble(), Colors.pink),
                        _buildBarGroup(
                            2, analytics.totalSales.toDouble(), KprimaryColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildConversionFunnel(analytics),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConversionFunnel(ProductAnalytics analytics) {
    final cartToSalesRate = analytics.totalAddToCart > 0
        ? (analytics.totalSales / analytics.totalAddToCart * 100)
        : 0.0;
    final favToSalesRate = analytics.totalAddToFav > 0
        ? (analytics.totalSales / analytics.totalAddToFav * 100)
        : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Conversion',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        _buildConversionItem(
          'Cart → Sales',
          cartToSalesRate,
          Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildConversionItem(
          'Fav → Sales',
          favToSalesRate,
          Colors.pink,
        ),
      ],
    );
  }

  Widget _buildConversionItem(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 6,
            backgroundColor: color.withValues(alpha:0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(List<SaleEntry> filteredSales) {
    if (filteredSales.isEmpty) {
      return _buildEmptyChart();
    }

    final dailyData = _groupSalesByDate(filteredSales);
    final maxRevenue = dailyData.fold<double>(
        0, (max, e) => e['revenue'] > max ? e['revenue'] : max);

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxRevenue > 0 ? maxRevenue / 5 : 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200]!,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: dailyData.length > 7 ? 2 : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= dailyData.length) {
                    return const SizedBox();
                  }
                  final date = dailyData[index]['date'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('M/d').format(date),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: dailyData
                  .asMap()
                  .entries
                  .map((e) =>
                      FlSpot(e.key.toDouble(), e.value['revenue'] as double))
                  .toList(),
              isCurved: true,
              color: KprimaryColor,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: KprimaryColor,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    KprimaryColor.withValues(alpha:0.3),
                    KprimaryColor.withValues(alpha:0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index >= 0 && index < dailyData.length) {
                    final date = dailyData[index]['date'] as DateTime;
                    return LineTooltipItem(
                      '${DateFormat('MMM d').format(date)}\n\$${spot.y.toStringAsFixed(2)}',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
          ),
          minY: 0,
          maxY: maxRevenue > 0 ? maxRevenue * 1.2 : 10,
        ),
      ),
    );
  }

  Widget _buildQuantityChart(List<SaleEntry> filteredSales) {
    if (filteredSales.isEmpty) {
      return _buildEmptyChart();
    }

    final dailyData = _groupSalesByDate(filteredSales);
    final maxQuantity = dailyData.fold<int>(
        0, (max, e) => e['quantity'] > max ? e['quantity'] : max);

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxQuantity > 0 ? (maxQuantity * 1.2).toDouble() : 10,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (groupIndex >= 0 && groupIndex < dailyData.length) {
                  final date = dailyData[groupIndex]['date'] as DateTime;
                  return BarTooltipItem(
                    '${DateFormat('MMM d').format(date)}\n${rod.toY.toInt()} units',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: dailyData.length > 7 ? 2 : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < dailyData.length) {
                    final date = dailyData[index]['date'] as DateTime;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('M/d').format(date),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: dailyData
              .asMap()
              .entries
              .map((e) => BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: (e.value['quantity'] as int).toDouble(),
                        color: Colors.teal,
                        width: dailyData.length > 15 ? 12 : 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 32,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 48),
            SizedBox(height: 12),
            Text(
              "No data available for selected period",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupSalesByDate(List<SaleEntry> sales) {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (var sale in sales) {
      final date = sale.boughtAt.toDate();
      final key = DateFormat('yyyy-MM-dd').format(date);

      if (!grouped.containsKey(key)) {
        grouped[key] = {
          'date': date,
          'revenue': 0.0,
          'quantity': 0,
        };
      }

      grouped[key]!['revenue'] =
          (grouped[key]!['revenue'] as double) + sale.totalPrice;
      grouped[key]!['quantity'] =
          (grouped[key]!['quantity'] as int) + sale.quantity;
    }

    final sorted = grouped.values.toList()
      ..sort(
          (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    return sorted;
  }

  double _getMaxValue(List<double> values) {
    if (values.isEmpty) return 10;
    final max = values.reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble();
  }
}
