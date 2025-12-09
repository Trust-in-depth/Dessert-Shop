// lib/features/settings_module/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:shredrek/core/database/db_helper.dart';
import 'package:shredrek/models/settings.dart';
import 'package:shredrek/features/settings_module/screens/pin_change_screen.dart';
import 'package:shredrek/features/settings_module/screens/secret_page_login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Settings? _currentSettings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Ayarları veritabanından çeker
  void _loadSettings() async {
    final settings = await DbHelper.instance.getSettings();
    setState(() {
      _currentSettings = settings;
      _isLoading = false;
    });
  }

  // Varsayılan Shred Yöntemini Güncelleme
  void _updateDefaultShredMethod(String? newValue) async {
    if (newValue != null && _currentSettings != null) {
      final updatedSettings = Settings(
        id: 1,
        pinHash: _currentSettings!.pinHash,
        defaultShredMethod: newValue,
        requireConfirmation: _currentSettings!.requireConfirmation,
      );
      await DbHelper.instance.updateSettings(updatedSettings);
      _loadSettings(); // Ekranı yenile
    }
  }

  // İki Kez Onay İste ayarını güncelleme
  void _toggleConfirmation(bool newValue) async {
    if (_currentSettings != null) {
      final updatedSettings = Settings(
        id: 1,
        pinHash: _currentSettings!.pinHash,
        defaultShredMethod: _currentSettings!.defaultShredMethod,
        requireConfirmation: newValue ? 1 : 0,
      );
      await DbHelper.instance.updateSettings(updatedSettings);
      _loadSettings(); // Ekranı yenile
    }
  }

  @override
  Widget build(BuildContext setContext) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ayarlar')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_currentSettings == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ayarlar')),
        body: Center(child: Text('Ayarlar yüklenemedi.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar & Güvenlik')),
      body: ListView(
        children: [
          // --- Güvenlik Ayarları Bölümü ---
          ListTile(
            leading: const Icon(Icons.password, color: Colors.blue),
            title: const Text('PIN Değiştir'),
            subtitle: const Text('Mevcut uygulama giriş PIN\'ini güncelleyin.'),
            onTap: () {
              Navigator.of(setContext)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => const PinChangeScreen(),
                    ),
                  )
                  .then((_) => _loadSettings()); // Geri dönünce ayarları yenile
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_person, color: Colors.purple),
            title: const Text('Gizli Sayfaya Git'),
            subtitle: const Text('Dosya gizleme alanına erişin. (PIN Gerekli)'),
            onTap: () {
              // Gizli Sayfa PIN Giriş ekranına yönlendirme
              Navigator.of(setContext).push(
                MaterialPageRoute(
                  builder: (context) => const SecretPageLoginScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // --- Shred Ayarları Bölümü ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shred Ayarları',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                // Varsayılan Shred Yöntemi
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Varsayılan Shred Yöntemi',
                  ),
                  value: _currentSettings!.defaultShredMethod,
                  items: const [
                    DropdownMenuItem(
                      value: '1-pass',
                      child: Text('1-Pass (Hızlı)'),
                    ),
                    DropdownMenuItem(
                      value: '3-pass',
                      child: Text('3-Pass (Güvenli)'),
                    ),
                  ],
                  onChanged: _updateDefaultShredMethod,
                ),

                // Onay İste Seçeneği
                SwitchListTile(
                  title: const Text('Silme işleminden önce iki kez onay iste'),
                  value: _currentSettings!.requireConfirmation == 1,
                  onChanged: _toggleConfirmation,
                ),
              ],
            ),
          ),

          const Divider(),

          // --- Hakkında Ekranı ---
          ListTile(
            leading: const Icon(Icons.info, color: Colors.grey),
            title: const Text('Hakkında ve Kavramlar'),
            subtitle: const Text(
              'Shredder ve depolama teknolojileri hakkında bilgi.',
            ),
            onTap: () {
              // Hakkında/Info ekranına yönlendirme yapılacak
              // Navigator.of(setContext).pushNamed('/about');
            },
          ),
        ],
      ),
    );
  }
}
