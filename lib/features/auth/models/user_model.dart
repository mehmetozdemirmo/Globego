// lib/auth/models/user_model.dart

class UserModel {
  final String name;
  final String email;
  final String? profileImageUrl;

  UserModel({
    required this.name,
    required this.email,
    this.profileImageUrl,
  });

  /// Mevcut kullanıcı nesnesini bozmadan belirli alanları güncelleyip
  /// yeni bir nesne döndürmek için kullanılır. Flutter State Management
  /// (setState, Provider, Bloc vb.) için kritiktir.
  UserModel copyWith({
    String? name,
    String? email,
    String? profileImageUrl,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  /// Veritabanına (Firebase, Supabase vb.) veya yerel depolamaya
  /// (SharedPreferences) veri yazarken JSON formatına dönüştürme sağlar.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
    };
  }

  /// Veritabanından veya API'den gelen Map (JSON) verisini
  /// UserModel nesnesine dönüştürmek için kullanılır.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String?,
    );
  }

  /// Debug (Hata ayıklama) sırasında print(user) dediğinde
  /// konsolda anlamlı veriler görmeni sağlar.
  @override
  String toString() => 'UserModel(name: $name, email: $email, profileImageUrl: $profileImageUrl)';

  /// İki farklı UserModel nesnesinin içindeki verilerin aynı olup olmadığını
  /// kontrol eder. Gereksiz arayüz yenilemelerini (re-build) önlemek için kullanılır.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.name == name &&
        other.email == email &&
        other.profileImageUrl == profileImageUrl;
  }

  @override
  int get hashCode => name.hashCode ^ email.hashCode ^ profileImageUrl.hashCode;
}