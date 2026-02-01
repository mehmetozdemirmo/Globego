import 'package:flutter/material.dart';

class TicketScreen extends StatelessWidget {
  final Map<String, dynamic> tripDetails;
  const TicketScreen({super.key, required this.tripDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seyahat Bileti")),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flight_takeoff, size: 50, color: Colors.blueAccent),
              const SizedBox(height: 20),
              Text(tripDetails['location'] ?? "Bilinmeyen Yer", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Tarih: ${tripDetails['date']}", style: const TextStyle(color: Colors.grey)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                child: const Icon(Icons.qr_code_2, size: 150),
              ),
              const SizedBox(height: 20),
              const Text("QR Kodu terminalde okutunuz", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}