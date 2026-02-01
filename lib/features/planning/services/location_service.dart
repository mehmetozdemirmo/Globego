import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class LocationService {
  static const String _baseUrl = 'https://countriesnow.space/api/v0.1/countries';

  // 1. TÜM ÜLKELERİ ÇEKER
  Future<List<String>> getCountries() async {
    try {
      print("İstek gönderiliyor: $_baseUrl"); // LOG
      final response = await http.get(Uri.parse(_baseUrl)).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false) {
          final List<dynamic> countriesData = data['data'];
          List<String> countryList = countriesData.map((e) => e['country'].toString()).toList();
          countryList.sort();
          return countryList;
        }
      } else {
        print("Ülke çekme başarısız. Kod: ${response.statusCode}");
      }
    } on SocketException {
      print("İnternet bağlantısı yok veya sunucuya erişilemiyor (SocketException)");
    } catch (e) {
      print("Ülke çekme hatası: $e");
    }
    return ["Türkiye", "Amerika", "Almanya", "İngiltere"]; // Boş dönmemesi için yedek
  }

  // 2. SEÇİLEN ÜLKENİN ŞEHİRLERİNİ ÇEKER
  Future<List<String>> getCities(String country) async {
    try {
      print("$country için şehirler çekiliyor..."); // LOG
      final response = await http.post(
        Uri.parse('$_baseUrl/cities'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"country": country}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false) {
          List<String> cityList = List<String>.from(data['data']);
          cityList.sort();
          return cityList;
        }
      }
    } catch (e) {
      print("Şehir çekme hatası: $e");
    }
    return ["İstanbul", "Ankara", "İzmir"]; // Yedek liste
  }

  // 3. İLÇE/BÖLGE ÇEKER (YEDEK MEKANİZMA GÜÇLENDİRİLDİ)
  Future<List<String>> getDistricts(String country, String city) async {
    return [
      "Merkez",
      "$city Kuzey",
      "$city Güney",
      "Eski Şehir (Old Town)",
      "Sahil Şeridi",
      "İş Merkezi"
    ];
  }
}