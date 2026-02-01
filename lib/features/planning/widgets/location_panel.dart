import 'package:flutter/material.dart';

class LocationPanel extends StatelessWidget {
  final String? country;
  final String? city;
  final String? district;
  final bool isLoadingCountries;
  final bool isLoadingCities;
  final bool isLoadingDistricts;
  final VoidCallback onCountryTap;
  final VoidCallback? onCityTap;
  final VoidCallback? onDistrictTap;

  const LocationPanel({
    super.key,
    required this.country,
    required this.city,
    required this.district,
    required this.isLoadingCountries,
    required this.isLoadingCities,
    required this.isLoadingDistricts,
    required this.onCountryTap,
    this.onCityTap,
    this.onDistrictTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSelector(context, country ?? "Ülke Seç", Icons.public, isLoadingCountries, onCountryTap),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSelector(context, city ?? "Şehir Seç", Icons.location_city, isLoadingCities, onCityTap),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSelector(context, district ?? "İlçe / Bölge Seçin", Icons.map, isLoadingDistricts, onDistrictTap),
        ],
      ),
    );
  }

  Widget _buildSelector(BuildContext context, String label, IconData icon, bool isLoading, VoidCallback? onTap) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDarkMode ? Colors.white12 : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Expanded(child: Text(isLoading ? "..." : label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}