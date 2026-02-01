import 'package:flutter/material.dart';

class CartItem {
  final String title;
  final String city;
  final String category;
  final String imagePath;
  final double price; // Ürünün temel fiyatı
  final double star;  // Genel yıldız ortalaması
  bool isFavorite;    // Favori durumu
  double rating;      // Kullanıcının verdiği puan

  // --- YENİ EKLENEN VE HATALARI ÇÖZEN ÖZELLİKLER ---
  final DateTime? selectedDate;
  // SelectionSheet'teki 'selectedMeal' ve CartScreen'deki 'selectedMenu' hatalarını çözmek için:
  final String? selectedMenu;
  final String? extraOption;
  final Map<String, dynamic>? metadata;

  CartItem({
    required this.title,
    required this.city,
    required this.category,
    required this.imagePath,
    this.price = 0.0,
    this.star = 0.0,
    this.isFavorite = false,
    this.rating = 0.0,
    this.selectedDate,
    this.selectedMenu, // İsimlendirme diğer dosyalarla eşitlendi
    this.extraOption,
    this.metadata,
  });

  /// [copyWith] metodu: Nesneyi değiştirmeden kopyasını oluşturur.
  /// Tüm yeni alanlar buraya dahil edilerek veri akışı korundu.
  CartItem copyWith({
    String? title,
    String? city,
    String? category,
    String? imagePath,
    double? price,
    double? star,
    bool? isFavorite,
    double? rating,
    DateTime? selectedDate,
    String? selectedMenu,
    String? extraOption,
    Map<String, dynamic>? metadata,
  }) {
    return CartItem(
      title: title ?? this.title,
      city: city ?? this.city,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      price: price ?? this.price,
      star: star ?? this.star,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedMenu: selectedMenu ?? this.selectedMenu,
      extraOption: extraOption ?? this.extraOption,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Bütçe hesaplamalarında TL formatında string döndürmek için yardımcı getter
  String get formattedPrice => "${price.toStringAsFixed(0)} ₺";

  /// Seçilen detayları okunabilir bir metin olarak döndürür (Sepet ekranında kullanmak için)
  String get detailsSummary {
    List<String> details = [];
    if (selectedDate != null) {
      details.add("${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}");
    }
    if (selectedMenu != null && selectedMenu!.isNotEmpty) {
      details.add(selectedMenu!);
    }
    if (extraOption != null && extraOption!.isNotEmpty) {
      details.add(extraOption!);
    }
    return details.isEmpty ? "Detay seçilmedi" : details.join(" • ");
  }

  /// Veritabanı veya JSON işlemleri için Map'e dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'city': city,
      'category': category,
      'imagePath': imagePath,
      'price': price,
      'star': star,
      'isFavorite': isFavorite,
      'rating': rating,
      'selectedDate': selectedDate?.toIso8601String(),
      'selectedMenu': selectedMenu,
      'extraOption': extraOption,
      'metadata': metadata,
    };
  }

  /// JSON'dan nesne üretmek için (Dönüşüm hatalarını önlemek için tip kontrolleri eklendi)
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      title: map['title']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      category: map['category'] ?? '',
      imagePath: map['imagePath'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      star: (map['star'] ?? 0.0).toDouble(),
      isFavorite: map['isFavorite'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      selectedDate: map['selectedDate'] != null
          ? DateTime.tryParse(map['selectedDate'].toString())
          : null,
      selectedMenu: map['selectedMenu']?.toString(),
      extraOption: map['extraOption']?.toString(),
      metadata: map['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  /// Kategoriye göre UI'da kullanılacak ikonu otomatik döndürür
  /// int tipinde icon data döner, Icon(IconData(item.categoryIcon, fontFamily: 'MaterialIcons')) şeklinde kullanılır.
  int get categoryIcon {
    switch (category.toLowerCase()) {
      case 'oteller': return 0xe32a; // Icons.hotel
      case 'restoranlar': return 0xe532; // Icons.restaurant
      case 'araçlar': return 0xe1d1; // Icons.directions_car
      case 'turlar': return 0xe23a; // Icons.explore
      default: return 0xe0bc; // Icons.bookmark
    }
  }
}