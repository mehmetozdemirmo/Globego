import 'package:flutter/material.dart';
import 'ticket_screen.dart';

class PastTripsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> trips;
  const PastTripsScreen({super.key, required this.trips});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geçmiş Seyahatler")),
      body: trips.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            const Text("Henüz tamamlanmış bir geziniz yok.", style: TextStyle(color: Colors.grey)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.flight_takeoff, color: Colors.white, size: 20),
              ),
              title: Text(trip['location'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Tarih: ${trip['date']} • ${trip['items'].length} etkinlik"),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TicketScreen(tripDetails: trip)));
              },
            ),
          );
        },
      ),
    );
  }
}