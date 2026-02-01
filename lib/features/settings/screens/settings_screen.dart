import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ayarlar")),
      body: ListView(
        children: [
          SwitchListTile(value: true, onChanged: (v) {}, title: const Text("Bildirimleri Aç")),
          SwitchListTile(value: false, onChanged: (v) {}, title: const Text("Karanlık Mod")),
          ListTile(leading: const Icon(Icons.language), title: const Text("Dil Seçimi"), trailing: const Icon(Icons.chevron_right)),
          ListTile(leading: const Icon(Icons.lock), title: const Text("Gizlilik Politikası"), onTap: () {}),
        ],
      ),
    );
  }
}