import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class EventDetailPage extends StatelessWidget {
  final CartItem item;

  const EventDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Görüntü ve Başlık Alanı
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
              background: Image.asset(item.imagePath, fit: BoxFit.cover),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Genel Bilgiler"),
                  _buildInfoTile(Icons.location_city, "Şehir", item.city),
                  _buildInfoTile(Icons.category, "Kategori", item.category),
                  _buildInfoTile(Icons.star, "Puan", "${item.star} / 5.0"),

                  const Divider(height: 40),

                  _buildSectionTitle("Senin Seçimlerin"),
                  // CartItem içindeki yeni alanları burada gösteriyoruz
                  _buildInfoTile(Icons.calendar_month, "Seçilen Tarih",
                      item.selectedDate != null ? "${item.selectedDate!.day}.${item.selectedDate!.month}.${item.selectedDate!.year}" : "Tarih Belirtilmedi"),

                  if (item.selectedMenu != null)
                    _buildInfoTile(Icons.restaurant_menu, "Seçilen Menü/Paket", item.selectedMenu!),

                  if (item.extraOption != null)
                    _buildInfoTile(Icons.add_circle_outline, "Ekstra", item.extraOption!),

                  const SizedBox(height: 30),

                  // Fiyat Bilgisi Kartı
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.3))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Toplam Tutar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(item.formattedPrice, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}