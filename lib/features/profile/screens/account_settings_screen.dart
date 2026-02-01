import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';

class AccountSettingsScreen extends StatefulWidget {
  final UserModel? user;
  // Bu callback sayesinde ProfileScreen'deki değişkenleri anlık güncelleyeceğiz.
  final Function(String newName, String newEmail)? onUpdate;

  const AccountSettingsScreen({super.key, this.user, this.onUpdate});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isPublicProfile = true;
  String _selectedLanguage = "Türkçe";

  // State içindeki güncel kullanıcı bilgileri (Ekranda anlık değişim için)
  late String _currentName;
  late String _currentEmail;

  @override
  void initState() {
    super.initState();
    // widget.user'dan gelen verileri yerel state'e aktarıyoruz
    _currentName = widget.user?.name ?? "Misafir";
    _currentEmail = widget.user?.email ?? "email@example.com";
  }

  // --- MERKEZİ KAYDETME FONKSİYONU ---
  void _saveAllChanges() {
    if (widget.onUpdate != null) {
      // Değişiklikleri ana sayfaya (ProfileScreen) callback ile gönderiyoruz.
      widget.onUpdate!(_currentName, _currentEmail);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Değişiklikler başarıyla kaydedildi"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );

    // Kaydettikten sonra sayfayı kapatıyoruz.
    // ProfileScreen'deki setState tetiklendiği için oradaki tüm pencereler güncellenecek.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Hesap Ayarları",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: _saveAllChanges,
            child: const Text("Kaydet",
                style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSectionHeader("Profil Bilgileri"),
          _buildSettingTile(
            Icons.person_outline,
            "Ad Soyad",
            subtitle: _currentName, // Yerel state'den güncel ismi oku
            onTap: () => _showEditDialog("İsim Düzenle", _currentName, (val) {
              setState(() => _currentName = val);
            }),
          ),
          _buildSettingTile(
            Icons.email_outlined,
            "E-posta",
            subtitle: _currentEmail, // Yerel state'den güncel e-postayı oku
            onTap: () => _showEditDialog("E-posta Düzenle", _currentEmail, (val) {
              setState(() => _currentEmail = val);
            }),
          ),
          _buildSettingTile(Icons.lock_outline, "Şifre Değiştir"),

          const Divider(),
          _buildSectionHeader("Uygulama Tercihleri"),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_none, color: Colors.blueAccent),
            title: const Text("Bildirimler"),
            subtitle: const Text("Grup mesajları ve gezi hatırlatıcıları"),
            value: _notificationsEnabled,
            activeColor: Colors.blueAccent,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          _buildSettingTile(
            Icons.language,
            "Dil",
            subtitle: _selectedLanguage,
            onTap: _showLanguagePicker,
          ),

          const Divider(),
          _buildSectionHeader("Gizlilik ve Güvenlik"),
          SwitchListTile(
            secondary: const Icon(Icons.public, color: Colors.blueAccent),
            title: const Text("Profilim Herkese Açık"),
            subtitle: const Text("Diğer gezginler beni bulabilsin"),
            value: _isPublicProfile,
            activeColor: Colors.blueAccent,
            onChanged: (val) => setState(() => _isPublicProfile = val),
          ),
          _buildSettingTile(Icons.verified_user_outlined, "İzinleri Yönet"),

          const SizedBox(height: 30),
          _buildDangerZone(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- UI BİLEŞENLERİ ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildDangerZone() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => _showDeleteAccountConfirm(),
        child: const Text("Hesabı Kalıcı Olarak Sil"),
      ),
    );
  }

  // --- MODALLAR ---

  void _showEditDialog(String title, String initialValue, Function(String) onSave) {
    final ctrl = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                onSave(ctrl.text);
              }
              Navigator.pop(context);
            },
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    final languages = ["Türkçe", "English", "Deutsch", "Français"];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Dil Seçin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...languages.map((lang) => ListTile(
              title: Text(lang),
              trailing: _selectedLanguage == lang ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.pop(context);
              },
            )).toList(),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hesabı Sil?"),
        content: const Text("Bu işlem geri alınamaz. Tüm gezi planlarınız silinecektir."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç")),
          TextButton(
            onPressed: () {
              // Buraya çıkış yapma veya database silme kodu eklenebilir.
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Evet, Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}