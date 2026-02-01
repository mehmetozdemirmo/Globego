import 'package:flutter/material.dart';
import '../../profile/screens/profile_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final TravelGroup group;
  final List<Map<String, dynamic>> myTrips;

  const GroupChatScreen({super.key, required this.group, required this.myTrips});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage(String text, {bool isPlan = false, Map<String, dynamic>? planData}) {
    if (text.trim().isEmpty && !isPlan) return;
    setState(() {
      _messages.add({
        'sender': 'Ben',
        'text': text,
        'isMe': true,
        'isPlan': isPlan,
        'planData': planData,
        'time': DateTime.now().toString().substring(11, 16),
      });
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name, style: const TextStyle(fontSize: 18)),
            Text("${widget.group.members.length} Üye", style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return msg['isPlan'] ? _buildPlanCard(msg) : _buildBubble(msg);
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> msg) {
    final plan = msg['planData'];
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 250,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.orangeAccent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
              child: Row(children: const [Icon(Icons.map, color: Colors.white, size: 16), SizedBox(width: 8), Text("Rota Paylaşıldı", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))]),
            ),
            ListTile(title: Text(plan['location'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), subtitle: Text(plan['date'], style: const TextStyle(fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: const BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15), bottomLeft: Radius.circular(15))),
        child: Text(msg['text'], style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.card_travel, color: Colors.orangeAccent), onPressed: _showTripPicker),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: "Mesaj yaz...", filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none)),
            ),
          ),
          IconButton(icon: const Icon(Icons.send, color: Colors.blueAccent), onPressed: () => _sendMessage(_controller.text)),
        ],
      ),
    );
  }

  void _showTripPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Paylaşılacak Planı Seç", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...widget.myTrips.map((trip) => ListTile(
              leading: const Icon(Icons.location_on, color: Colors.orangeAccent),
              title: Text(trip['location']),
              subtitle: Text(trip['date']),
              onTap: () { _sendMessage("", isPlan: true, planData: trip); Navigator.pop(context); },
            )).toList(),
          ],
        ),
      ),
    );
  }
}