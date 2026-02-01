import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // MENÜ ÜST BİLGİSİ (User Header)
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.blueAccent),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
            ),
            accountName: const Text("Mehmet Yılmaz", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text("mehmet@email.com"),
          ),

          // KAYDIRILABİLİR LİSTE ALANI
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSectionTitle("Aktif Seyahat"),
                _buildMenuItem(Icons.qr_code_2, "Bilet / QR Kod", () {}),
                _buildMenuItem(Icons.check_circle_outline, "Check-in Bilgileri", () {}),

                const Divider(),
                _buildSectionTitle("Geçmiş Seyahatler"),
                _buildMenuItem(Icons.history, "Tamamlanan Geziler", () {}),
                _buildMenuItem(Icons.pie_chart_outline, "Harcama Özeti", () {}),

                const Divider(),
                _buildSectionTitle("Ayarlar"),
                _buildMenuItem(Icons.language, "Dil / Para Birimi", () {}),
                _buildMenuItem(Icons.notifications_none, "Bildirim Tercihleri", () {}),

                const Divider(),
                _buildSectionTitle("Yardım & Destek"),
                _buildMenuItem(Icons.help_outline, "Destek Merkezi", () {}),
                _buildMenuItem(Icons.info_outline, "Uygulama Hakkında", () {}),
              ],
            ),
          ),

          // ÇIKIŞ BUTONU
          const Divider(),
          _buildMenuItem(Icons.logout, "Çıkış Yap", () {}, color: Colors.red),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Bölüm başlıkları için yardımcı widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 10, bottom: 5),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Menü öğeleri için yardımcı widget
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {Color color = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: TextStyle(color: color, fontSize: 14),
      ),
      onTap: onTap,
      dense: true, // Menüyü daha kompakt yapar
    );
  }
}