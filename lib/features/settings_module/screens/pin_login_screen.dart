// lib/features/settings_module/screens/pin_login_screen.dart

import 'package:flutter/material.dart';
import 'package:shredrek/core/database/db_helper.dart';
import 'package:shredrek/core/security/security_utils.dart';
import 'package:shredrek/models/settings.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorMessage;
  Settings?
  _appSettings; // Veritabanından çekilen ayarlar (Hashlenmiş PIN burada)
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Veritabanından hashlenmiş PIN'i içeren ayarları çeker
  void _loadSettings() async {
    final settings = await DbHelper.instance.getSettings();
    setState(() {
      _appSettings = settings;
      _isLoading = false;
    });
  }

  // PIN doğrulama işlemini yapar
  void _verifyPin() {
    if (_appSettings == null) {
      setState(
        () => _errorMessage = "Ayarlar yüklenemedi. Lütfen tekrar deneyin.",
      );
      return;
    }

    final String enteredPin = _pinController.text;
    final String storedHash = _appSettings!.pinHash;

    if (enteredPin.isEmpty) {
      setState(() => _errorMessage = "Lütfen PIN'i giriniz.");
      return;
    }

    // Hash karşılaştırması için SecurityUtils kullanılıyor
    final bool isCorrect = SecurityUtils.verifyPin(enteredPin, storedHash);

    if (isCorrect) {
      // Doğru PIN: Ana sayfaya yönlendir
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      // Yanlış PIN
      setState(() {
        _errorMessage = "Hatalı PIN. Lütfen tekrar deneyin.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('🔐 Shredrek Giriş')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Uygulamaya devam etmek için PIN\'inizi giriniz.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'PIN',
                errorText: _errorMessage,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyPin,
              child: const Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
