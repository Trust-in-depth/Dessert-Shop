// lib/features/settings_module/screens/pin_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:shredrek/core/database/db_helper.dart';
import 'package:shredrek/core/security/security_utils.dart';
import 'package:shredrek/features/shred_module/screens/file_selection_screen.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorMessage;

  // PIN'i hash'ler ve veritabanına kaydeder
  void _setupPin() async {
    final String pin = _pinController.text;

    if (pin.length < 4) {
      setState(() {
        _errorMessage = "PIN en az 4 haneli olmalıdır.";
      });
      return;
    }

    // 1. PIN'i Hashleme
    final String pinHash = SecurityUtils.hashPin(pin);

    // 2. Hashlenmiş PIN'i veritabanına kaydetme (Sadece PIN alanını güncelleyeceğiz)
    final int rowsAffected = await DbHelper.instance.updatePin(pinHash);

    if (rowsAffected > 0) {
      // Başarılı olursa, ana sayfaya yönlendir
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      // Hata durumunda
      setState(() {
        _errorMessage = "PIN oluşturulurken bir hata oluştu.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔐 PIN Oluşturma')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Uygulamanızı korumak için lütfen bir PIN belirleyin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6, // 4-6 haneli PIN'ler yaygındır
              decoration: InputDecoration(
                labelText: 'Yeni PIN',
                errorText: _errorMessage,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setupPin,
              child: const Text('PIN Oluştur ve Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
