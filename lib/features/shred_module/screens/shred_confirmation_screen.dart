// lib/features/shred_module/screens/shred_confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shredrek/features/shred_module/services/shred_service.dart';
import 'package:shredrek/core/database/db_helper.dart';
import 'package:shredrek/models/log_entry.dart';

class ShredConfirmationScreen extends StatefulWidget {
  final PlatformFile fileToShred; // Tek bir dosya

  const ShredConfirmationScreen({super.key, required this.fileToShred});

  @override
  State<ShredConfirmationScreen> createState() =>
      _ShredConfirmationScreenState();
}

class _ShredConfirmationScreenState extends State<ShredConfirmationScreen> {
  int _selectedPassCount = 1; // Varsayılan: 1-pass
  bool _isProcessing = false;
  final ShredService _shredService = ShredService();

  // Shred işlemini başlatır ve loglar
  void _startShredding() async {
    setState(() => _isProcessing = true);
    final filePath = widget.fileToShred.path!;

    try {
      // 1. Güvenli Silme (Shredding)
      await _shredService.shredFile(filePath, passCount: _selectedPassCount);

      // 2. Başarılı Log Kaydı
      final logEntry = LogEntry(
        fileName: widget.fileToShred.name,
        filePath: 'N/A (Shredded)', // Silindiği için yol belirtilmez
        fileSize: '${(widget.fileToShred.size / 1024).toStringAsFixed(2)} KB',
        status: 'SHREDDED',
        shredMethod: '$_selectedPassCount-pass',
        passCount: _selectedPassCount,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await DbHelper.instance.insertLog(logEntry);

      // 3. Sonuç Ekranına Yönlendirme
      if (mounted) {
        // Sonuç ekranına (ShredResultScreen) yönlendirme yapılacak
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ShredResultScreen(success: true),
          ),
        );
      }
    } catch (e) {
      // Hata Loglama ve Hata Ekranına Yönlendirme
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ShredResultScreen(success: false),
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Güvenli Silme İşlemi Yapılıyor... Lütfen Bekleyin.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kalıcı Silme Onayı')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dosya Adı: ${widget.fileToShred.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Seçilen bu dosya kalıcı olarak silinecektir. Geri getirilmesi mümkün olmayacaktır.',
            ),
            const Divider(),
            const Text(
              'Shredding Yöntemini Seçin:',
              style: TextStyle(fontSize: 16),
            ),
            RadioListTile<int>(
              title: const Text('1-Pass (Hızlı ve Temel)'),
              subtitle: const Text(
                'Dosyanın üzerine bir kez rastgele veri yazar.',
              ),
              value: 1,
              groupValue: _selectedPassCount,
              onChanged: (val) => setState(() => _selectedPassCount = val!),
            ),
            RadioListTile<int>(
              title: const Text('3-Pass (Daha Güvenli)'),
              subtitle: const Text(
                'Dosyanın üzerine üç kez rastgele veri yazar (DoD 5220.22-M standardını simüle eder).',
              ),
              value: 3,
              groupValue: _selectedPassCount,
              onChanged: (val) => setState(() => _selectedPassCount = val!),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _startShredding,
                icon: const Icon(Icons.warning),
                label: const Text('KALICI OLARAK SHRED ET'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Basit Sonuç Ekranı (Modül 1 gereksinimi)
class ShredResultScreen extends StatelessWidget {
  final bool success;
  const ShredResultScreen({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shred Sonucu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              success
                  ? 'Başarıyla Shred Edildi!'
                  : 'Shred İşlemi Başarısız Oldu.',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Ana Sayfaya Dön'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/log'),
              child: const Text('Log Detaylarını Gör'),
            ),
          ],
        ),
      ),
    );
  }
}
