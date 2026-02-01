import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase eklendi
import '../../auth/models/user_model.dart';
import '../../planning/models/cart_item.dart';
import '../../chat/screens/group_chat_screen.dart';
import 'account_settings_screen.dart';

// Grup verilerini tutmak için model
class TravelGroup {
  final String name;
  final List<String> members;
  String lastMessage;
  final Color groupColor;

  TravelGroup({
    required this.name,
    required this.members,
    this.lastMessage = "Grup oluşturuldu.",
    this.groupColor = Colors.blueAccent,
  });
}

class ProfileScreen extends StatefulWidget {
  final UserModel? user;
  final List<Map<String, dynamic>> pastTrips;
  final List<CartItem> favorites;
  final List<CartItem> ratedItems;

  const ProfileScreen({
    super.key,
    this.user,
    this.pastTrips = const [],
    this.favorites = const [],
    this.ratedItems = const [],
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- STATE DEĞİŞKENLERİ ---
  late UserModel _currentUser;
  final User? _firebaseUser = FirebaseAuth.instance.currentUser; // Firebase User referansı

  final List<TravelGroup> _myGroups = [
    TravelGroup(name: "Ege Yolcuları", members: ["Ali", "Veli", "Can"], lastMessage: "Plan paylaşıldı.", groupColor: Colors.orange),
    TravelGroup(name: "Hafta Sonu Ekibi", members: ["Ayşe", "Fatma"], lastMessage: "Otel ayarlandı mı?", groupColor: Colors.purple),
  ];

  @override
  void initState() {
    super.initState();
    // Google'dan gelen verileri UserModel'e eşliyoruz
    _currentUser = widget.user ?? UserModel(
      name: _firebaseUser?.displayName ?? "Gezgin Kullanıcı",
      email: _firebaseUser?.email ?? "email@example.com",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            _buildUserInfoSection(),
            const SizedBox(height: 30),
            _buildStatsSection(),
            const SizedBox(height: 25),
            if (widget.ratedItems.isNotEmpty) _buildRatedSection(),
            const Divider(thickness: 1, height: 30),
            _buildProfileMenuItems(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- KULLANICI BİLGİ ALANI (Google Fotoğrafı Eklendi) ---
  Widget _buildUserInfoSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.blueAccent,
            child: CircleAvatar(
              radius: 52,
              backgroundColor: Colors.white,
              backgroundImage: _firebaseUser?.photoURL != null
                  ? NetworkImage(_firebaseUser!.photoURL!)
                  : null,
              child: _firebaseUser?.photoURL == null
                  ? const Icon(Icons.person, size: 60, color: Colors.blueAccent)
                  : null,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _currentUser.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            _currentUser.email,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- İSTATİSTİK KARTLARI ---
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard("Geziler", widget.pastTrips.length.toString()),
          const SizedBox(width: 15),
          _buildStatCard("Favoriler", widget.favorites.length.toString()),
          const SizedBox(width: 15),
          _buildStatCard("Puanlanan", widget.ratedItems.length.toString()),
        ],
      ),
    );
  }

  // --- PROFİL MENÜ LİSTESİ (Hesap Silme Eklendi) ---
  Widget _buildProfileMenuItems() {
    return Column(
      children: [
        _buildProfileItem(
          Icons.history,
          "Geçmiş Planlarım",
          subtitle: "${widget.pastTrips.length} Kayıtlı Seyahat",
          onTap: () => _showListSheet(context, "Geçmiş Planlarım", widget.pastTrips, isTrip: true),
        ),
        _buildProfileItem(
          Icons.favorite_border,
          "Favori Mekanlar",
          subtitle: "${widget.favorites.length} Mekan Kaydedildi",
          onTap: () => _showListSheet(context, "Favorilerim", widget.favorites, isTrip: false),
        ),
        _buildProfileItem(
          Icons.groups_outlined,
          "Gruplarım",
          subtitle: "${_myGroups.length} Aktif Grup",
          onTap: () => _showGroupsSheet(context),
        ),
        _buildProfileItem(Icons.payment, "Ödeme Yöntemlerim"),
        _buildProfileItem(
          Icons.settings_outlined,
          "Hesap Ayarları",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountSettingsScreen(
                  user: _currentUser,
                  onUpdate: (newName, newEmail) {
                    setState(() {
                      _currentUser = _currentUser.copyWith(name: newName, email: newEmail);
                    });
                  },
                ),
              ),
            );
          },
        ),
        const Divider(),
        _buildProfileItem(
          Icons.delete_forever_outlined,
          "Hesabımı Sil",
          textColor: Colors.red,
          onTap: () => _showDeleteDialog(context),
        ),
        _buildProfileItem(
          Icons.logout,
          "Çıkış Yap",
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            if (mounted) Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }

  // --- HESAP SİLME DİALOĞU ---
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hesabımı Sil"),
        content: const Text("Hesabınızı ve tüm verilerinizi silmek istediğinize emin misiniz? Bu işlem geri alınamaz."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Güvenlik nedeniyle tekrar giriş yapıp denemelisiniz.")),
                );
              }
            },
            child: const Text("Sil", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- MODAL LİSTELERİ ---
  void _showListSheet(BuildContext context, String title, List list, {required bool isTrip}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
                initialChildSize: 0.6,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${_currentUser.name}'in Listesi", style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 5),
                        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        Expanded(
                          child: list.isEmpty
                              ? Center(child: Text("$title listeniz henüz boş."))
                              : ListView.builder(
                            controller: scrollController,
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final item = list[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: Icon(
                                    isTrip ? Icons.map_outlined : Icons.favorite,
                                    color: isTrip ? Colors.blueAccent : Colors.redAccent,
                                  ),
                                  title: Text(isTrip ? item['location'] : (item as CartItem).title),
                                  subtitle: Text(isTrip ? item['date'] : (item as CartItem).city),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
            );
          },
        );
      },
    );
  }

  // --- GRUPLAR LİSTESİ MODAL ---
  void _showGroupsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Gruplarım", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blueAccent, size: 30),
                    onPressed: () async {
                      await _showCreateGroupDialog(context);
                      setSheetState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: _myGroups.isEmpty
                    ? const Center(child: Text("Henüz bir grubunuz yok."))
                    : ListView.builder(
                  itemCount: _myGroups.length,
                  itemBuilder: (context, index) {
                    return _buildGroupTile(index, _myGroups[index], setSheetState);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupTile(int index, TravelGroup group, StateSetter parentState) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: group.groupColor.withOpacity(0.2),
          child: Text(
              group.name[0].toUpperCase(),
              style: TextStyle(color: group.groupColor, fontWeight: FontWeight.bold)
          ),
        ),
        title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${group.members.length} Üye • ${group.lastMessage}", style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.settings, color: Colors.blueAccent, size: 20),
          onPressed: () => _showManageGroupSheet(context, index, parentState),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupChatScreen(
                group: group,
                myTrips: widget.pastTrips,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showManageGroupSheet(BuildContext context, int index, StateSetter parentState) {
    final group = _myGroups[index];
    final TextEditingController newMemberController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setMgmtState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${group.name} - Üyeleri Yönet", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: newMemberController,
                decoration: InputDecoration(
                  hintText: "Üye ekle (Kullanıcı adı/Tel)",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.blueAccent),
                    onPressed: () {
                      if (newMemberController.text.isNotEmpty) {
                        setState(() { group.members.add(newMemberController.text); });
                        setMgmtState(() {});
                        parentState(() {});
                        newMemberController.clear();
                      }
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 15),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: group.members.length,
                  itemBuilder: (context, mIndex) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person, size: 20)),
                    title: Text(group.members[mIndex]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () {
                        setState(() { group.members.removeAt(mIndex); });
                        setMgmtState(() {});
                        parentState(() {});
                      },
                    ),
                  ),
                ),
              ),
              const Divider(),
              TextButton.icon(
                onPressed: () {
                  setState(() { _myGroups.removeAt(index); });
                  Navigator.pop(context);
                  parentState(() {});
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text("Grubu Sil", style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateGroupDialog(BuildContext context) async {
    final TextEditingController groupNameController = TextEditingController();
    final TextEditingController memberController = TextEditingController();
    final List<String> addedMembers = [];
    Color selectedColor = Colors.blueAccent;
    final List<Color> colors = [Colors.blue, Colors.orange, Colors.purple, Colors.green, Colors.red, Colors.pink];

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Yeni Grup Oluştur", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: groupNameController,
                    decoration: InputDecoration(
                      hintText: "Grup Adı",
                      prefixIcon: const Icon(Icons.edit_note),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text("Grup Rengi", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 35,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: colors.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () => setModalState(() => selectedColor = colors[index]),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 35,
                          decoration: BoxDecoration(
                              color: colors[index],
                              shape: BoxShape.circle,
                              border: Border.all(color: selectedColor == colors[index] ? Colors.black : Colors.transparent, width: 2)
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: memberController,
                    decoration: InputDecoration(
                      hintText: "Üye Ekle (Kullanıcı Adı)",
                      prefixIcon: const Icon(Icons.person_add_alt),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
                        onPressed: () {
                          if (memberController.text.isNotEmpty) {
                            setModalState(() {
                              addedMembers.add(memberController.text);
                              memberController.clear();
                            });
                          }
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  _buildMemberChips(addedMembers, setModalState),
                  const SizedBox(height: 25),
                  _buildCreateButton(groupNameController, addedMembers, selectedColor),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }
      ),
    );
  }

  Widget _buildMemberChips(List<String> members, StateSetter setModalState) {
    if (members.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        const Text("Eklenen Üyeler", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: members.map((member) => Chip(
            label: Text(member, style: const TextStyle(fontSize: 12)),
            onDeleted: () => setModalState(() => members.remove(member)),
            backgroundColor: Colors.blueAccent.withOpacity(0.1),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCreateButton(TextEditingController nameCtrl, List<String> members, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () {
          if (nameCtrl.text.isNotEmpty) {
            setState(() {
              _myGroups.add(TravelGroup(
                name: nameCtrl.text,
                members: List.from(members),
                groupColor: color,
              ));
            });
            Navigator.pop(context);
          }
        },
        child: const Text("Grubu Başlat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRatedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text("Puanladığım Mekanlar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: widget.ratedItems.length,
            itemBuilder: (context, index) {
              final item = widget.ratedItems[index];
              return SizedBox(
                width: 160,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(item.city, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(item.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, {String? subtitle, Color? textColor, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? Colors.blueAccent).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: textColor ?? Colors.blueAccent, size: 22),
      ),
      title: Text(title, style: TextStyle(color: textColor ?? Colors.black87, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }
}