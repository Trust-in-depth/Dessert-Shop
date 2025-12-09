// lib/features/shred_module/screens/file_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shredrek/features/shred_module/screens/staging_screen.dart'; // Bir sonraki ekran

class FileSelectionScreen extends StatefulWidget {
  const FileSelectionScreen({super.key});

  @override
  State<FileSelectionScreen> createState() => _FileSelectionScreenState();
}

class _FileSelectionScreenState extends State<FileSelectionScreen> {
  // Sol menü (Drawer) için anahtar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Dosya seçme işlemi
  void _pickFiles() async {
    // Kullanıcının birden fazla dosya seçmesine izin verir
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      // Seçilen PlatformFile nesnelerini bir sonraki ekrana gönder
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StagingScreen(selectedFiles: result.files),
          ),
        );
      }
    } else {
      // Kullanıcı seçimi iptal etti
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dosya seçimi iptal edildi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: const Text('Shredrek - Ana Sayfa')),
      // Uygulamanın navigasyonu için sol menü
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menü',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Loglar / Geçmiş'),
              onTap: () {
                // Modül 2 rotasına yönlendirme yapılacak
                Navigator.pop(context);
                // Navigator.of(context).pushNamed('/log');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar & Güvenlik'),
              onTap: () {
                // Modül 3 rotasına yönlendirme yapılacak
                Navigator.pop(context);
                // Navigator.of(context).pushNamed('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Gizli Sayfa (PIN Gerekli)'),
              onTap: () {
                // Gizli Sayfa PIN girişine yönlendirme yapılacak
                Navigator.pop(context);
                // Navigator.of(context).pushNamed('/secret_login');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Hakkında'),
              onTap: () {
                // Hakkında ekranına yönlendirme
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.folder_open, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 20),
            const Text(
              'Güvenli bir işlem yapmak için dosya seçin',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.upload_file),
              label: const Text('Dosya Seç', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
