import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../routes/app_routes.dart';
import '../../planning/screens/planning_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../planning/models/cart_item.dart';
import '../../profile/screens/profile_screen.dart';
import 'ticket_screen.dart';
import 'expense_summary_screen.dart';
import 'past_trips_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<CartItem> myCart = [];
  List<Map<String, dynamic>> pastTrips = [];
  List<CartItem> favorites = [];
  List<CartItem> ratedItems = [];

  User? get currentUser => FirebaseAuth.instance.currentUser;

  double get cartTotalPrice {
    return myCart.fold(0.0, (sum, item) => sum + (item.price ?? 0.0));
  }

  void addToCart(CartItem item) {
    setState(() => myCart.add(item));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item.title} eklendi (${item.price?.toStringAsFixed(0)} ₺)"),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void toggleFavorite(CartItem item) {
    setState(() {
      final exists = favorites.any((f) => f.title == item.title);
      if (exists) {
        favorites.removeWhere((f) => f.title == item.title);
      } else {
        favorites.add(item);
      }
    });
  }

  void approveTrip() {
    if (myCart.isEmpty) return;

    final Map<String, dynamic> approvedTrip = {
      'id': DateTime.now().toString(),
      'date': "${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}",
      'items': List<CartItem>.from(myCart),
      'location': myCart.first.city,
      'totalPrice': cartTotalPrice,
    };

    setState(() {
      pastTrips.add(approvedTrip);
      myCart.clear();
      _selectedIndex = 4;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Seyahatiniz Profilinize kaydedildi!"), backgroundColor: Colors.green),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await GoogleSignIn().disconnect();
      await currentUser?.delete();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Güvenlik nedeniyle tekrar giriş yapmalısınız.")),
      );
    }
  }

  List<Widget> _getPages() {
    return [
      _buildHomeDashboard(),
      PlanningScreen(onAdd: addToCart, onFavoriteToggle: toggleFavorite, favorites: favorites),
      const SizedBox(),
      CartScreen(
        items: myCart,
        onApprove: approveTrip,
        onDelete: (index) => setState(() => myCart.removeAt(index)),
      ),
      ProfileScreen(pastTrips: pastTrips, favorites: favorites, ratedItems: ratedItems),
    ];
  }

  Widget _buildHomeDashboard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildWeeklyBestPlans(),
          const SizedBox(height: 15),
          _buildUserTrendingChoices(),
          const SizedBox(height: 15),
          _buildDiscountedDeals(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Merhaba, ${currentUser?.displayName ?? 'Gezgin'} 👋",
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const Text("Nereyi Keşfediyoruz?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWeeklyBestPlans() {
    final List<Map<String, dynamic>> plans = [
      {'title': 'Ege Rüyası', 'days': '5 Gün', 'price': 12500.0, 'city': 'İzmir'},
      {'title': 'Kapadokya Masalı', 'days': '3 Gün', 'price': 8200.0, 'city': 'Nevşehir'},
      {'title': 'Karadeniz Turu', 'days': '7 Gün', 'price': 15400.0, 'city': 'Trabzon'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text("Haftanın En İyi Planları", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
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
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          image: const DecorationImage(image: AssetImage('assets/images/globego.jpeg'), fit: BoxFit.cover),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.6), Colors.transparent]),
                          ),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(plan['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              Text("${plan['days']} • ${plan['price'].toStringAsFixed(0)} ₺", style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton.icon(
                        onPressed: () => addToCart(CartItem(
                            title: plan['title'], city: plan['city'], category: "Turlar", imagePath: 'assets/images/globego.jpeg', price: plan['price'])),
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text("Sepete Ekle"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 36)),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserTrendingChoices() {
    final List<Map<String, dynamic>> choices = [
      {'name': 'Swissotel', 'count': '1.2k kişi', 'price': 4500.0, 'city': 'İstanbul'},
      {'name': 'Kapadokya Balon', 'count': '850 kişi', 'price': 3200.0, 'city': 'Nevşehir'},
      {'name': 'Bodrum Tekne', 'count': '2.1k kişi', 'price': 1500.0, 'city': 'Muğla'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text("Diğer Kullanıcılar Neler Seçti?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: choices.length,
            itemBuilder: (context, index) {
              final choice = choices[index];
              return Container(
                width: 200,
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
                    Text(choice['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("${choice['price'].toStringAsFixed(0)} ₺", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.trending_up, color: Colors.green, size: 14),
                            const SizedBox(width: 4),
                            Text(choice['count']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                        InkWell(
                          onTap: () => addToCart(CartItem(
                              title: choice['name'], city: choice['city'], category: "Oteller", imagePath: 'assets/images/globego.jpeg', price: choice['price'])),
                          child: const Icon(Icons.add_circle, color: Colors.blueAccent),
                        )
                      ],
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

  Widget _buildDiscountedDeals() {
    final List<Map<String, dynamic>> deals = [
      {'title': 'Antalya Her Şey Dahil', 'price': 5000.0, 'discount': '%20', 'city': 'Antalya'},
      {'title': 'Rize Yayla Evi', 'price': 2500.0, 'discount': '%15', 'city': 'Rize'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text("Fırsat Paketleri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: deals.length,
            itemBuilder: (context, index) {
              final deal = deals[index];
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                        child: Text("${deal['discount']} İNDİRİM", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Text(deal['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${deal['price'].toStringAsFixed(0)} ₺", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                          IconButton(
                            onPressed: () => addToCart(CartItem(
                                title: deal['title'], city: deal['city'], category: "Fırsatlar", imagePath: 'assets/images/globego.jpeg', price: deal['price'])),
                            icon: const Icon(Icons.add_shopping_cart, color: Colors.orange),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text("GlobeGo", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.sort), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
        actions: [
          if(myCart.isNotEmpty && _selectedIndex == 3)
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 15),
              child: Text("${cartTotalPrice.toStringAsFixed(0)} ₺", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.blueAccent,
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        child: const Icon(Icons.menu, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blueAccent,
          onTap: (index) { if (index != 2) setState(() => _selectedIndex = index); },
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Ana Sayfa'),
            const BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Planlama'),
            const BottomNavigationBarItem(icon: Icon(Icons.add, color: Colors.transparent), label: ''),
            BottomNavigationBarItem(
              icon: Badge(label: Text(myCart.length.toString()), isLabelVisible: myCart.isNotEmpty, child: const Icon(Icons.shopping_cart_outlined)),
              activeIcon: const Icon(Icons.shopping_cart),
              label: 'Sepetim',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.blueAccent),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: currentUser?.photoURL != null ? NetworkImage(currentUser!.photoURL!) : null,
              child: currentUser?.photoURL == null ? const Icon(Icons.person, size: 40, color: Colors.blueAccent) : null,
            ),
            accountName: Text(currentUser?.displayName ?? "Gezgin Kullanıcı", style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(currentUser?.email ?? "gezgin@mail.com"),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerSectionTitle("Aktif Seyahat"),
                _drawerItem(Icons.qr_code_2, 'Bilet / QR Kod', () {
                  Navigator.pop(context);
                  if (pastTrips.isNotEmpty) Navigator.push(context, MaterialPageRoute(builder: (context) => TicketScreen(tripDetails: pastTrips.last)));
                }),
                _drawerItem(Icons.check_circle_outline, 'Check-in Bilgileri', () {}),
                const Divider(),
                _drawerSectionTitle("Geçmiş Seyahatler"),
                _drawerItem(Icons.history, 'Tamamlanan Geziler', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PastTripsScreen(trips: pastTrips)));
                }),
                _drawerItem(Icons.pie_chart_outline, 'Harcama Özeti', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseSummaryScreen(items: pastTrips.isNotEmpty ? List<CartItem>.from(pastTrips.last['items']) : [])));
                }),
                const Divider(),
                _drawerSectionTitle("Hesap Yönetimi"),
                _drawerItem(Icons.delete_forever, 'Hesabımı Sil', () {
                  showDialog(context: context, builder: (context) => AlertDialog(
                    title: const Text("Hesabı Sil"),
                    content: const Text("Tüm verileriniz ve hesabınız kalıcı olarak silinecektir. Onaylıyor musiniz?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç")),
                      TextButton(onPressed: _deleteAccount, child: const Text("Sil", style: TextStyle(color: Colors.red))),
                    ],
                  ));
                }, color: Colors.red),
                const Divider(),
                _drawerSectionTitle("Destek"),
                _drawerItem(Icons.help_outline, 'Yardım & Destek', () {}),
                _drawerItem(Icons.info_outline, 'Uygulama Hakkında', () {}),
              ],
            ),
          ),
          const Divider(),
          _drawerItem(Icons.logout, 'Çıkış Yap', () async {
            await FirebaseAuth.instance.signOut();
            final GoogleSignIn googleSignIn = GoogleSignIn();
            await googleSignIn.signOut();
            await googleSignIn.disconnect();
            if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
          }, color: Colors.red),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _drawerSectionTitle(String title) => Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text(title, style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)));
  Widget _drawerItem(IconData icon, String text, VoidCallback onTap, {Color color = Colors.black87}) => ListTile(leading: Icon(icon, color: color, size: 22), title: Text(text, style: TextStyle(color: color, fontSize: 14)), onTap: onTap, dense: true);
}