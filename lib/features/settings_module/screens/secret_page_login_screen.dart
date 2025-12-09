// lib/features/settings_module/screens/secret_page_login_screen.dart

import 'package:flutter/material.dart';
import 'package:shredrek/core/database/db_helper.dart';
import 'package:shredrek/core/security/security_utils.dart';
import 'package:shredrek/features/shred_module/screens/secret_storage_screen.dart'; // Gizli Alan

class SecretPageLoginScreen extends StatefulWidget {
  const SecretPageLoginScreen({super.key});

  @override
  State<SecretPageLoginScreen> createState() => _SecretPageLoginScreenState();
}

class _SecretPageLoginScreenState extends State<SecretPageLoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorMessage;

  void _verifySecretPin() async {
    final enteredPin = _pinController.text;
    final settings = await DbHelper.instance.getSettings();

    if (settings == null) return;

    final storedHash = settings.pinHash;

    if (SecurityUtils.verifyPin(enteredPin, storedHash)) {
      // Doğru PIN: Gizli alana yönlendir
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SecretStorageScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = "Hatalı PIN. Gizli alana erişim reddedildi.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gizli Alan Girişi')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Gizli depolama alanına erişmek için PIN\'inizi tekrar giriniz.',
              textAlign: TextAlign.center,
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
              onPressed: _verifySecretPin,
              child: const Text('Gizli Alana Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
