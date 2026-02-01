import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class DetailsScreen extends StatelessWidget {
  final CartItem item;
  final VoidCallback onAddToCart;

  const DetailsScreen({super.key, required this.item, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Esnek Başlık (Resim alanı)
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(item.imagePath, fit: BoxFit.cover),
            ),
          ),
          // 2. İçerik Alanı
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("${item.price.toStringAsFixed(0)} ₺", style: const TextStyle(fontSize: 20, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 18),
                      Text(item.city, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 40),
                  const Text("Hakkında", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    "Bu tesis, şehrin kalbinde eşsiz bir deneyim sunmaktadır. Modern mimarisi, yüksek kaliteli hizmet anlayışı ve konforlu detaylarıyla seyahatinizi unutulmaz kılmak için tasarlanmıştır.",
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  _buildFeatureIcons(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildFeatureIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _featureIcon(Icons.wifi, "Ücretsiz Wifi"),
        _featureIcon(Icons.pool, "Havuz"),
        _featureIcon(Icons.ac_unit, "Klima"),
        _featureIcon(Icons.local_parking, "Otopark"),
      ],
    );
  }

  Widget _featureIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: SafeArea(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          onPressed: () {
            Navigator.pop(context);
            onAddToCart();
          },
          child: const Text("Planıma Ekle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}