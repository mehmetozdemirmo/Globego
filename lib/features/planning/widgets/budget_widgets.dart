import 'package:flutter/material.dart';

class SpendingSummary extends StatelessWidget {
  final Map<String, double> budgets;
  final double totalBudget;

  const SpendingSummary({
    super.key,
    required this.budgets,
    required this.totalBudget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_outline, color: Colors.blueAccent, size: 20),
              SizedBox(width: 8),
              Text(
                "Harcama Dağılımı",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Kategorilere göre harcama satırları
          ...budgets.entries.where((entry) => entry.value > 0).map((entry) {
            return _buildBudgetRow(context, entry.key, entry.value);
          }).toList(),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Toplam Planlanan",
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              Text(
                "${totalBudget.toStringAsFixed(0)} ₺",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(BuildContext context, String category, double amount) {
    // Kategoriye göre ikon belirleme
    IconData icon;
    switch (category.toLowerCase()) {
      case 'oteller': icon = Icons.hotel; break;
      case 'araçlar': icon = Icons.directions_car; break;
      case 'turlar': icon = Icons.explore; break;
      case 'restoranlar': icon = Icons.restaurant; break;
      default: icon = Icons.category;
    }

    // Yüzde hesaplama
    double percentage = totalBudget > 0 ? (amount / totalBudget) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(category, style: const TextStyle(fontSize: 14)),
              ),
              Text(
                "${amount.toStringAsFixed(0)} ₺",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}