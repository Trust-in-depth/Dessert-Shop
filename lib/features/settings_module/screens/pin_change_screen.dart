// lib/features/settings_module/screens/pin_change_screen.dart

import 'package:flutter/material.dart';
import 'package:shredrek/core/database/db_helper.dart';
import 'package:shredrek/core/security/security_utils.dart';
import 'package:shredrek/models/settings.dart';

class PinChangeScreen extends StatefulWidget {
  const PinChangeScreen({super.key});

  @override
  State<PinChangeScreen> createState() => _PinChangeScreenState();
}

class _PinChangeScreenState extends State<PinChangeScreen> {
  final TextEditingController _currentPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  String? _errorMessage;
  Settings? _appSettings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    _appSettings = await DbHelper.instance.getSettings();
  }

  void _changePin() async {
    final currentPin = _currentPinController.text;
    final newPin = _newPinController.text;

    if (_appSettings == null) return;

    // 1. Mevcut PIN Doğrulama
    if (!SecurityUtils.verifyPin(currentPin, _appSettings!.pinHash)) {
      setState(() => _errorMessage = "Mevcut PIN hatalı.");
      return;
    }

    // 2. Yeni PIN Kontrolü
    if (newPin.length < 4) {
      setState(() => _errorMessage = "Yeni PIN en az 4 haneli olmalıdır.");
      return;
    }

    // 3. Yeni PIN'i Hashleme ve Kaydetme
    final newPinHash = SecurityUtils.hashPin(newPin);
    await DbHelper.instance.updatePin(newPinHash);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN başarıyla güncellendi!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PIN Değiştirme')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            TextField(
              controller: _currentPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Mevcut PIN'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Yeni PIN',
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _changePin,
              child: const Text('PIN\'i Değiştir'),
            ),
          ],
        ),
      ),
    );
  }
}
