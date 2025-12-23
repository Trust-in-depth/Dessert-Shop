import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ders7flutterproject/mainpage.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupPageState();
}

class _SignupPageState extends State<Signup> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- PEMBE RENK PALETİ (Login ile Aynı) ---
  final Color _primaryPink = const Color(0xFFE91E63);
  final Color _backgroundPink = const Color(0xFFFCE4EC);
  final Color _textColor = const Color(0xFF4A2C2C);

  // Kayıt Ol Fonksiyonu
  Future<void> signUp() async {
    // Email veya şifre boşsa uyarı ver
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
      return;
    }

    // Yükleniyor...
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: _primaryPink)),
    );

    try {
      // Firebase'de kullanıcı oluştur
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat

        // Başarılı olursa direkt Ana Sayfaya gönder
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hesap başarıyla oluşturuldu! Hoşgeldiniz."),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Kayıt Hatası: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundPink,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. DALGALI GÖRSEL ALANI (Login ile aynı görsel)
            ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: size.height * 0.35,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/cake4.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        _primaryPink.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. FORM ALANI
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10,
              ),
              child: Column(
                children: [
                  Text(
                    "Aramıza Katıl",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tatlı dünyasına ilk adımını at.",
                    style: TextStyle(
                      fontSize: 16,
                      color: _textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email Input
                  _buildSweetTextField(
                    controller: _emailController,
                    label: 'E-posta Adresi',
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 20),

                  // Şifre Input
                  _buildSweetTextField(
                    controller: _passwordController,
                    label: 'Şifre Belirle',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  const SizedBox(height: 30),

                  // KAYIT OL BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryPink,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: _primaryPink.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "KAYIT OL",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Zaten hesabın var mı? (Geri Dönüş)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Zaten hesabın var mı? ",
                        style: TextStyle(color: _textColor),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Login sayfasına geri dön (Pop işlemi)
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Giriş Yap",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _primaryPink,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Yardımcı Widget: Tatlı Input Kutucuğu
  Widget _buildSweetTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _primaryPink.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: _textColor),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: _primaryPink),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}

// Dalga Efekti (Login sayfasındaki ile aynı)
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(
      size.width - (size.width / 4),
      size.height - 80,
    );
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
