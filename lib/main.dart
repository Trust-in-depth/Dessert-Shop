// lib/main.dart

import 'package:flutter/material.dart';
import 'package:shredrek/features/settings_module/screens/pin_setup_screen.dart';
import 'package:shredrek/features/settings_module/screens/pin_login_screen.dart';
import 'package:shredrek/features/shred_module/screens/file_selection_screen.dart';
import 'package:shredrek/core/database/db_helper.dart'; // Veritabanı yardımcınız
import 'package:shredrek/models/settings.dart'; // Ayarlar modeliniz

void main() async {
  // 1. Flutter Motorunu Başlatma
  WidgetsFlutterBinding.ensureInitialized(); 

  // 2. Veritabanını Başlatma
  await DbHelper.instance.database; // Veritabanı bağlantısının kurulduğundan emin oluruz

  // 3. Uygulamayı Başlatma
  runApp(const ShredrekApp());
}

class ShredrekApp extends StatelessWidget {
  const ShredrekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shredrek - Güvenli Silme',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // İlk ekranı belirleyen FutureBuilder
      home: FutureBuilder<bool>(
        // PIN ayarlanıp ayarlanmadığını kontrol eden fonksiyon
        future: _checkPinStatus(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Veritabanı kontrol edilirken yükleme ekranı göster
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            // Hata durumu
            return const Scaffold(body: Center(child: Text('Uygulama Hatası')));
          } 
          
          // PIN durumu kontrolü
          final bool isPinSet = snapshot.data ?? false;
          
          if (!isPinSet) {
            // PIN ayarlanmamışsa: İlk defa PIN oluşturma ekranına yönlendir
            return const PinSetupScreen(); 
          } else {
            // PIN ayarlanmışsa: Giriş yapmak için PIN Giriş ekranına yönlendir
            return const PinLoginScreen(); 
          }
        },
      ),
      // Diğer rotalar (sayfalar arası geçiş için)
      routes: {
        '/home': (context) => const FileSelectionScreen(),
        // Diğer modül ekranlarını buraya ekleyeceksiniz:
        // '/log': (context) => const ShredHistoryListScreen(),
        // '/settings': (context) => const SettingsScreen(),
        // '/secret': (context) => const SecretStorageScreen(),
      },
    );
  }
}

// PIN durumunu veritabanından kontrol eden fonksiyon
Future<bool> _checkPinStatus() async {
  // Veritabanından settings tablosundaki PIN bilgisini çek
  final settings = await DbHelper.instance.getSettings(); 
  
  // Eğer settings kaydı varsa VE hashlenmiş PIN alanı boş değilse PIN ayarlanmıştır
  return settings != null && settings.pinHash.isNotEmpty;
}