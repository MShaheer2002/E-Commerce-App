import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/admin/global_analytics_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/models/sale_entry_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminGlobalAnalyticsScreen extends StatefulWidget {
  const AdminGlobalAnalyticsScreen({super.key});

  @override
  State<AdminGlobalAnalyticsScreen> createState() =>
      _AdminGlobalAnalyticsScreenState();
}

class _AdminGlobalAnalyticsScreenState
    extends State<AdminGlobalAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<GlobalAnalyticsProvider>().fetchGlobalAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: adminCustomAppBar(
        context: context,
        title: "Product Plug Analytics",
        titleColor: Colors.white,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              context.read<GlobalAnalyticsProvider>().generateAnalytics();
            },
            tooltip: "Regenerate Analytics",
          ),
        ],
      ),
      body: Consumer<GlobalAnalyticsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: SmallLoader(backgroundColor: KprimaryColor),
            );
          }

          final analytics = provider.analytics;

          if (analytics == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "No analytics available",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap refresh to generate",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter chips
                _buildFilterRow(provider),
                const SizedBox(height: 20),

                // KPI Cards
                _buildKPICards(provider, analytics),
                const SizedBox(height: 24),

                // Order Status Overview
                _buildSectionTitle("Order Status"),
                const SizedBox(height: 12),
                _buildOrderStatusChart(provider),
                const SizedBox(height: 24),

                // Revenue Trend
                _buildSectionTitle("Revenue Trend (${provider.filter})"),
                const SizedBox(height: 12),
                _buildRevenueChart(provider.filteredSales),
                const SizedBox(height: 24),

                // Items Sold Over Time
                _buildSectionTitle("Items Sold (${provider.filter})"),
                const SizedBox(height: 12),
                _buildItemsSoldChart(provider.filteredSales),
              ],
            ),
          );
        },
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

  Widget _buildFilterRow(GlobalAnalyticsProvider provider) {
    final filters = ['Week', 'Month', 'Year', 'All Time'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = provider.filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (_) => provider.setFilter(f),
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

  Widget _buildKPICards(GlobalAnalyticsProvider provider, dynamic analytics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                "Total Revenue",
                "\$${provider.filteredRevenue.toStringAsFixed(2)}",
                Icons.attach_money,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                "Total Orders",
                "${provider.filteredOrders.length}",
                Icons.shopping_bag_outlined,
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
                "Items Sold",
                "${provider.filteredItemsSold}",
                Icons.inventory_2_outlined,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                "Total Stock",
                "${analytics.totalStock}",
                Icons.store_outlined,
                Colors.blue,
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

  Widget _buildOrderStatusChart(GlobalAnalyticsProvider provider) {
    final total = provider.ordersCompleted +
        provider.ordersPending +
        provider.ordersCancelled;

    if (total == 0) {
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
      child: Row(
        children: [
          // Pie Chart
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: provider.ordersCompleted.toDouble(),
                    title:
                        '${((provider.ordersCompleted / total) * 100).toStringAsFixed(0)}%',
                    color: Colors.green,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: provider.ordersPending.toDouble(),
                    title:
                        '${((provider.ordersPending / total) * 100).toStringAsFixed(0)}%',
                    color: Colors.orange,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: provider.ordersCancelled.toDouble(),
                    title:
                        '${((provider.ordersCancelled / total) * 100).toStringAsFixed(0)}%',
                    color: Colors.red,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Legend
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem(
                    "Completed", provider.ordersCompleted, Colors.green),
                const SizedBox(height: 12),
                _buildLegendItem(
                    "Pending", provider.ordersPending, Colors.orange),
                const SizedBox(height: 12),
                _buildLegendItem(
                    "Cancelled", provider.ordersCancelled, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
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
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                "$count",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(List<SaleEntry> sales) {
    if (sales.isEmpty) {
      return _buildEmptyChart();
    }

    final dailyData = _groupSalesByDate(sales);
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
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
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
              color: Colors.green,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.green,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withValues(alpha:0.3),
                    Colors.green.withValues(alpha:0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          minY: 0,
          maxY: maxRevenue > 0 ? maxRevenue * 1.2 : 10,
        ),
      ),
    );
  }

  Widget _buildItemsSoldChart(List<SaleEntry> sales) {
    if (sales.isEmpty) {
      return _buildEmptyChart();
    }

    final dailyData = _groupSalesByDate(sales);
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
                    '${DateFormat('MMM d').format(date)}\n${rod.toY.toInt()} items',
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
                        color: Colors.orange,
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
}
