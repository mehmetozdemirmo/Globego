// lib/features/trips/screens/ticket_screen.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // QR kod için bu paketi eklemelisin!

// pubspec.yaml dosyana ekle:
// dependencies:
//   qr_flutter: ^4.1.0 # En son sürümü kontrol et

class TicketScreen extends StatelessWidget {
  final Map<String, dynamic> tripDetails; // Onaylanan seyahat bilgileri

  const TicketScreen({super.key, required this.tripDetails});

  @override
  Widget build(BuildContext context) {
    // Seyahat detaylarını burada ayrıştırabiliriz
    final String location = tripDetails['location'] ?? 'Bilinmiyor';
    final String date = tripDetails['date'] ?? 'Tarih Yok';
    final List<dynamic> items = tripDetails['items'] ?? [];
    final String qrData = "TripID: ${tripDetails['id']}\nLocation: $location\nDate: $date";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seyahat Biletiniz"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      const Icon(Icons.flight_takeoff, size: 60, color: Colors.blueAccent),
                      const SizedBox(height: 20),
                      Text(
                        location,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Planlanan Tarih: $date",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      // QR Kod Alanı
                      QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        errorStateBuilder: (cxt, err) {
                          return const Center(
                            child: Text(
                              "QR Kodu oluşturulamadı.",
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      const Divider(height: 1, thickness: 1, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text(
                        "Seyahat Detayları",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      // Eklenen öğeleri listele
                      if (items.isEmpty)
                        const Text("Henüz detaylı etkinlik eklenmemiş.")
                      else
                        ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(_getCategoryIcon(item.category), color: Colors.green),
                              const SizedBox(width: 10),
                              Expanded(child: Text(item.title)),
                            ],
                          ),
                        )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Bu bileti paylaşma veya kaydetme işlevi eklenebilir
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Biletiniz başarıyla kaydedildi!")),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text("Bileti Kaydet / Paylaş"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kategoriye göre ikon belirleme (CartScreen'den kopyalandı)
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'oteller': return Icons.hotel;
      case 'araçlar': return Icons.directions_car;
      case 'turlar': return Icons.explore;
      case 'restoranlar': return Icons.restaurant;
      default: return Icons.bookmark;
    }
  }
}