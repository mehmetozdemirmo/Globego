import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/location_service.dart';
import '../widgets/selection_sheet.dart';
import '../widgets/location_panel.dart';
import '../widgets/budget_widgets.dart';
import '../widgets/timeline_tile.dart';
import 'details_screen.dart';
import 'event_detail_page.dart';

class PlanningScreen extends StatefulWidget {
  final Function(CartItem) onAdd;
  final Function(CartItem) onFavoriteToggle;
  final List<CartItem> favorites;

  const PlanningScreen({
    super.key,
    required this.onAdd,
    required this.onFavoriteToggle,
    required this.favorites,
  });

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LocationService _locationService = LocationService();

  List<String> countries = [];
  List<String> cities = [];
  List<String> districts = [];

  String? selectedCountry;
  String? selectedCity;
  String? selectedDistrict;
  int _selectedCategoryIndex = 0;
  String _searchQuery = "";

  bool isLoadingCountries = true;
  bool isLoadingCities = false;
  bool isLoadingDistricts = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Oteller', 'icon': Icons.hotel},
    {'name': 'Araçlar', 'icon': Icons.directions_car},
    {'name': 'Turlar', 'icon': Icons.explore},
    {'name': 'Restoranlar', 'icon': Icons.restaurant},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCountries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get _totalBudget => widget.favorites.fold(0.0, (sum, item) => sum + (item.price));

  Map<String, double> get _categoryBudgets {
    Map<String, double> summary = {'Oteller': 0, 'Araçlar': 0, 'Turlar': 0, 'Restoranlar': 0};
    for (var item in widget.favorites) {
      if (summary.containsKey(item.category)) {
        summary[item.category] = summary[item.category]! + (item.price);
      }
    }
    return summary;
  }

  // --- LOKASYON FONKSİYONLARI ---
  Future<void> _fetchCountries() async {
    final result = await _locationService.getCountries();
    if (mounted) setState(() { countries = result; isLoadingCountries = false; });
  }

  Future<void> _fetchCities(String country) async {
    setState(() { isLoadingCities = true; cities = []; districts = []; selectedCity = null; selectedDistrict = null; });
    final result = await _locationService.getCities(country);
    if (mounted) setState(() { cities = result; isLoadingCities = false; });
  }

  Future<void> _fetchDistricts(String country, String city) async {
    setState(() { isLoadingDistricts = true; districts = []; selectedDistrict = null; });
    final result = await _locationService.getDistricts(country, city);
    if (mounted) setState(() { districts = ["Tümü", ...result]; selectedDistrict = "Tümü"; isLoadingDistricts = false; });
  }

  void _showSearchModal(String title, List<String> items, Function(String) onSelected) {
    List<String> filteredItems = List.from(items);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(hintText: "Ara...", prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), filled: true, fillColor: Theme.of(context).cardColor),
                onChanged: (val) => setModalState(() => filteredItems = items.where((e) => e.toLowerCase().contains(val.toLowerCase())).toList()),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) => ListTile(title: Text(filteredItems[index]), onTap: () { onSelected(filteredItems[index]); Navigator.pop(context); }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bütçe Footer'ı artık listenin üzerine binmiyor, en altta sabit duruyor.
      bottomNavigationBar: widget.favorites.isNotEmpty ? _buildBudgetFooter() : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Üstteki Lokasyon Seçim Paneli (Kaydırdıkça kapanır)
            SliverToBoxAdapter(
              child: LocationPanel(
                country: selectedCountry, city: selectedCity, district: selectedDistrict,
                isLoadingCountries: isLoadingCountries, isLoadingCities: isLoadingCities, isLoadingDistricts: isLoadingDistricts,
                onCountryTap: () => _showSearchModal("Ülke Seç", countries, (v) { setState(() => selectedCountry = v); _fetchCities(v); }),
                onCityTap: selectedCountry == null ? null : () => _showSearchModal("Şehir Seç", cities, (v) { setState(() => selectedCity = v); _fetchDistricts(selectedCountry!, v); }),
                onDistrictTap: selectedCity == null ? null : () => _showSearchModal("İlçe Seç", districts, (v) => setState(() => selectedDistrict = v)),
              ),
            ),
            // Sabitlenen Sekme Çubuğu (Üstte yapışık kalır)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.blueAccent,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blueAccent,
                    tabs: const [
                      Tab(icon: Icon(Icons.search), text: "Keşfet"),
                      Tab(icon: Icon(Icons.map_outlined), text: "Yol Haritası"),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDiscoveryTab(),
            _buildRoadmapTab(),
          ],
        ),
      ),
    );
  }

  // --- SEKME 1: KEŞFET ---
  Widget _buildDiscoveryTab() {
    if (selectedCity == null) return _buildEmptyState();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildSearchBar()),
        SliverToBoxAdapter(child: _buildCategoryList()),
        _buildContentSliverList(),
        if (_totalBudget > 0)
          SliverToBoxAdapter(child: SpendingSummary(budgets: _categoryBudgets, totalBudget: _totalBudget)),
      ],
    );
  }

  // --- SEKME 2: YOL HARİTASI ---
  Widget _buildRoadmapTab() {
    if (widget.favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("Henüz bir plan oluşturmadınız.", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.favorites.length,
      itemBuilder: (context, index) {
        return TimelineTile(
          item: widget.favorites[index],
          isFirst: index == 0,
          isLast: index == widget.favorites.length - 1,
          index: index,
        );
      },
    );
  }

  // --- İÇERİK LİSTESİ (SLIVER) ---
  Widget _buildContentSliverList() {
    List<String> activeDistricts = (selectedDistrict == null || selectedDistrict == "Tümü")
        ? districts.where((d) => d != "Tümü").toList()
        : [selectedDistrict!];

    List<Map<String, String>> allVisibleItems = [];
    for (var districtName in activeDistricts) {
      for (int i = 1; i <= 3; i++) {
        allVisibleItems.add({'title': "$districtName - ${_categories[_selectedCategoryIndex]['name']} $i", 'district': districtName});
      }
    }

    var filteredResults = allVisibleItems.where((item) => item['title']!.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, i) {
            final String title = filteredResults[i]['title']!;
            int favIndex = widget.favorites.indexWhere((f) => f.title == title);
            CartItem currentItem = (favIndex != -1) ? widget.favorites[favIndex] : CartItem(
              title: title, city: selectedCity!, category: _categories[_selectedCategoryIndex]['name'],
              imagePath: 'assets/images/globego.jpeg', price: 1200.0 + (i * 150),
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => EventDetailPage(item: currentItem))),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Image.asset(currentItem.imagePath, height: 160, width: double.infinity, fit: BoxFit.cover),
                          Positioned(top: 12, right: 12, child: GestureDetector(onTap: () => widget.onFavoriteToggle(currentItem), child: CircleAvatar(backgroundColor: Colors.white, radius: 18, child: Icon(currentItem.isFavorite ? Icons.favorite : Icons.favorite_border, color: currentItem.isFavorite ? Colors.red : Colors.grey, size: 20)))),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), _buildStars(currentItem)]),
                            IconButton(icon: const Icon(Icons.add_shopping_cart, color: Colors.blueAccent), onPressed: () => _openSheet(currentItem)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: filteredResults.length,
        ),
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: "${_categories[_selectedCategoryIndex]['name']} içerisinde ara...",
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          filled: true, fillColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      height: 85,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() { _selectedCategoryIndex = index; _searchQuery = ""; }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 100, margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: isSelected ? Colors.blueAccent : Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_categories[index]['icon'], color: isSelected ? Colors.white : Colors.blueAccent, size: 22),
                  const SizedBox(height: 4),
                  Text(_categories[index]['name'], style: TextStyle(color: isSelected ? Colors.white : null, fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openSheet(CartItem item) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (c) => SelectionSheet(item: item, onConfirm: (conf) => widget.onAdd(conf)));
  }

  Widget _buildStars(CartItem item) {
    return Row(children: List.generate(5, (index) => Icon(index < (item.rating ?? 0) ? Icons.star : Icons.star_border, color: Colors.amber, size: 20)));
  }

  Widget _buildBudgetFooter() {
    return InkWell(
      onTap: () {
        if (widget.favorites.isNotEmpty) {
          Navigator.push(context, MaterialPageRoute(builder: (c) => EventDetailPage(item: widget.favorites.last)));
        }
      },
      child: Container(
        height: 85,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              const Text("Tahmini Bütçe", style: TextStyle(color: Colors.grey, fontSize: 11)),
              Text("${_totalBudget.toStringAsFixed(0)} ₺", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ]),
            ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Planı Onayla", style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.map_outlined, size: 60, color: Colors.blueAccent), const SizedBox(height: 20), const Text("Seyahatinizi Planlayın", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("Lütfen yukarıdan konum seçin", style: TextStyle(color: Colors.grey[600]))]));
  }
}

// Sekmeyi sabitlemek için gereken yardımcı sınıf
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyTabBarDelegate({required this.child});
  @override
  double get minExtent => 50;
  @override
  double get maxExtent => 50;
  @override
  Widget build(Object context, double shrinkOffset, bool overlapsContent) => child;
  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}