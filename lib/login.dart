import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ders7flutterproject/mainpage.dart';
import 'package:ders7flutterproject/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- PEMBE RENK PALETİ (Efsane Geri Döndü) ---
  final Color _primaryPink = const Color(0xFFE91E63); // Canlı pembe
  final Color _backgroundPink = const Color(0xFFFCE4EC); // Çok açık toz pembe
  final Color _textColor = const Color(0xFF4A2C2C); // Çikolata rengi yazı

  Future<void> login() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: _primaryPink)),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Giriş Hatası: ${e.toString()}"),
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
            // 1. DALGALI GÖRSEL ALANI
            ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height:
                    size.height *
                    0.40, // Yüksekliği biraz artırdım, kekler daha çok görünsün
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    // YENİ FOTOĞRAFIN BURADA:
                    image: AssetImage('assets/cupcake2.webp'),
                    fit: BoxFit.cover, // Alanı tamamen kaplasın
                  ),
                ),
                child: Container(
                  // Yazıların okunması için resmin üzerine çok hafif pembe perde
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        _primaryPink.withOpacity(0.2), // Hafif pembe geçiş
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
                    " Hoşgeldiniz!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "...Tatlı Dükkanı...",
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
                    label: 'Şifre',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  const SizedBox(height: 30),

                  // Giriş Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: login,
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
                        "GİRİŞ YAP",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Kayıt Ol Linki
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Henüz üye değil misin? ",
                        style: TextStyle(color: _textColor),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Signup()),
                          );
                        },
                        child: Text(
                          "Hemen Kayıt Ol",
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

// Dalga Efekti Sınıfı
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    // 1. Dalga
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // 2. Dalga
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
