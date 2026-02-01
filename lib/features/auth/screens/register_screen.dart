import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Üye Ol")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const Icon(Icons.person_add_alt_1, size: 70, color: Colors.blueAccent),
            const SizedBox(height: 30),

            _buildField("Ad Soyad", Icons.person, _nameController),
            const SizedBox(height: 15),
            _buildField("E-posta", Icons.email, _emailController),
            const SizedBox(height: 15),
            _buildField("Şifre", Icons.lock, _passController, isPass: true),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: () {
                  // Kayıt olan bilgileri UserModel'e aktar
                  final newUser = UserModel(
                    name: _nameController.text,
                    email: _emailController.text,
                  );

                  // Kayıt başarılı mesajı göster ve Home'a bu bilgilerle git
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hesabınız başarıyla oluşturuldu!")));
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false, arguments: newUser);
                },
                child: const Text("Kaydı Tamamla ve Giriş Yap", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController controller, {bool isPass = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}