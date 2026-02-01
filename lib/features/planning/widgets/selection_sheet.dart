import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class SelectionSheet extends StatefulWidget {
  final CartItem item;
  final Function(CartItem) onConfirm;

  const SelectionSheet({super.key, required this.item, required this.onConfirm});

  @override
  State<SelectionSheet> createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<SelectionSheet> {
  DateTime? selectedDate;
  String? selectedMeal;
  int duration = 1;
  double extraPrice = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      // Alt panelin cihazın klavyesi veya navigation bar'ı ile çakışmaması için
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 30),

          // --- DİNAMİK İÇERİK ---
          // Kategori isimlerini projedeki yazım şekline göre kontrol ediyoruz
          if (widget.item.category == "Oteller" || widget.item.category == "Turlar")
            _buildDatePicker(),

          if (widget.item.category == "Restoranlar")
            _buildMealSelection(),

          if (widget.item.category == "Araçlar" || widget.item.category == "Araç Kiralama")
            _buildDurationPicker(),

          const SizedBox(height: 30),
          _buildTotalAndConfirm(),
        ],
      ),
    );
  }

  // Başlık Bölümü
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                widget.item.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(widget.item.city, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.grey)
        ),
      ],
    );
  }

  // Tarih Seçici (Oteller ve Turlar için)
  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Colors.blueAccent),
        title: Text(
          selectedDate == null
              ? "Seyahat Tarihi Seçiniz"
              : "${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}",
          style: TextStyle(
            color: selectedDate == null ? Colors.blueAccent : Colors.black87,
            fontWeight: selectedDate == null ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.blueAccent),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) setState(() => selectedDate = picked);
        },
      ),
    );
  }

  // Yemek/Öğün Seçimi (Restoranlar için)
  Widget _buildMealSelection() {
    final meals = {
      "Standart Menü": 0.0,
      "Full Paket (İçecek Dahil)": 150.0,
      "Şefin Tadım Menüsü": 350.0
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text("Menü Seçimi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        ...meals.entries.map((meal) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedMeal == meal.key ? Colors.blueAccent : Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: RadioListTile<String>(
            activeColor: Colors.blueAccent,
            title: Text(meal.key, style: const TextStyle(fontSize: 14)),
            subtitle: Text("+ ${meal.value.toStringAsFixed(0)} ₺", style: const TextStyle(color: Colors.green)),
            value: meal.key,
            groupValue: selectedMeal,
            onChanged: (val) {
              setState(() {
                selectedMeal = val;
                extraPrice = meal.value;
              });
            },
          ),
        )),
      ],
    );
  }

  // Süre Seçici (Araç Kiralama için)
  Widget _buildDurationPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Kiralama Süresi", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Gün bazlı hesaplanır", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () => setState(() => duration > 1 ? duration-- : null),
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent)
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text("$duration", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                  onPressed: () => setState(() => duration++),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.green)
              ),
            ],
          )
        ],
      ),
    );
  }

  // Alt Onay Butonu
  Widget _buildTotalAndConfirm() {
    // Toplam fiyat hesabı
    double basePrice = widget.item.price ?? 0.0;
    double finalPrice = (basePrice * (widget.item.category == "Araçlar" || widget.item.category == "Araç Kiralama" ? duration : 1)) + extraPrice;

    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          onPressed: () {
            // DİKKAT: Buradaki parametre isimleri CartItem modelindekiyle birebir aynı olmalı
            final configuredItem = CartItem(
              title: widget.item.title,
              city: widget.item.city,
              category: widget.item.category,
              price: finalPrice,
              imagePath: widget.item.imagePath,
              selectedDate: selectedDate,
              selectedMenu: selectedMeal, // Hata veren kısım burasıydı, modelde tanımlanmalı
              extraOption: widget.item.category == "Araçlar" || widget.item.category == "Araç Kiralama" ? "$duration Günlük" : null,
            );

            widget.onConfirm(configuredItem);
            Navigator.pop(context);
          },
          child: Text(
            "Sepete Ekle (${finalPrice.toStringAsFixed(0)} ₺)",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "İstediğiniz zaman sepetten güncelleyebilirsiniz.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}