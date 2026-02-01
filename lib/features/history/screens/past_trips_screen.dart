import 'package:flutter/material.dart';

class PastTripsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> trips;
  const PastTripsScreen({super.key, required this.trips});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geçmiş Seyahatler"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: trips.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("Henüz tamamlanmış bir geziniz yok.",
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: trips.length,
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemBuilder: (context, index) {
          final trip = trips[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history_edu, color: Colors.blueAccent),
              ),
              title: Text(trip['location'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Tarih: ${trip['date']}\nEtkinlik Sayısı: ${trip['items'].length}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              isThreeLine: true,
              onTap: () {
                // Buraya tıklandığında seyahat detayları gösterilebilir
              },
            ),
          );
        },
      ),
    );
  }
}