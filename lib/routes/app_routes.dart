import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Google çıkış için eklendi
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/help/screens/support_screen.dart';
import '../features/auth/screens/register_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String support = '/support';

  // Giriş durumunu kontrol eden geliştirilmiş başlangıç rotası
  static String get initialRoute {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return home;
    }
    return login;
  }

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    settings: (context) => const SettingsScreen(),
    support: (context) => const SupportScreen(),
    profile: (context) => const ProfileScreen(
      pastTrips: [],
      favorites: [],
      ratedItems: [],
    ),
  };

  // --- KRİTİK ÇIKIŞ FONKSİYONU ---
  // Bu fonksiyon hem Firebase hem Google oturumunu kapatır
  static Future<void> logout(BuildContext context) async {
    try {
      // 1. Firebase oturumunu kapat
      await FirebaseAuth.instance.signOut();

      // 2. Google Sign-In önbelleğini temizle (HESAP SEÇME EKRANI İÇİN ŞART)
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
        await googleSignIn.disconnect(); // Bağlantıyı tamamen koparır
      }

      // 3. Login ekranına yönlendir ve tüm sayfaları temizle
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
      }
    } catch (e) {
      debugPrint("Çıkış yapılırken hata oluştu: $e");
    }
  }

  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }
}