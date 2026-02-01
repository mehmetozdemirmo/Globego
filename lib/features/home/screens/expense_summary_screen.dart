import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../planning/models/cart_item.dart';

class ExpenseSummaryScreen extends StatelessWidget {
  final List<CartItem> items;
  const ExpenseSummaryScreen({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    Map<String, double> categoryBudgets = {};
    for (var item in items) {
      categoryBudgets[item.category] = (categoryBudgets[item.category] ?? 0) + (item.price ?? 0.0);
    }

    double totalBudget = categoryBudgets.values.fold(0, (sum, price) => sum + price);

    final List<Color> colors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Harcama ve Plan Analizi")),
      body: items.isEmpty
          ? const Center(child: Text("Analiz edilecek veri bulunamadı."))
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("Toplam Bütçe: ${totalBudget.toStringAsFixed(0)} ₺",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 10),
            const Text("Harcama Dağılımınız", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: _buildChartSections(categoryBudgets, colors),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: categoryBudgets.entries.toList().asMap().entries.map((entry) {
                  int idx = entry.key;
                  var e = entry.value;
                  return _buildCategoryLegend(e.key, e.value, colors[idx % colors.length]);
                }).toList(),
              ),
            ),
            _buildSummaryInfo(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections(Map<String, double> data, List<Color> colors) {
    int index = 0;
    return data.entries.map((e) {
      final color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        color: color,
        value: e.value,
        title: '%${((e.value / data.values.fold(0.0, (s, v) => s + v)) * 100).toStringAsFixed(0)}',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Widget _buildCategoryLegend(String title, double amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 15, height: 15, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Text("${amount.toStringAsFixed(0)} ₺", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        ],
      ),
    );
  }

  Widget _buildSummaryInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.blueAccent),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "İpucu: Harcamalarınızı kategorize ederek bütçenizi daha verimli yönetebilirsiniz!",
              style: TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}