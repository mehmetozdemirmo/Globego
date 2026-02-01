import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class TimelineTile extends StatelessWidget {
  final CartItem item;
  final bool isFirst;
  final bool isLast;
  final int index;

  const TimelineTile({
    super.key,
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Sol taraftaki çizgi ve nokta
          SliverTimelineIndicator(isFirst: isFirst, isLast: isLast, index: index),

          // Sağ taraftaki içerik kartı
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 15, bottom: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  // Kategori İkonu
                  CircleAvatar(
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    child: Icon(_getIcon(), color: Colors.blueAccent, size: 20),
                  ),
                  const SizedBox(width: 15),
                  // Metin İçeriği
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${index + 1}. Durak: ${item.category}",
                            style: const TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        if (item.selectedDate != null)
                          Text("Tarih: ${item.selectedDate!.day}.${item.selectedDate!.month}.${item.selectedDate!.year}",
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text("${item.price.toStringAsFixed(0)} ₺", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (item.category) {
      case 'Oteller': return Icons.hotel;
      case 'Araçlar': return Icons.directions_car;
      case 'Turlar': return Icons.explore;
      case 'Restoranlar': return Icons.restaurant;
      default: return Icons.location_on;
    }
  }
}

// Çizgi ve Nokta Tasarımı
class SliverTimelineIndicator extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final int index;

  const SliverTimelineIndicator({super.key, required this.isFirst, required this.isLast, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: 2, height: 20, color: isFirst ? Colors.transparent : Colors.blueAccent.withOpacity(0.3)),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
          child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : Colors.blueAccent.withOpacity(0.3))),
      ],
    );
  }
}