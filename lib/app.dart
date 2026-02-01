import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase eklendi
import 'routes/app_routes.dart';
import 'package:yeni_projem/features/planning/models/cart_item.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlobeGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      // initialRoute yerine home kullanıyoruz ki giriş durumunu dinleyelim
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Eğer uygulama hala Firebase'den yanıt bekliyorsa yükleme ekranı göster
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // Eğer kullanıcı giriş yapmışsa (data varsa) Ana Sayfa'ya (home) git
          if (snapshot.hasData) {
            // Not: AppRoutes içinde ana sayfa rotanız nasıl tanımlıysa ona göre yönlendirin
            // Genelde AppRoutes.home veya benzeri bir ana sayfa widget'ı döndürülür.
            return AppRoutes.routes[AppRoutes.home]!(context);
          }
          // Giriş yapmamışsa Login sayfasına git
          return AppRoutes.routes[AppRoutes.login]!(context);
        },
      ),
      routes: AppRoutes.routes,
    );
  }
}

// HomeContent widget'ın (Değişmedi, aynı kalabilir)
class HomeContent extends StatelessWidget {
  final Function(CartItem)? onAdd;

  const HomeContent({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildWeeklyBestPlans(context),
          _buildSpecialDeals(context),
          _buildUserTrendingChoices(context),
        ],
      ),
    );
  }

  Widget _buildWeeklyBestPlans(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text("Haftanın En İyi Planları",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: 3,
            itemBuilder: (context, index) {
              final title = "Ege Rüyası ${index + 1}";
              final price = 12500.0 + (index * 1000);

              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        image: DecorationImage(
                          image: AssetImage('assets/images/globego.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text("${price.toStringAsFixed(0)} ₺",
                                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (onAdd != null) {
                                onAdd!(CartItem(
                                  title: title,
                                  price: price,
                                  city: "Muğla",
                                  category: "Tur",
                                  imagePath: 'assets/images/globego.jpeg',
                                ));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Icon(Icons.add_shopping_cart, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialDeals(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
          child: Text("Kaçırılmayacak Fırsatlar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: 4,
            itemBuilder: (context, index) => Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_offer, color: Colors.orangeAccent),
                  const SizedBox(height: 5),
                  const Text("Hafta Sonu", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("%20 İndirim", style: TextStyle(color: Colors.green[700], fontSize: 12)),
                  TextButton(
                    onPressed: () {},
                    child: const Text("İncele", style: TextStyle(fontSize: 12)),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTrendingChoices(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
          child: Text("Diğer Kullanıcılar Neler Seçti?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: 5,
            itemBuilder: (context, index) => Container(
              width: 180,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Swissotel İstanbul",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text("1.2k seçim", style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}