import 'package:flutter/material.dart';
import '../../planning/models/cart_item.dart';

class CartScreen extends StatelessWidget {
  final List<CartItem> items;
  final Function(int) onDelete;
  final VoidCallback onApprove;

  const CartScreen({
    super.key,
    required this.items,
    required this.onDelete,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: items.isEmpty
          ? _buildEmptyCart()
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildCartItem(context, item, index);
              },
            ),
          ),
          _buildBottomAction(context),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile( // Detayları göstermek için ExpansionTile kullanabiliriz veya ListTile'ı genişletebiliriz
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(item.category),
            color: Colors.blueAccent,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${item.city} • ${item.category}",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 4),
            // --- YENİ EKLENEN SEÇİM DETAYLARI ---
            _buildSelectionDetails(item),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${item.price?.toStringAsFixed(0)} ₺",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _confirmDelete(context, index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kullanıcının seçtiği özel detayları (Tarih, Menü vb.) gösteren widget
  Widget _buildSelectionDetails(CartItem item) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        // Tarih seçilmişse göster
        // item.selectedDate! yerine tarih formatlanmış halini yazıyoruz:
        if (item.selectedDate != null)
          _buildDetailChip(
              Icons.calendar_month,
              "${item.selectedDate!.day}.${item.selectedDate!.month}.${item.selectedDate!.year}", // String'e çevirdik
              Colors.orange
          ),
        // Yemek/Menü seçilmişse göster
        if (item.selectedMenu != null)
          _buildDetailChip(Icons.restaurant_menu, item.selectedMenu!, Colors.green),

        // Ekstra seçenekler (Klima, Sigorta vb.) varsa göster
        if (item.extraOption != null)
          _buildDetailChip(Icons.add_circle_outline, item.extraOption!, Colors.purple),
      ],
    );
  }

  // Detay kutucukları (Chip tasarımı)
  Widget _buildDetailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'oteller': return Icons.hotel;
      case 'araçlar': return Icons.directions_car;
      case 'turlar': return Icons.explore;
      case 'restoranlar': return Icons.restaurant;
      default: return Icons.bookmark;
    }
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Öğeyi Sil"),
        content: const Text("Bu seçimi planınızdan kaldırmak istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç")),
          TextButton(
            onPressed: () {
              onDelete(index);
              Navigator.pop(context);
            },
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            "Sepetiniz Boş",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          const Text(
            "Keşfetmeye başlayın ve planınıza\naktiviteler ekleyin!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    // Toplam fiyat hesaplama
    double totalPrice = items.fold(0, (sum, item) => sum + (item.price ?? 0));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Toplam Tutar", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Text(
                      "${totalPrice.toStringAsFixed(0)} ₺",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    "${items.length} Etkinlik",
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Seyahati Onayla ve Bitir"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}